//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
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
    internal weak var router: GenericPaymentMethodRouting?

    @Published internal var state: State = .idle

    // MARK: - Initializers

    internal init(
        component: PaymentComponent,
        dropInFlowManager: DropInFlowManaging,
        logoUrlProvider: LogoURLProvider
    ) {
        self.component = component
        self.dropInFlowManager = dropInFlowManager
        self.logoUrlProvider = logoUrlProvider

        self.component.delegate = self
    }

    internal var paymentMethodName: String {
        component.paymentMethod.name
    }

    internal var paymentMethodLogoURL: URL {
        let logoName = component.paymentMethod.type.rawValue
        return logoUrlProvider.logoURL(withName: logoName)
    }

    // MARK: - Public

    internal func startPayment() {
        component.performSubmit()
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
        router?.present(actionViewController: actionViewController)
    }

    internal func didCancel(actionComponent: any ActionComponent) {
        state = .idle
    }
}
