//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Combine
@_spi(AdyenInternal) import struct Adyen.LocalizationKey
import Foundation

#if canImport(AdyenUI)
    import AdyenUI
#endif

@MainActor
internal final class PreselectedPaymentMethodViewModel: ObservableObject {

    // MARK: - Properties

    private let component: PaymentComponent
    internal let theme: CheckoutTheme
    private let localizationParameters: LocalizationParameters?
    internal let showsAllPaymentMethodsButton: Bool
    private let dropInFlowManager: DropInFlowManaging
    internal let analyticsProvider: AnyAnalyticsProvider?
    internal let dropInAnalyticsConfiguration: DropInAnalyticsConfiguration
    internal weak var router: PreselectedPaymentMethodRouting?

    // TODO: Robert: DropInComponent needs to send an event on the component being loaded.
    /// Callback for when the component is loaded on display.
    internal var onDidLoad: (() -> Void)?

    @Published internal private(set) var isLoading = false

    // MARK: - Initializers

    internal init(
        component: PaymentComponent,
        theme: CheckoutTheme,
        localizationParameters: LocalizationParameters?,
        showsAllPaymentMethodsButton: Bool,
        analyticsProvider: AnyAnalyticsProvider?,
        dropInAnalyticsConfiguration: DropInAnalyticsConfiguration,
        dropInFlowManager: DropInFlowManaging
    ) {
        self.component = component
        self.dropInFlowManager = dropInFlowManager
        self.analyticsProvider = analyticsProvider
        self.dropInAnalyticsConfiguration = dropInAnalyticsConfiguration
        self.theme = theme
        self.localizationParameters = localizationParameters
        self.showsAllPaymentMethodsButton = showsAllPaymentMethodsButton
    }

    // MARK: - Display Properties

    internal var paymentMethodLogoURL: URL {
        let paymentMethod = component.paymentMethod
        let displayInformation = paymentMethod.displayInformation(using: localizationParameters)
        // TODO: Robert: This will change as we will not rely on DisplayInformation for V6.
        return LogoURLProvider.logoURL(
            withName: displayInformation.logoName,
            environment: component.context.apiContext.environment,
            size: .large
        )
    }

    internal var titleText: String {
        let displayInformation = component.paymentMethod.displayInformation(using: localizationParameters)
        return displayInformation.title
    }

    internal var subtitleText: String {
        localizedString(.preselectedPaymentMethodSubtitle, localizationParameters, component.paymentMethod.name)
    }

    internal var submitButtonTitle: String {
        AmountAwarePaymentStringsPolicy.payButtonTitle(
            with: component.context.amount,
            localizationParameters: localizationParameters
        )
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
        sendDidLoadEvent()
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

        switch component.type {
        case .regular, .stored:
            router?.present(component: component)
        case .generic:
            startLoading()
            component.performSubmit()
        }
    }

    // MARK: -

    private func startLoading() {
        isLoading = true
    }

    private func stopLoading() {
        isLoading = false
    }
}

// MARK: - PaymentComponentDelegate

extension PreselectedPaymentMethodViewModel: PaymentComponentDelegate {
    
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
        if case ComponentError.cancelled = error {
            cancel()
        } else {
            dropInFlowManager.fail(with: error, from: component)
        }
    }

    internal func sendDidLoadEvent() {
        var infoEvent = AnalyticsEventInfo(component: AnalyticsConstants.dropInComponentIdentifier, type: .rendered)
        infoEvent.configData = dropInAnalyticsConfiguration
        analyticsProvider?.add(info: infoEvent)
    }
}
