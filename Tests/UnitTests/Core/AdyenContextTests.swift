//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) @testable import AdyenCheckout
@testable import AdyenEncryption
@testable import AdyenNetworking
import Testing

struct AdyenContextTests {

    @Test func amountMutability() throws {

        let oneEUR = Amount(value: 1, currencyCode: "EUR")
        let twoEUR = Amount(value: 2, currencyCode: "EUR")

        let apiContext = try APIContext(environment: Environment.test, clientKey: "local_DUMMYKEYFORTESTING")
        let context = AdyenContext(
            apiContext: apiContext,
            amount: oneEUR,
            publicKey: Dummy.publicKey,
            checkoutAttemptId: nil,
            analyticsAPIContext: nil,
            analyticsConfiguration: AnalyticsConfiguration()
        )
        
        #expect(context.amount == oneEUR)
        context.amount = twoEUR
        #expect(context.amount == twoEUR)
    }
    
    @Test func publicInit() {
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: Dummy.amount,
            publicKey: Dummy.publicKey,
            checkoutAttemptId: nil,
            analyticsAPIContext: nil,
            analyticsConfiguration: AnalyticsConfiguration()
        )
        
        #expect(context.amount == Dummy.amount)
        #expect(context.apiContext.clientKey == Dummy.apiContext.clientKey)
    }
    
    @Test func internalInit() {
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: Dummy.amount,
            publicKey: Dummy.publicKey,
            analyticsProvider: AnalyticsProviderMock()
        )
        
        #expect(context.amount == Dummy.amount)
        #expect(context.apiContext.clientKey == Dummy.apiContext.clientKey)
        #expect(context.analyticsProvider != nil)
    }
    
    @Test func initWith_EnvironmentCheckoutAttemptID_shouldCreateAnalyticsProvider() {
        let analyticsApiContext = CheckoutConfiguration.createAnalyticsAPIContext(apiContext: Dummy.apiContext)
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: Dummy.amount,
            publicKey: Dummy.publicKey,
            checkoutAttemptId: AnalyticsProviderMock.testCheckoutAttemptId,
            analyticsAPIContext: analyticsApiContext,
            analyticsConfiguration: AnalyticsConfiguration(isEnabled: true)
        )
        
        #expect(context.analyticsProvider != nil)
    }
    
    @Test func initWithNotProvided_Environment_shouldNotCreateAnalyticsProvider() throws {
        let apiContext = try APIContext(environment: TestEnvironment.test, clientKey: "local_DUMMYKEYFORTESTING")
        let analyticsApiContext = CheckoutConfiguration.createAnalyticsAPIContext(apiContext: Dummy.apiContext)

        let context = AdyenContext(
            apiContext: apiContext,
            amount: Dummy.amount,
            publicKey: Dummy.publicKey,
            checkoutAttemptId: nil,
            analyticsAPIContext: analyticsApiContext,
            analyticsConfiguration: AnalyticsConfiguration(isEnabled: true)
        )
        #expect(context.analyticsProvider == nil)
    }

    @Test func initWithNotProvided_CheckoutAttemptID_shouldNotCreateAnalyticsProvider() throws {
        let apiContext = try APIContext(environment: TestEnvironment.test, clientKey: "local_DUMMYKEYFORTESTING")
        let analyticsApiContext = CheckoutConfiguration.createAnalyticsAPIContext(apiContext: Dummy.apiContext)

        let context = AdyenContext(
            apiContext: apiContext,
            amount: Dummy.amount,
            publicKey: Dummy.publicKey,
            checkoutAttemptId: nil,
            analyticsAPIContext: analyticsApiContext,
            analyticsConfiguration: AnalyticsConfiguration(isEnabled: true)
        )
        #expect(context.analyticsProvider == nil)

    }

    @Test func initWithNotProvided_analyticsDisabled_shouldNotCreateAnalyticsProvider() throws {
        let apiContext = try APIContext(environment: TestEnvironment.test, clientKey: "local_DUMMYKEYFORTESTING")
        let analyticsApiContext = CheckoutConfiguration.createAnalyticsAPIContext(apiContext: Dummy.apiContext)

        let context = AdyenContext(
            apiContext: apiContext,
            amount: Dummy.amount,
            publicKey: Dummy.publicKey,
            checkoutAttemptId: AnalyticsProviderMock.testCheckoutAttemptId,
            analyticsAPIContext: analyticsApiContext,
            analyticsConfiguration: AnalyticsConfiguration(isEnabled: false)
        )

        #expect(context.analyticsProvider == nil)
    }
}

enum TestEnvironment: AnyAPIEnvironment {
    case test
    
    var baseURL: URL {
        URL(string: "test")!
    }
}
