//
// Copyright (c) 2026 Adyen N.V.
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

@MainActor
internal protocol StoredPaymentComponentViewModelProtocol: AnyObject {
    var cardImageItem: CardImageItem { get }
    var titleText: String { get }
    var subtitleText: String { get }
    var submitButtonTitle: String { get }
    var theme: CheckoutTheme { get }
    var onLoadingStateChange: ((_ isLoading: Bool) -> Void)? { get set }

    func submitPayment()
    func cancel()
    func viewDidLoad()
}

@MainActor
internal final class StoredPaymentComponentViewModel: StoredPaymentComponentViewModelProtocol {

    private enum Constants {
        static let cardImageSize = CGSize(width: 80, height: 52)
    }

    // MARK: - Properties

    private let component: PaymentComponent
    private let title: String
    internal let theme: CheckoutTheme
    private let localizationParameters: LocalizationParameters?
    private let dropInFlowManager: DropInFlowManaging
    internal let analyticsProvider: AnyAnalyticsProvider?
    internal let dropInAnalyticsConfiguration: DropInAnalyticsConfiguration
    internal weak var router: StoredPaymentComponentRouting?

    internal var onLoadingStateChange: ((_ isLoading: Bool) -> Void)?

    // MARK: - Initializers

    internal init(
        component: PaymentComponent,
        title: String,
        theme: CheckoutTheme,
        localizationParameters: LocalizationParameters?,
        analyticsProvider: AnyAnalyticsProvider?,
        dropInAnalyticsConfiguration: DropInAnalyticsConfiguration,
        dropInFlowManager: DropInFlowManaging
    ) {
        self.component = component
        self.title = title
        self.theme = theme
        self.localizationParameters = localizationParameters
        self.analyticsProvider = analyticsProvider
        self.dropInAnalyticsConfiguration = dropInAnalyticsConfiguration
        self.dropInFlowManager = dropInFlowManager
    }

    // MARK: - StoredPaymentComponentViewModelProtocol

    internal var cardImageItem: CardImageItem {
        let paymentMethod = component.paymentMethod
        let displayInformation = paymentMethod.displayInformation(using: localizationParameters)
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
        component.paymentMethod.displayInformation(using: localizationParameters).title
    }

    internal var subtitleText: String {
        localizedString(.preselectedPaymentMethodSubtitle, localizationParameters, component.paymentMethod.name)
    }

    internal var submitButtonTitle: String {
        localizedSubmitButtonTitle(
            with: component.context.amount,
            style: .immediate,
            localizationParameters
        )
    }

    internal func submitPayment() {
        switch component.type {
        case .regular, .stored:
            guard let presentableComponent = component as? PresentablePaymentComponent else { return }
            router?.present(paymentComponent: presentableComponent)
        case .initiable:
            startLoading(for: component)
            component.performSubmit()
        }
    }

    internal func viewDidLoad() {
        sendDidLoadEvent()
    }

    internal func cancel() {
        dropInFlowManager.cancel(component: component)
        stopLoading()
        router?.dismiss(completion: nil)
    }

    // MARK: - Private

    private func startLoading(for component: PaymentComponent) {
        onLoadingStateChange?(true)
    }

    private func stopLoading() {
        onLoadingStateChange?(false)
    }

    private func sendDidLoadEvent() {
        var infoEvent = AnalyticsEventInfo(component: AnalyticsConstants.dropInComponentIdentifier, type: .rendered)
        infoEvent.configData = dropInAnalyticsConfiguration
        analyticsProvider?.add(info: infoEvent)
    }
}

// MARK: - PaymentComponentDelegate

extension StoredPaymentComponentViewModel: PaymentComponentDelegate {

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
            stopLoading()
            dropInFlowManager.fail(with: error, from: component)
        }
    }
}

// MARK: - ActionPresenter

extension StoredPaymentComponentViewModel: ActionPresenter {

    internal func present(actionViewController: UIViewController) {
        router?.present(actionViewController: actionViewController) { [weak self] in
            self?.stopLoading()
        }
    }

    internal func didCancel(actionComponent: any ActionComponent) {
        stopLoading()
    }
}
