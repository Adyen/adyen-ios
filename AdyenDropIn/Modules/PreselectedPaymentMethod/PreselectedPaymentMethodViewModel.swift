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

internal protocol PreselectedPaymentMethodViewModelProtocol: AnyObject {

    // To Retrieve what to be displayed
    var cardImageItem: CardImageItem { get }
    var titleText: String { get }
    var subtitleText: String { get }

    var submitButtonTitle: String { get }
    func submitPayment()

    var showAllPaymentMethodsButtonTitle: String { get }
    func showAllPaymentMethods()
    /// Theming
    var theme: AdyenTheme { get }

    /// Loading state
    var onLoadingStateChange: ((_ isLoading: Bool) -> Void)? { get set }

    // Actions
    func cancel()
    func viewDidLoad()
}

internal final class PreselectedPaymentMethodViewModel: PreselectedPaymentMethodViewModelProtocol {

    private enum Constants {
        static let cardImageSize = CGSize(width: 80, height: 52)
    }

    // MARK: - Properties

    private let component: PaymentComponent
    internal let theme: AdyenTheme
    private let localizationParameters: LocalizationParameters?
    private let dropInFlowManager: DropInFlowManaging

    internal weak var router: PreselectedPaymentMethodRouting?

    // TODO: Robert: DropInComponent needs to send an event on the component being loaded.
    /// Callback for when the component is loaded on display.
    internal var onDidLoad: (() -> Void)?

    /// Callback for when the loading state changes.
    internal var onLoadingStateChange: ((_ isLoading: Bool) -> Void)?

    // MARK: - Initializers

    internal init(
        component: PaymentComponent,
        theme: AdyenTheme,
        localizationParameters: LocalizationParameters?,
        dropInFlowManager: DropInFlowManaging
    ) {
        self.component = component
        self.dropInFlowManager = dropInFlowManager
        self.theme = theme
        self.localizationParameters = localizationParameters
    }

    // MARK: - PreselectedPaymentMethodViewModelProtocol

    internal var cardImageItem: CardImageItem {
        let paymentMethod = component.paymentMethod
        let displayInformation = paymentMethod.displayInformation(using: localizationParameters)
        // TODO: Robert: This will change as we will not rely on DisplayInformation for V6.
        let imageURL = LogoURLProvider.logoURL(
            withName: displayInformation.logoName,
            environment: component.context.apiContext.environment,
            size: .large
        )
        return CardImageItem(
            imageURL: imageURL,
            sizeMode: .fixed(Constants.cardImageSize),
            theme: theme
        )
    }

    internal var titleText: String {
        let displayInformation = component.paymentMethod.displayInformation(using: localizationParameters)
        return displayInformation.title
    }

    private var formattedAmount: String {
        let amount = component.context.amount
        guard let formatted = AmountFormatter.formatted(amount: amount.value, currencyCode: amount.currencyCode) else {
            return ""
        }
        return formatted
    }

    internal var subtitleText: String {
        localizedString(.preselectedPaymentMethodSubtitle, localizationParameters, component.paymentMethod.name, formattedAmount)
    }

    internal var submitButtonTitle: String {
        localizedString(.submitButtonFormatted, localizationParameters, formattedAmount)
    }

    internal func submitPayment() {
        didProceed(with: self.component)
    }

    internal var showAllPaymentMethodsButtonTitle: String {
        localizedString(.preselectedPaymentMethodOtherOptions, localizationParameters)
    }

    internal func showAllPaymentMethods() {
        didRequestAllPaymentMethods()
    }

    internal func viewDidLoad() {
        onDidLoad?()
    }

    internal func cancel() {
        dropInFlowManager.cancel(component: component)

        stopLoading()
        router?.dismiss(completion: nil)
    }

    // MARK: - Button Actions to Pay or Other Payment options

    private func didRequestAllPaymentMethods() {
        router?.presentPaymentMethodList()
    }

    private func didProceed(with component: any PaymentComponent) {
        startPaymentFlow(for: component)
    }

    private func startPaymentFlow(for component: PaymentComponent) {
        startLoading(for: component)

        switch component.type {
        case .regular, .stored:
            router?.present(component: component) { [weak self] in
                self?.stopLoading()
            }
        case let .initiable(initiablePaymentComponent):
            initiablePaymentComponent.initiatePayment(delegate: self)
        }
    }

    // MARK: -

    private func startLoading(for component: PaymentComponent) {
        onLoadingStateChange?(true)
    }

    private func stopLoading() {
        onLoadingStateChange?(false)
    }
}

// MARK: - PaymentComponentDelegate

extension PreselectedPaymentMethodViewModel: PaymentComponentDelegate {
    
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
        if case ComponentError.cancelled = error {
            cancel()
        } else {
            dropInFlowManager.fail(with: error, from: component)
        }
    }
}

// MARK: - ActionPresenter

extension PreselectedPaymentMethodViewModel: ActionPresenter {

    internal func present(actionComponent: any PresentableComponent) {
        router?.present(actionComponent: actionComponent) { [weak self] in
            self?.stopLoading()
        }
    }

    internal func didCancel(actionComponent: any ActionComponent) {
        stopLoading()
    }
}
