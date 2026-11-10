//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Combine
import Foundation
import UIKit

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
    @Published internal private(set) var isPaymentInProgress = false
    private var cancellables = Set<AnyCancellable>()

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
        observePaymentProgress()
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

    /// Locks the navigation from the moment the payment starts, before Drop-in reports it in progress, until the attempt ends.
    internal var isNavigationLocked: AnyPublisher<Bool, Never> {
        $state
            .combineLatest($isPaymentInProgress)
            .map { state, isPaymentInProgress in state == .loading || isPaymentInProgress }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    // MARK: - Private

    private func observePaymentProgress() {
        dropInFlowManager.paymentInProgressPublisher
            .removeDuplicates()
            .sink { [weak self] isPaymentInProgress in
                guard let self else { return }
                if self.isPaymentInProgress, !isPaymentInProgress {
                    state = .idle
                }
                self.isPaymentInProgress = isPaymentInProgress
            }
            .store(in: &cancellables)
    }
}

// MARK: - PaymentComponentDelegate

extension GenericPaymentMethodViewModel: PaymentComponentDelegate {

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

        dropInFlowManager.fail(with: error, from: component)
    }
}
