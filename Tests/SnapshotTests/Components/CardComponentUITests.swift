//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@testable import AdyenComponents

class CardComponentUITests: XCTestCase {
    
    let paymentMethod = CardPaymentMethod(
        type: .bcmc,
        name: "Test name",
        fundingSource: .debit,
        brands: [.accel]
    )
    
    func test_all_fields() throws {

        let configuration = CardComponent.Configuration.extended
        
        let sut = CardComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )
        
        verifyViewControllerImage(matching: sut.viewController, named: "CardComponentUITests.\(#function)")
    }
    
    func test_hidden_cvc() throws {
        
        var configuration = CardComponent.Configuration.minimal
        configuration.showsSecurityCodeField = false
        
        let sut = CardComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )
        
        verifyViewControllerImage(matching: sut.viewController, named: "CardComponentUITests.\(#function)")
    }
    
    func test_billing_address_modes() throws {
        
        var configuration = CardComponent.Configuration.minimal
        
        [CardComponent.AddressFormType.none, .full, .postalCode].forEach { mode in
            configuration.billingAddress.mode = mode
            
            let sut = CardComponent(
                paymentMethod: paymentMethod,
                context: Dummy.context,
                configuration: configuration
            )
            
            verifyViewControllerImage(
                matching: sut.viewController,
                named: "CardComponentUITests.\(#function).\(mode.description)"
            )
        }

    }
}

// MARK: - Convenience

private extension CardComponent.Configuration {
    
    static var minimal: Self {
        var configuration = CardComponent.Configuration()
        configuration.showsHolderNameField = false
        configuration.koreanAuthenticationMode = .hide
        configuration.socialSecurityNumberMode = .hide
        configuration.installmentConfiguration = nil
        return configuration
    }
    
    static var extended: Self {
        var configuration = CardComponent.Configuration()
        configuration.showsHolderNameField = true
        configuration.billingAddress.mode = .full
        configuration.koreanAuthenticationMode = .show
        configuration.socialSecurityNumberMode = .show
        configuration.installmentConfiguration = .init(
            cardBasedOptions: [.bcmc: .init(
                monthValues: [2, 3, 4],
                includesRevolving: true
            )],
            defaultOptions: .init(
                monthValues: [2, 3, 4],
                includesRevolving: true
            ),
            showInstallmentAmount: true
        )
        return configuration
    }
}

private extension CardComponent.AddressFormType {
    
    var description: String {
        switch self {
        case .lookup:
            "lookup"
        case .full:
            "full"
        case .postalCode:
            "postalCode"
        case .none:
            "none"
        }
    }
}
