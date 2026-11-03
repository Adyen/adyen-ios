//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
@testable import AdyenCheckout
import AdyenNetworking
@testable import AdyenUI
import XCTest

@MainActor
final class CheckoutProviderTests: XCTestCase {

    private var publicKeyFetcher: PublicKeyFetcherSpy!
    private var checkoutAttemptIdProvider: CheckoutAttemptIdProviderSpy!
    private var sut: CheckoutProvider!

    override func setUp() {
        super.setUp()
        publicKeyFetcher = PublicKeyFetcherSpy()
        checkoutAttemptIdProvider = CheckoutAttemptIdProviderSpy()
        sut = CheckoutProvider(
            checkoutAttemptIdProvider: checkoutAttemptIdProvider,
            publicKeyProvider: publicKeyFetcher
        )
    }

    override func tearDown() {
        sut = nil
        checkoutAttemptIdProvider = nil
        publicKeyFetcher = nil
        super.tearDown()
    }

    // MARK: - Address lookup validation

    func test_sessionSetup_withAddressLookupAndNoAddressCallbacks_shouldThrowInvalidConfigurationBeforeNetworkCalls() async {
        let error = await setupError {
            try await self.sut.setup(
                with: Self.sessionResponse,
                configuration: self.makeConfiguration(billingAddressMode: .lookup()),
                callbacks: .test()
            )
        }

        XCTAssertEqual(error?.code, .invalidConfiguration)
        XCTAssertEqual(error?.message, "Address lookup requires AddressCallbacks in the checkout callbacks.")
        assertNoNetworkCalls()
    }

    func test_advancedSetup_withAddressLookupAndNoAddressCallbacks_shouldThrowInvalidConfigurationBeforeNetworkCalls() async {
        let error = await setupError {
            try await self.sut.setup(
                with: Self.paymentMethods,
                configuration: self.makeConfiguration(billingAddressMode: .lookup()),
                callbacks: .test()
            )
        }

        XCTAssertEqual(error?.code, .invalidConfiguration)
        assertNoNetworkCalls()
    }

    func test_sessionSetup_withAddressLookupInBCMCConfigurationAndNoAddressCallbacks_shouldThrowInvalidConfiguration() async {
        let configuration = makeConfiguration(
            [.payment(.bcmc): CardConfiguration().billingAddressMode(.lookup())]
        )

        let error = await setupError {
            try await self.sut.setup(with: Self.sessionResponse, configuration: configuration, callbacks: .test())
        }

        XCTAssertEqual(error?.code, .invalidConfiguration)
        assertNoNetworkCalls()
    }

    func test_sessionSetup_withAddressLookupAndAddressCallbacks_shouldContinueToContextSetup() async {
        let callbacks = CheckoutCallbacks(onComplete: { _ in }, onFailure: { _ in }) {
            AddressCallbacks(onAddressLookup: { _ in [] })
        }

        let error = await setupError {
            try await self.sut.setup(
                with: Self.sessionResponse,
                configuration: self.makeConfiguration(billingAddressMode: .lookup()),
                callbacks: callbacks
            )
        }

        XCTAssertEqual(error?.code, .httpError)
        XCTAssertEqual(publicKeyFetcher.fetchCount, 1)
    }

    func test_advancedSetup_withAddressLookupAndAddressCallbacks_shouldSucceed() async throws {
        publicKeyFetcher.result = .success("public-key")
        let callbacks = AdvancedCheckoutCallbacks(
            onSubmit: { _ in .retry() },
            onAdditionalDetails: { _ in .completion(resultCode: "") },
            onComplete: { _ in },
            onFailure: { _ in }
        ) {
            AddressCallbacks(onAddressLookup: { _ in [] })
        }

        let core = try await sut.setup(
            with: Self.paymentMethods,
            configuration: makeConfiguration(billingAddressMode: .lookup()),
            callbacks: callbacks
        )

        let checkoutCore = try XCTUnwrap(core as? CheckoutCore)
        XCTAssertNotNil(checkoutCore.additionalCallbacks.callbacks(of: AddressCallbacks.self))
        XCTAssertEqual(publicKeyFetcher.fetchCount, 1)
    }

