//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif

internal enum PaymentMethodListState {
    case idle
    case loaded(sections: [ListSection])
}

// sourcery:AutoMockable
@MainActor
internal protocol PaymentMethodListViewModelProtocol {
    var context: AdyenContext { get }
    var title: String { get }
    var paymentMethodSections: [PaymentMethodsSection] { get }
    var statePublisher: Published<PaymentMethodListState>.Publisher { get }
    func cancel()
    func didLoad()
    func listItemIdentifier(for paymentMethod: PaymentMethod) -> String
}

@MainActor
internal class PaymentMethodListViewModel: PaymentMethodListViewModelProtocol {

    // MARK: - Properties

    internal let context: AdyenContext
    internal let localizationParameters: LocalizationParameters
    internal let componentManager: ComponentManaging
    internal weak var router: PaymentMethodListRouting?
    private let dropInFlowManager: DropInFlowManaging
    private let logoURLProvider: LogoURLProvider

    @Published internal private(set) var state: PaymentMethodListState = .idle
    internal var statePublisher: Published<PaymentMethodListState>.Publisher {
        $state
    }

    internal let paymentMethodSections: [PaymentMethodsSection]
    private let brandProtectedComponents: Set<PaymentMethodType> = [.applePay]

    // MARK: - Initializers

    internal init(
        context: AdyenContext,
        localizationParameters: LocalizationParameters,
        componentManager: ComponentManaging,
        configuration: DropInComponent.Configuration,
        dropInFlowManager: DropInFlowManaging,
        logoURLProvider: LogoURLProvider
    ) {
        self.context = context
        self.localizationParameters = localizationParameters
        self.componentManager = componentManager
        self.paymentMethodSections = componentManager.sections
        self.dropInFlowManager = dropInFlowManager
        self.logoURLProvider = logoURLProvider
    }

    // MARK: - PaymentMethodListViewModelProtocol

    internal var title: String {
        localizedString(.paymentMethodsTitle, localizationParameters)
    }

    internal func cancel() {
        router?.dismiss(completion: nil)
    }

    internal func didLoad() {
        // TODO: - Handle analytics on list load.
        let listSections = getListSections()
        state = .loaded(sections: listSections)
    }

    // MARK: - Private

    private func select(paymentMethod: PaymentMethod) {
        guard let component = componentManager.buildComponent(for: paymentMethod) else { return }

        switch component.type {
        case .regular, .stored:
            router?.present(component: component) { [weak self] in
                self?.state = .idle
            }
        case let .initiable(initiablePaymentComponent):
            listItem(for: paymentMethod)?.startLoading()
            initiablePaymentComponent.initiatePayment(delegate: self)
        }
    }

    private func delete(paymentMethod: PaymentMethod, completion: @escaping Adyen.Completion<Bool>) {
        // TODO: - Logic to delete stored payment method
    }

    private func getListSections() -> [ListSection] {
        paymentMethodSections.map { section in
            let paymentMethods = section.paymentMethods
            let paymentMethodItems = paymentMethods.map { listItem(from: $0) }
            return ListSection(
                header: section.header,
                items: paymentMethodItems,
                footer: section.footer
            )
        }
    }

    private func listItem(from paymentMethod: PaymentMethod) -> ListItem {
        let displayInformation = paymentMethod.displayInformation(using: localizationParameters)
        let isProtected = brandProtectedComponents.contains(paymentMethod.type)
        let imageURL = logoURLProvider.logoURL(withName: displayInformation.logoName)

        let listItem = ListItem(
            title: displayInformation.title,
            subtitle: displayInformation.subtitle,
            icon: .init(
                url: imageURL,
                canBeModified: !isProtected
            ),
            trailingInfo: displayInformation.trailingInfo?.forListItem(urlProvider: logoURLProvider),
            style: .init(),
            accessibilityLabel: displayInformation.accessibilityLabel
        )
        listItem.identifier = listItemIdentifier(for: paymentMethod)
        listItem.selectionHandler = { [weak self] in
            guard !(paymentMethod is OrderPaymentMethod) else { return }
            self?.select(paymentMethod: paymentMethod)
        }
        listItem.deletionHandler = { [weak self] _, completion in
            self?.delete(paymentMethod: paymentMethod, completion: completion)
        }

        return listItem
    }

    internal func listItemIdentifier(for paymentMethod: PaymentMethod) -> String {
        let uniqueIdentifier: String
        if let storedPaymentMethod = paymentMethod as? StoredPaymentMethod {
            uniqueIdentifier = "\(paymentMethod.type.rawValue).\(storedPaymentMethod.identifier)"
        } else {
            uniqueIdentifier = paymentMethod.type.rawValue
        }
        return ViewIdentifierBuilder.build(
            scopeInstance: "PaymentMethodListViewModel",
            postfix: uniqueIdentifier
        )
    }

    private func listItem(for paymentMethod: PaymentMethod) -> ListItem? {
        guard case let .loaded(sections) = state else { return nil }
        let expectedIdentifier = listItemIdentifier(for: paymentMethod)
        return sections
            .flatMap(\.items)
            .first { $0.identifier == expectedIdentifier }
    }
}

// MARK: - PaymentComponentDelegate

extension PaymentMethodListViewModel: PaymentComponentDelegate {
    
    internal func didSubmit(
        _ data: PaymentComponentData,
        from component: any PaymentComponent
    ) {
        dropInFlowManager.submit(data, from: component, actionPresenter: self)
    }
    
    internal func didFail(
        with error: any Error,
        from component: any PaymentComponent
    ) {
        defer { state = .idle }

        if case ComponentError.cancelled = error {
            cancel()
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

internal extension DisplayInformation.TrailingInfoType {

    func forListItem(urlProvider: LogoURLProvider) -> ListItem.TrailingInfoType {
        switch self {
        case let .text(string):
            return .text(string)
        case let .logos(logoNames, trailingText):
            return .logos(urls: logoNames.map { urlProvider.logoURL(withName: $0) }, trailingText: trailingText)
        }
    }
}
