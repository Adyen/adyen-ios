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
    
    struct AnalyticsTestData: CustomTestStringConvertible {
        let attemptID: String?
        let analyticsAPIContext: APIContext?
        let analyticsConfiguration: AnalyticsConfiguration

        var testDescription: String {
            "attemptID: \(attemptID), Context: \(analyticsAPIContext), Config: \(analyticsConfiguration)"
        }

        static var allPermutations: [AnalyticsTestData] {
            let possibleAttemptIds: [String?] = [AnalyticsProviderMock.testCheckoutAttemptId, nil]
            let possibleContexts: [APIContext?] = [Dummy.apiContext, nil]
            let possibleAnalyticsConfigurations: [AnalyticsConfiguration] = [AnalyticsConfiguration(isEnabled: true), AnalyticsConfiguration(isEnabled: false)]

            return possibleAttemptIds.flatMap { id in
                possibleContexts.flatMap { context in
                    possibleAnalyticsConfigurations.map { config in
                        AnalyticsTestData(attemptID: id, analyticsAPIContext: context, analyticsConfiguration: config)
                    }
                }
            }
        }

        /// AnalyticsProvider should not be created when we don't have the checkoutAttemptID available.
        /// But it should be created irrespective of the configuration set by the merchant in AnalyticsConfiguration.
        var expectedToCreateAnalyticsProvider: Bool {
            guard attemptID != nil, analyticsAPIContext != nil else {
                return false
            }
            return true
        }

        /// The EventsAnalyticsProvider(That which is responsible to send info/log/error events) should be created only when it is enabled by the merchant in AnalyticsConfiguration.
        var expectedToCreateEventsAnalyticsProvider: Bool {
            guard attemptID != nil, analyticsAPIContext != nil, analyticsConfiguration.isEnabled else {
                return false
            }
            return true
        }
    }

    @Test(arguments: AnalyticsTestData.allPermutations)
    func creationOfAnalyticsProvider(testData: AnalyticsTestData) throws {
        let apiContext = try APIContext(environment: TestEnvironment.test, clientKey: "local_DUMMYKEYFORTESTING")

        let context = AdyenContext(
            apiContext: apiContext,
            amount: Dummy.amount,
            publicKey: Dummy.publicKey,
            checkoutAttemptId: testData.attemptID,
            analyticsAPIContext: testData.analyticsAPIContext,
            analyticsConfiguration: testData.analyticsConfiguration
        )

        #expect((context.analyticsProvider != nil) == testData.expectedToCreateAnalyticsProvider)
        #expect(((context.analyticsProvider as? AnalyticsProvider)?.eventAnalyticsProvider != nil) == testData.expectedToCreateEventsAnalyticsProvider)
    }
}

enum TestEnvironment: AnyAPIEnvironment {
    case test
    
    var baseURL: URL {
        URL(string: "test")!
    }
}
