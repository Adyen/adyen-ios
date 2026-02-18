//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenUI

internal enum PaymentMethodListState {
    case idle
    case loaded(sections: [ListSection])
    case loading(paymentMethod: PaymentMethod)
}

// sourcery:AutoMockable
internal protocol PaymentMethodListViewModelProtocol {
    var context: AdyenContext { get }
    var localizationParameters: LocalizationParameters? { get }
    func cancel()

    func didLoad()
    func select(_ component: PaymentComponent)
    func delete(_ storePaymentMethod: StoredPaymentMethod, completion: @escaping Completion<Bool>)
}

internal class PaymentMethodListViewModel: PaymentMethodListViewModelProtocol {

    // MARK: - Properties

    internal let context: AdyenContext
    internal let localizationParameters: LocalizationParameters?
    internal let componentManager: ComponentManager
    internal weak var router: PaymentMethodListRouting?
    private var dropInFlowManager: DropInFlowManaging

    @Published internal private(set) var state: PaymentMethodListState = .idle
    internal let componentSections: [ComponentsSection]
    private var paymentMethodSections: [ListSection] = []
    private let brandProtectedComponents: Set<PaymentMethodType> = [.applePay]

    // MARK: - Initializers

    internal init(
        context: AdyenContext,
        localizationParameters: LocalizationParameters? = nil,
        componentManager: ComponentManager,
        configuration: DropInComponent.Configuration,
        dropInFlowManager: DropInFlowManaging
    ) {
        self.context = context
        self.localizationParameters = localizationParameters
        self.componentManager = componentManager
        self.componentSections = componentManager.sections
        self.dropInFlowManager = dropInFlowManager
    }

    // MARK: - PaymentMethodListViewModelProtocol

    internal func cancel() {
        router?.dismiss(completion: nil)
    }

    internal func didLoad() {
        // TODO: - Handle analytics on list load.
        paymentMethodSections = getPaymentMethodSections()
        state = .loaded(sections: paymentMethodSections)
    }

    internal func select(_ component: PaymentComponent) {
        state = .loading(paymentMethod: component.paymentMethod)

        switch component.type {
        case .regular, .stored:
            router?.present(component: component) { [weak self] in
                self?.state = .idle
            }
        case let .initiable(initiablePaymentComponent):
            initiablePaymentComponent.initiatePayment(delegate: self)
        case .undefined:
            break
        }
    }

    internal func select(paymentMethod: PaymentMethod) {
        // TODO:
        print("⚠️⚠️⚠️ PAYMENT METHOD SELECTED ⚠️⚠️⚠️")
    }

    internal func delete(paymentMethod: PaymentMethod, completion: @escaping Adyen.Completion<Bool>) {
        // TODO:
    }

    internal func delete(_ storedPaymentMethod: StoredPaymentMethod, completion: @escaping Adyen.Completion<Bool>) {
        // TODO: - Logic to delete stored payment method
    }

    // MARK: - Private

    private func getPaymentMethodSections() -> [ListSection] {
        componentSections.map { section in
            let paymentMethods = section.components.compactMap(\.paymentMethod)
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
        let logoUrlProvider = LogoURLProvider(environment: context.apiContext.environment)
        let imageURL = logoUrlProvider.logoURL(withName: displayInformation.logoName)

        let listItem = ListItem(
            title: displayInformation.title,
            subtitle: displayInformation.subtitle,
            icon: .init(
                url: imageURL,
                canBeModified: !isProtected
            ),
            trailingInfo: displayInformation.trailingInfo?.forListItem(urlProvider: logoUrlProvider),
            style: .init(),
            accessibilityLabel: displayInformation.accessibilityLabel
        )
        listItem.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: listItem.title
        )
        listItem.selectionHandler = { [weak self] in
//            guard !(component is AlreadyPaidPaymentComponent) else { return }
            self?.select(paymentMethod: paymentMethod)
        }
        listItem.deletionHandler = { [weak self] _, completion in
            self?.delete(paymentMethod: paymentMethod, completion: completion)
        }

        return listItem
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
