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
    @_spi(AdyenInternal) import struct AdyenUI.ListSection
#endif

internal enum PaymentMethodListState {
    case idle
    case loading
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

    var formattedAmount: String { get }
    var subtitle: String { get }
    var applePayButtonState: PaymentMethodListHeaderViewModel.ApplePayButtonState { get }
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
    internal let theme: CheckoutTheme

    @Published internal private(set) var state: PaymentMethodListState = .idle
    internal var statePublisher: Published<PaymentMethodListState>.Publisher {
        $state
    }

    internal let paymentMethodSections: [PaymentMethodsSection]

    // MARK: - Initializers

    internal init(
        context: AdyenContext,
        localizationParameters: LocalizationParameters,
        componentManager: ComponentManaging,
        configuration: DropInComponent.Configuration,
        dropInFlowManager: DropInFlowManaging,
        logoURLProvider: LogoURLProvider,
        theme: CheckoutTheme
    ) {
        self.context = context
        self.localizationParameters = localizationParameters
        self.componentManager = componentManager
        self.paymentMethodSections = componentManager.sections
        self.dropInFlowManager = dropInFlowManager
        self.logoURLProvider = logoURLProvider
        self.theme = theme
    }

    // MARK: - PaymentMethodListViewModelProtocol

    internal var title: String {
        localizedString(.paymentMethodsTitle, localizationParameters)
    }

    internal var formattedAmount: String {
        context.amount?.formatted ?? ""
    }

    internal var subtitle: String {
        // TODO: - Add localization key for this string
        "Select your preferred payment option to complete the payment"
    }

    internal var applePayButtonState: PaymentMethodListHeaderViewModel.ApplePayButtonState {
        guard applePayPaymentMethod != nil else { return .hidden }
        return .visible { [weak self] in
            self?.startApplePay()
        }
    }

    private var applePayPaymentMethod: PaymentMethod? {
        paymentMethodSections
            .flatMap(\.paymentMethods)
            .first { $0.type == .applePay }
    }

    private var applePayComponent: PaymentComponent?
    private var initiablePaymentComponent: PaymentComponent?

    internal func cancel() {
        router?.dismiss(completion: nil)
    }

    internal func didLoad() {
        // TODO: - Handle analytics on list load.
        let sections = getSections()
        state = .loaded(sections: sections)
    }

    // MARK: - Private

    private func startApplePay() {
        guard applePayComponent == nil, let applePayPaymentMethod else { return }
        self.applePayComponent = componentManager.buildComponent(for: applePayPaymentMethod)
        applePayComponent?.delegate = self

        guard let applePayViewController = (applePayComponent as? PresentableComponent)?.viewController else { return }
        router?.present(viewController: applePayViewController)
    }

    internal func select(paymentMethod: PaymentMethod) {
        guard let component = componentManager.buildComponent(for: paymentMethod) else { return }

        switch component.type {
        case .regular, .stored:
            router?.present(component: component)
        case let .initiable(initiablePaymentComponent):
            state = .loading
            self.initiablePaymentComponent = initiablePaymentComponent
            initiablePaymentComponent.delegate = self
            initiablePaymentComponent.performSubmit()
        }
    }

    private func delete(paymentMethod: PaymentMethod, completion: @escaping Adyen.Completion<Bool>) {
        // TODO: - Logic to delete stored payment method
    }

    private func getSections() -> [PaymentMethodSection] {
        paymentMethodSections.map { section in
            let items = section.paymentMethods.filter {
                !Constants.instantPaymentMethods.contains($0.type)
            }.map(paymentMethodItem(from:))
            return PaymentMethodSection(
                headerTitle: section.header?.title,
                items: items,
                theme: theme
            )
        }
    }

    private func paymentMethodItem(from paymentMethod: PaymentMethod) -> PaymentMethodItem {
        let displayInformation = paymentMethod.displayInformation(using: localizationParameters)
        let imageURL = logoURLProvider.logoURL(withName: displayInformation.logoName)

        return PaymentMethodItem(
            title: displayInformation.title,
            subtitle: displayInformation.subtitle,
            iconURL: imageURL,
            trailingInfo: displayInformation.trailingInfo,
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
        initiablePaymentComponent = nil
        dropInFlowManager.submit(data, from: component, actionPresenter: self)
    }

    internal func didFail(
        with error: any Error,
        from component: any PaymentComponent
    ) {
        defer {
            state = .idle
            initiablePaymentComponent = nil
        }

        if case ComponentError.cancelled = error {
            applePayComponent = nil
        } else {
            dropInFlowManager.fail(with: error, from: component)
        }
    }
}

// MARK: - ActionPresenter

extension PaymentMethodListViewModel: ActionPresenter {

    internal func present(actionComponent: any PresentableComponent) {
        router?.present(actionComponent: actionComponent) { [weak self] in
            self?.state = .idle
        }
    }

    internal func didCancel(actionComponent: any ActionComponent) {
        state = .idle
    }
}
