//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenActions
@testable import AdyenCard
@testable import AdyenDropIn
@testable import AdyenEncryption
@_spi(AdyenInternal) @testable import AdyenUI

import Testing
import UIKit

@MainActor
struct PreselectedPaymentMethodIntegrationTests {
    // MARK: - UI Display Tests

    @Test("What is shown in the UI for some stored types", arguments: TestDataStoredPaymentType.allCases)
    func componentIsPreSelected_validateWhatIsDisplayed(testDataPaymentType: TestDataStoredPaymentType) throws {
        // When paymentType is loaded
        let sut = SUT(type: testDataPaymentType)

        // Expected in the UI
        try #expect(sut.primaryTitleText == testDataPaymentType.expectedTitle, "Card number")
        try #expect(sut.subTitleText == testDataPaymentType.expectedSubTitleText, "Use payment.method to pay amount")
        try #expect(sut.primaryButtonText == testDataPaymentType.primaryButtonText, "Pay amount")
        try #expect(sut.secondaryButtonText == testDataPaymentType.secondaryButtonText, "Other Payment methods")
    }
    
    // MARK: - Primary Button (Pay) Tests
    
    // @Test("Tapping primary button triggers submit flow via dropInFlowManager")
    func primaryButtonTapped_triggersSubmitFlow() async throws {
        // Given
        let sut = SUT(type: .visa)
        
        // When - simulate primary button tap
        try sut.tapPrimaryButton()

        try await Task.sleep(for: .milliseconds(50))
        // Then - verify dropInFlowManager.submit was called
        #expect(sut.dropInFlowManagerMock.submitFromActionPresenterCalled == true)
    }
    
    // MARK: - Setup of the system under test

    @MainActor
    struct SUT {
        let router: Router

        let dropInFlowManagerMock = DropInFlowManagingMock()
        let paymentMethodListAssemblerMock = PaymentMethodListAssemblerProtocolMock()
        let componentContainerAssemblerMock = ComponentContainerAssemblerProtocolMock()

        init(type: TestDataStoredPaymentType) {
            let assembler = PreselectedPaymentMethodAssembler(
                paymentMethodListAssembler: paymentMethodListAssemblerMock,
                componentContainerAssembler: componentContainerAssemblerMock,
                configuration: .init(),
                dropInFlowManager: dropInFlowManagerMock,
                partialPaymentDelegate: nil
            )

            router = assembler.resolvePreselectedPaymentMethodRouter(
                delegate: nil,
                component: type.paymentComponent,
                title: "Test Title"
            )
            
            _ = router.rootViewController.loadViewIfNeeded()

        }

        // MARK: - Readable UI accessors

        var primaryTitleText: String {
            get throws {
                let titleLabel = try #require(router.rootViewController.view.findView(by: "title") as? UILabel)
                return try #require(titleLabel.text)
            }
        }

        var subTitleText: String {
            get throws {
                let secondaryTitleLabel = try #require(router.rootViewController.view.findView(by: "subTitle") as? UILabel)
                return try #require(secondaryTitleLabel.text)
            }
        }

        var primaryButtonText: String {
            get throws {
                let button = try primaryButton()
                return try #require(button.title)
            }
        }

        var secondaryButtonText: String {
            get throws {
                let button = try secondaryButton()
                return try #require(button.title)
            }
        }
        
        // MARK: - UI elements
        
        func primaryButton() throws -> FormButton {
            try #require(
                router.rootViewController.view.findView(by: "primaryButton") as? FormButton,
                "Cannot find primaryButton - Check if the element exists in the view."
            )
        }
        
        func secondaryButton() throws -> FormButton {
            try #require(
                router.rootViewController.view.findView(by: "secondaryButton") as? FormButton,
                "Cannot find secondaryButton - Check if the element exists in the view."
            )
        }
        
        // MARK: - Interactions
        
        func tapPrimaryButton() throws {
            let button = try primaryButton()
            button.sendActions(for: .touchUpInside)
        }
        
        func tapSecondaryButton() throws {
            let button = try secondaryButton()
            button.sendActions(for: .touchUpInside)
        }
        
        func tapCancel() {
            let cancelButton = router.rootViewController.navigationItem.leftBarButtonItem
            _ = cancelButton?.target?.perform(cancelButton?.action)
        }
        
        // MARK: - Test wiring helpers
        
        func setPaymentMethodListRouter(_ router: Router) {
            paymentMethodListAssemblerMock.resolvePaymentMethodListRouterDelegateReturnValue = router
        }

    }

    // MARK: - Test data
    
    enum TestDataStoredPaymentType: CaseIterable {
        case visa
        case bcmc

        var paymentComponent: PaymentComponent {
            switch self {
            case .visa:
                let storedCardPaymentMethod = try! AdyenCoder.decode(storedCreditCardDictionary) as StoredCardPaymentMethod
                return StoredCardComponent(
                    storedCardPaymentMethod: storedCardPaymentMethod,
                    context: Dummy.context
                )
            case .bcmc:
                let paymentMethod = try! AdyenCoder.decode(storedBcmcDictionary) as StoredBCMCPaymentMethod
                return StoredPaymentMethodComponent(
                    paymentMethod: paymentMethod,
                    context: Dummy.context
                )
            }
        }

        var expectedTitle: String {
            switch self {
            case .visa: "•••• 1111"
            case .bcmc: "•••• 4449"
            }
        }

        var expectedSubTitleText: String {
            switch self {
            case .visa: "Use VISA to pay €1.00"
            case .bcmc: "Use Maestro to pay €1.00"
            }
        }

        var primaryButtonText: String {
            "Pay €1.00"
        }

        var secondaryButtonText: String {
            "Other payment options"
        }
    }
}

// MARK: - Mocks

internal class PaymentMethodListAssemblerProtocolMock: PaymentMethodListAssemblerProtocol {

    var resolvePaymentMethodListRouterDelegateCallsCount = 0
    var resolvePaymentMethodListRouterDelegateCalled: Bool {
        resolvePaymentMethodListRouterDelegateCallsCount > 0
    }
    
    var resolvePaymentMethodListRouterDelegateReceivedDelegate: PaymentMethodListRouterListener?

    var resolvePaymentMethodListRouterDelegateReturnValue: Router!
    var resolvePaymentMethodListRouterDelegateClosure: ((PaymentMethodListRouterListener?) -> Router)?

    func resolvePaymentMethodListRouter(delegate: PaymentMethodListRouterListener?) -> Router {
        resolvePaymentMethodListRouterDelegateCallsCount += 1
        resolvePaymentMethodListRouterDelegateReceivedDelegate = delegate
        if let resolvePaymentMethodListRouterDelegateClosure {
            return resolvePaymentMethodListRouterDelegateClosure(delegate)
        } else {
            return resolvePaymentMethodListRouterDelegateReturnValue
        }
    }
}