    func test_sessionSetup_withoutAddressLookup_shouldNotRequireAddressCallbacks() async {
        let modes: [BillingAddressMode] = [.none, .postalCode(), .full()]

        for mode in modes {
            publicKeyFetcher = PublicKeyFetcherSpy()
            sut = CheckoutProvider(checkoutAttemptIdProvider: checkoutAttemptIdProvider, publicKeyProvider: publicKeyFetcher)

            let error = await setupError {
                try await self.sut.setup(
                    with: Self.sessionResponse,
                    configuration: self.makeConfiguration(billingAddressMode: mode),
                    callbacks: .test()
                )
            }

            XCTAssertEqual(error?.code, .httpError, "\(mode)")
            XCTAssertEqual(publicKeyFetcher.fetchCount, 1, "\(mode)")
        }
    }

    func test_sessionSetup_withAddressCallbacksAndNoAddressLookup_shouldContinueToContextSetup() async {
        let callbacks = CheckoutCallbacks(onComplete: { _ in }, onFailure: { _ in }) {
            AddressCallbacks(onAddressLookup: { _ in [] })
        }

        let error = await setupError {
            try await self.sut.setup(
                with: Self.sessionResponse,
                configuration: self.makeConfiguration(billingAddressMode: .full()),
                callbacks: callbacks
            )
        }

        XCTAssertEqual(error?.code, .httpError)
        XCTAssertEqual(publicKeyFetcher.fetchCount, 1)
    }

    func test_actionOnlySetup_withAddressLookup_shouldNotValidateAddressCallbacks() async {
        let error = await setupError {
            try await self.sut.setup(
                configuration: self.makeConfiguration(billingAddressMode: .lookup()),
                callbacks: .test()
            )
        }

        XCTAssertEqual(error?.code, .httpError)
        XCTAssertEqual(publicKeyFetcher.fetchCount, 1)
    }

    // MARK: - Helpers

    private static let sessionResponse = SessionResponse(id: "sessionId", sessionData: "sessionData")

    private static let paymentMethods = PaymentMethods(regular: [], stored: [])

    private func makeConfiguration(billingAddressMode: BillingAddressMode) -> CheckoutConfiguration {
        makeConfiguration([.payment(.scheme): CardConfiguration().billingAddressMode(billingAddressMode)])
    }

    private func makeConfiguration(
        _ configurations: [CheckoutComponentType: CheckoutComponentConfiguration]
    ) -> CheckoutConfiguration {
        CheckoutConfiguration(
            apiContext: Dummy.apiContext,
            analyticsApiContext: nil,
            analyticsConfiguration: .init(),
            configurations: configurations
        )
    }

    private func setupError(_ setup: () async throws -> CheckoutCoreProtocol) async -> CheckoutError? {
        do {
            _ = try await setup()
            XCTFail("Expected setup to throw")
            return nil
        } catch {
            return error as? CheckoutError
        }
    }

    private func assertNoNetworkCalls(file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(publicKeyFetcher.fetchCount, 0, file: file, line: line)
        XCTAssertEqual(checkoutAttemptIdProvider.fetchCount, 0, file: file, line: line)
    }
}

private final class PublicKeyFetcherSpy: PublicKeyFetching {

    var result: Result<String, Error> = .failure(TestError())
    private(set) var fetchCount = 0

    func fetchPublicKey(
        apiClient: APIClientKeyRequestProtocol,
        clientKey: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        fetchCount += 1
        completion(result)
    }

    func fetchPublicKey(apiClient: APIClientKeyRequestProtocol, clientKey: String) async throws -> String {
        fetchCount += 1
        return try result.get()
    }
}

private final class CheckoutAttemptIdProviderSpy: CheckoutAttemptIdProviding {

    private(set) var fetchCount = 0

    func fetchCheckoutAttemptId(with apiClient: AsyncAPIClientProtocol?) async -> String? {
        fetchCount += 1
        return nil
    }
}
