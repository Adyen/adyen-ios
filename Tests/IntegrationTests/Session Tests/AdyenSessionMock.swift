//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenSession
@_spi(AdyenInternal) @testable import Adyen

final class AdyenSessionMock: AdyenSessionProtocol {
    var sessionContext: AdyenSession.Context
    var delegate: AdyenSessionDelegate?
    var presentationDelegate: PresentationDelegate?

    // MARK: - AdyenSessionAware
    
    var isSession: Bool = true

    // MARK: - InstallmentConfigurationAware
    
    var installmentConfiguration: InstallmentConfiguration?

    // MARK: - StorePaymentMethodFieldAware
    
    var showStorePaymentMethodField: Bool?

    internal init(
        sessionContext: AdyenSession.Context,
        delegate: AdyenSessionDelegate? = nil,
        presentationDelegate: PresentationDelegate? = nil,
        installmentConfiguration: InstallmentConfiguration? = nil,
        showStorePaymentMethodField: Bool? = true
    ) {
        self.sessionContext = sessionContext
        self.delegate = delegate
        self.presentationDelegate = presentationDelegate
        self.installmentConfiguration = installmentConfiguration
        self.showStorePaymentMethodField = showStorePaymentMethodField
    }
}
