//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenUI
import Foundation

@MainActor
internal class GenericPaymentMethodViewModel: ObservableObject {

    internal enum State {
        case idle
        case loading
    }

    // MARK: - Properties

    private let component: PaymentComponent
    private let dropInFlowManager: DropInFlowManaging
    private let logoUrlProvider: LogoURLProvider
    private let localizationParameters: LocalizationParameters
    internal weak var router: GenericPaymentMethodRouting?

    @Published internal var state: State = .idle

    // MARK: - Initializers

    internal init(
        component: PaymentComponent,
        dropInFlowManager: DropInFlowManaging,
        logoUrlProvider: LogoURLProvider,
        localizationParameters: LocalizationParameters
    ) {
        self.component = component
        self.dropInFlowManager = dropInFlowManager
        self.logoUrlProvider = logoUrlProvider
        self.localizationParameters = localizationParameters

        self.component.delegate = self
    }

    // MARK: - Localization

    internal var title: String {
        component.paymentMethod.name
    }

    internal var description: String {
        localizedString(.checkoutDropinGenericPaymentMethodDescription, localizationParameters)
    }

    internal var progressTitle: String {
        localizedString(.checkoutDropinGenericPaymentMethodProgressTitle, localizationParameters)
    }

    // MARK: - Public

    internal var paymentMethodLogoURL: URL {
        let logoName = component.paymentMethod.type.rawValue
        return logoUrlProvider.logoURL(withName: logoName)
    }

    internal func startPayment() {
        guard state != .loading else { return }
        state = .loading
        component.performSubmit()
    }

    internal func dismiss() {
        router?.dismiss()
    }
}

// MARK: - PaymentComponentDelegate

extension GenericPaymentMethodViewModel: PaymentComponentDelegate {

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
        defer {
            state = .idle
        }

        dropInFlowManager.fail(with: error, from: component)
    }
}

// MARK: - ActionPresenter

extension GenericPaymentMethodViewModel: ActionPresenter {

    internal func present(actionViewController: UIViewController) {
        router?.present(actionViewController: actionViewController) { [weak self] in
            self?.state = .idle
        }
    }

    internal func didCancel(actionComponent: any ActionComponent) {
        state = .idle
    }
}
