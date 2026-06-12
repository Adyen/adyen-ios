//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

// File: Tests/UnitTests/Core/PaymentComponentFactoryProtocolTests.swift

//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

@MainActor
final class PaymentComponentFactoryProtocolTests: XCTestCase {
    
    // MARK: - Mock Types for Testing
    
    struct MockPaymentMethod: PaymentMethod {
        
        var type: PaymentMethodType {
            .other("mock")
        }

        var name: String {
            "Mock Payment Method"
        }
        
        func encode(to encoder: Encoder) throws {}
        init(from decoder: Decoder) throws {}
        init() {}
    }
    
    struct MockConfiguration {
        var value: String = "default"
        var showsSubmitButton: Bool = true
    }
    
    class MockComponent: PaymentComponent, PresentableComponent {

        // PaymentComponent requirements
        var delegate: PaymentComponentDelegate?
        let paymentMethod: PaymentMethod

        /// PresentableComponent requirement
        var viewController: UIViewController {
            UIViewController()
        }

        /// Component requirements (via AdyenContextAware)
        let context: AdyenContext

        /// PartialPaymentOrderAware requirements
        var order: PartialPaymentOrder?

        /// Custom property to verify configuration
        let configValue: String

        init(paymentMethod: PaymentMethod, context: AdyenContext, configuration: MockConfiguration) {
            self.paymentMethod = paymentMethod
            self.context = context
            self.configValue = configuration.value
            self.order = nil
        }

        // MARK: - submit

        var submitCallsCount = 0
        var submitCalled: Bool {
            submitCallsCount > 0
        }

        var submitClosure: (() -> Void)?

        func performSubmit() {
            submitCallsCount += 1
            submitClosure?()
        }
    }
    
    struct MockFactory: PaymentComponentFactory {
        typealias Configuration = MockConfiguration
        typealias Method = MockPaymentMethod
        typealias Component = MockComponent
        
        func defaultConfiguration() -> MockConfiguration {
            MockConfiguration(value: "factory_default", showsSubmitButton: true)
        }
        
        func create(
            with paymentMethod: MockPaymentMethod,
            context: AdyenContext,
            configuration: MockConfiguration
        ) -> MockComponent {
            MockComponent(
                paymentMethod: paymentMethod,
                context: context,
                configuration: configuration
            )
        }
    }
    
    // MARK: - Protocol Conformance Tests
    
    func testMockFactory_ConformsToProtocol() {
        // Given
        let factory = MockFactory()
        
        // Then
        XCTAssertNotNil(factory as any PaymentComponentFactory)
    }
    
    func testMockFactory_ProvidesDefaultConfiguration() {
        // Given
        let factory = MockFactory()
        
        // When
        let config = factory.defaultConfiguration()
        
        // Then
        XCTAssertEqual(config.value, "factory_default")
        XCTAssertTrue(config.showsSubmitButton)
    }
    
    func testMockFactory_CreatesComponent() {
        // Given
        let factory = MockFactory()
        let paymentMethod = MockPaymentMethod()
        let context = Dummy.context
        let configuration = MockConfiguration(value: "test", showsSubmitButton: false)
        
        // When
        let component = factory.create(
            with: paymentMethod,
            context: context,
            configuration: configuration
        )
        
        // Then
        XCTAssertEqual(component.paymentMethod.type, paymentMethod.type)
        XCTAssertEqual(component.configValue, "test")
        XCTAssertEqual(component.context.apiContext.clientKey, context.apiContext.clientKey)
    }
    
    func testMockFactory_AssociatedTypesAreCorrect() {
        // Given
        let factory = MockFactory()
        
        // When
        let config = factory.defaultConfiguration()
        let paymentMethod = MockPaymentMethod()
        let component = factory.create(
            with: paymentMethod,
            context: Dummy.context,
            configuration: config
        )
        
        // Then - Verify through properties
        XCTAssertEqual(config.value, "factory_default")
        XCTAssertEqual(paymentMethod.type, .other("mock"))
        XCTAssertEqual(component.paymentMethod.type, paymentMethod.type)
        XCTAssertEqual(component.configValue, "factory_default")
    }
    
    func testMockFactory_UsesProvidedConfiguration() {
        // Given
        let factory = MockFactory()
        let paymentMethod = MockPaymentMethod()
        let customConfig = MockConfiguration(value: "custom_value", showsSubmitButton: false)
        
        // When
        let component = factory.create(
            with: paymentMethod,
            context: Dummy.context,
            configuration: customConfig
        )
        
        // Then - Component should use the provided configuration
        XCTAssertEqual(component.configValue, "custom_value")
    }
    
    func testMockFactory_PreservesPaymentMethod() {
        // Given
        let factory = MockFactory()
        let paymentMethod = MockPaymentMethod()
        let config = factory.defaultConfiguration()
        
        // When
        let component = factory.create(
            with: paymentMethod,
            context: Dummy.context,
            configuration: config
        )
        
        // Then
        XCTAssertEqual(component.paymentMethod.type, paymentMethod.type)
        XCTAssertEqual(component.paymentMethod.name, paymentMethod.name)
    }
    
    func testMockFactory_PreservesContext() {
        // Given
        let factory = MockFactory()
        let paymentMethod = MockPaymentMethod()
        let customAmount = Amount(value: 1234, currencyCode: "GBP")
        let customContext = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: customAmount,
            publicKey: Dummy.publicKey,
            analyticsProvider: AnalyticsProviderMock()
        )
        let config = factory.defaultConfiguration()
        
        // When
        let component = factory.create(
            with: paymentMethod,
            context: customContext,
            configuration: config
        )
        
        // Then
        XCTAssertEqual(component.context.amount?.value, 1234)
        XCTAssertEqual(component.context.amount?.currencyCode, "GBP")
    }
    
    func testMockFactory_MultipleComponentsAreIndependent() {
        // Given
        let factory = MockFactory()
        let paymentMethod1 = MockPaymentMethod()
        let paymentMethod2 = MockPaymentMethod()
        let config1 = MockConfiguration(value: "config1", showsSubmitButton: true)
        let config2 = MockConfiguration(value: "config2", showsSubmitButton: false)
        
        // When
        let component1 = factory.create(with: paymentMethod1, context: Dummy.context, configuration: config1)
        let component2 = factory.create(with: paymentMethod2, context: Dummy.context, configuration: config2)
        
        // Then - Components should be independent
        XCTAssertEqual(component1.configValue, "config1")
        XCTAssertEqual(component2.configValue, "config2")
        XCTAssertNotIdentical(component1, component2)
    }
    
    func testMockFactory_ComponentConformsToPaymentComponent() {
        // Given
        let factory = MockFactory()
        let paymentMethod = MockPaymentMethod()
        let config = factory.defaultConfiguration()
        
        // When
        let component = factory.create(
            with: paymentMethod,
            context: Dummy.context,
            configuration: config
        )
        
        // Then - Verify component conforms to PaymentComponent
        XCTAssertNotNil(component as PaymentComponent)
        XCTAssertNotNil(component.context)
        XCTAssertNotNil(component.paymentMethod)
    }
    
    func testMockFactory_DefaultConfigurationIsConsistent() {
        // Given
        let factory = MockFactory()
        
        // When
        let config1 = factory.defaultConfiguration()
        let config2 = factory.defaultConfiguration()
        
        // Then - Default configurations should have same values
        XCTAssertEqual(config1.value, config2.value)
        XCTAssertEqual(config1.showsSubmitButton, config2.showsSubmitButton)
    }
}
