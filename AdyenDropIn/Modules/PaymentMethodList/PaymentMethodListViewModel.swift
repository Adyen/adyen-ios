//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey
import Foundation
import UIKit
#if canImport(AdyenUI)
    import AdyenUI
#endif

internal enum PaymentMethodListState {
    case idle
    case loaded(sections: [PaymentMethodSection])
}

// sourcery:AutoMockable
@MainActor
internal protocol PaymentMethodListViewModelProtocol {
    var context: AdyenContext { get }
    var title: String { get }
    var paymentMethodSections: [PaymentMethodsSection] { get }
    var statePublisher: Published<PaymentMethodListState>.Publisher { get }
    var theme: CheckoutTheme { get }
    func cancel()
    func didLoad()

    var headerTitle: String { get }
    var subtitle: String { get }
    /// The Apple Pay component's button screen, or `nil` when Apple Pay isn't available.
    var applePayViewController: UIViewController? { get }
}

@MainActor
internal class PaymentMethodListViewModel: PaymentMethodListViewModelProtocol {

    // MARK: - Constants

    private enum Constants {
        /// Payment methods that are displayed separately (e.g., in the header) and should be filtered from the main list.
        internal static let instantPaymentMethods: Set<PaymentMethodType> = [.applePay]
    }

    // MARK: - Properties

    internal let context: AdyenContext
    internal let localizationParameters: LocalizationParameters
    internal let componentManager: ComponentManaging
    internal weak var router: PaymentMethodListRouting?
    private let dropInFlowManager: DropInFlowManaging
    private let logoURLProvider: LogoURLProvider
    private let supportsStoredPaymentMethodManagement: Bool
    internal let theme: CheckoutTheme

    @Published internal private(set) var state: PaymentMethodListState = .idle
    internal var statePublisher: Published<PaymentMethodListState>.Publisher {
        $state
    }

    internal var paymentMethodSections: [PaymentMethodsSection] {
        componentManager.sections
    }

    // MARK: - Initializers

    internal init(
        context: AdyenContext,
        localizationParameters: LocalizationParameters,
        componentManager: ComponentManaging,
        configuration: DropInConfiguration,
        dropInFlowManager: DropInFlowManaging,
        logoURLProvider: LogoURLProvider,
        supportsStoredPaymentMethodManagement: Bool,
        theme: CheckoutTheme
    ) {
        self.context = context
        self.localizationParameters = localizationParameters
        self.componentManager = componentManager
        self.dropInFlowManager = dropInFlowManager
        self.logoURLProvider = logoURLProvider
        self.supportsStoredPaymentMethodManagement = supportsStoredPaymentMethodManagement
        self.theme = theme
    }

    // MARK: - PaymentMethodListViewModelProtocol

    internal var title: String {
        localizedString(.paymentMethodsTitle, localizationParameters)
    }

    internal var headerTitle: String {
        AmountAwarePaymentStringsPolicy.paymentMethodListHeaderTitle(
            with: context.amount,
            localizationParameters: localizationParameters
        )
    }

    internal var subtitle: String {
        AmountAwarePaymentStringsPolicy.paymentMethodListSubtitle(
            with: context.amount,
            localizationParameters: localizationParameters
        )
    }

    internal var applePayViewController: UIViewController? {
        applePayComponent?.viewController
    }

    private var applePayPaymentMethod: PaymentMethod? {
        paymentMethodSections
            .flatMap(\.paymentMethods)
            .first { $0.type == .applePay }
    }

    // TODO: Building the Apple Pay component here sends its setup analytics request when the list loads,
    // duplicating Drop-in's own setup request. Remove once setup analytics move out of components.
    private lazy var applePayComponent: PaymentComponent? = {
        guard let applePayPaymentMethod,
              let component = componentManager.buildComponent(for: applePayPaymentMethod) else {
            return nil
        }
        component.delegate = self
        return component
    }()

    internal func cancel() {
        dropInFlowManager.cancelDropIn()

        // The dismissal travels up through the router listener, which tears down the drop in.
        router?.dismiss(completion: nil)
    }

    internal func didLoad() {
        // TODO: - Handle analytics on list load.
        let sections = getSections()
        state = .loaded(sections: sections)
    }

    // MARK: - Private

    internal func select(paymentMethod: PaymentMethod) {
        guard let component = componentManager.buildComponent(for: paymentMethod) else { return }
        router?.present(component: component)
    }

    internal func remove(storedPaymentMethod: any StoredPaymentMethod) {
        componentManager.removeStoredPaymentMethod(withIdentifier: storedPaymentMethod.identifier)
        state = .loaded(sections: getSections())
    }

    private func getSections() -> [PaymentMethodSection] {
        paymentMethodSections.map { section in
            let items = section.paymentMethods.filter {
                !Constants.instantPaymentMethods.contains($0.type)
            }.map(paymentMethodItem(from:))

            return PaymentMethodSection(
                headerTitle: section.headerTitle,
                headerTrailingButton: manageButton(for: section, items: items),
                items: items,
                theme: theme
            )
        }
    }

    private func manageButton(
        for section: PaymentMethodsSection,
        items: [PaymentMethodItem]
    ) -> PaymentMethodSection.HeaderTrailingButton? {
        switch section.kind {
        case .stored:
            guard supportsStoredPaymentMethodManagement, !items.isEmpty else {
                return nil
            }

            return .init(
                title: localizedString(.storedPaymentMethodManagementTitle, localizationParameters),
                handler: { [weak self] in
                    self?.router?.presentStoredPaymentMethodManagement()
                }
            )
        case .paid, .regular:
            return nil
        }
    }

    private func paymentMethodItem(from paymentMethod: PaymentMethod) -> PaymentMethodItem {
        let displayInformation = paymentMethod.displayInformation(using: localizationParameters)
        let imageURL = logoURLProvider.logoURL(withName: displayInformation.logoName)
        let trailingInfo: DisplayInformation.TrailingInfoType? = switch paymentMethod {
        case let cardPaymentMethod as CardPaymentMethod where !cardPaymentMethod.brands.isEmpty:
            .logos(named: cardPaymentMethod.brands.map(\.rawValue), trailingText: nil)
        default:
            displayInformation.trailingInfo
        }

        return PaymentMethodItem(
            title: displayInformation.title,
            subtitle: displayInformation.subtitle,
            subtitleStatus: displayInformation.subtitleStatus,
            iconURL: imageURL,
            trailingInfo: trailingInfo,
            logoURLProvider: logoURLProvider,
            accessibilityLabel: displayInformation.accessibilityLabel,
            theme: theme,
            selectionHandler: { [weak self] in
                guard !(paymentMethod is OrderPaymentMethod) else { return }
                self?.select(paymentMethod: paymentMethod)
            }
        )
    }
}

// MARK: - PaymentComponentDelegate

extension PaymentMethodListViewModel: PaymentComponentDelegate {

    internal func didSubmit(
        _ data: PaymentComponentData,
        from component: any PaymentComponent
    ) {
        dropInFlowManager.submit(data, from: component)
    }

    internal func didFail(
        with error: any Error,
        from component: any PaymentComponent
    ) {
        defer {
            state = .idle
        }

        if case ComponentError.cancelled = error {
            return
        }
        dropInFlowManager.fail(with: error, from: component)
    }
}
