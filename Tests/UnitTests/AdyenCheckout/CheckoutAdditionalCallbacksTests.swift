//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
@testable import AdyenCheckout
@testable import AdyenDropIn
@testable import AdyenSession
@_spi(AdyenInternal) @testable import AdyenUI
import UIKit
import XCTest

@MainActor
final class CheckoutAdditionalCallbacksTests: XCTestCase {

    func test_additionalCallbacks_whenOmitted_shouldProvideNoAdditionalCallbacks() {
        let callbacks = CheckoutCallbacks(onComplete: { _ in }, onFailure: { _ in })
        let store = AdditionalCallbacksStore(callbacks.additionalCallbacks)

        XCTAssertNil(store.callbacks(of: CardCallbacks.self))
        XCTAssertNil(store.callbacks(of: AddressCallbacks.self))
    }

    func test_additionalCallbacks_withEmptyBlock_shouldProvideNoAdditionalCallbacks() {
        let callbacks = CheckoutCallbacks(onComplete: { _ in }, onFailure: { _ in }) {}

        XCTAssertNil(AdditionalCallbacksStore(callbacks.additionalCallbacks).callbacks(of: CardCallbacks.self))
    }

    func test_additionalCallbacks_whenCreatingMultipleComponents_shouldEvaluateTheBlockOnce() throws {
        var evaluationCount = 0
        var receivedBins: [String] = []
        func makeCallbacks() -> CardCallbacks {
            evaluationCount += 1
            return CardCallbacks().onBinChange { receivedBins.append($0) }
        }
        let callbacks = CheckoutCallbacks(onComplete: { _ in }, onFailure: { _ in }) {
            makeCallbacks()
        }
        let core = try makeCore(additionalCallbacks: AdditionalCallbacksStore(callbacks.additionalCallbacks))

        for bin in ["411111", "555555"] {
            let component = try core.createPaymentComponent(for: .scheme)
            let card = try XCTUnwrap(component.paymentComponent as? CardComponent)
            card.didChange(bin: bin)
        }

        XCTAssertEqual(evaluationCount, 1)
        XCTAssertEqual(receivedBins, ["411111", "555555"])
    }

    func test_additionalCallbacks_withConditionalEntries_shouldIncludeOnlySelectedBranches() {
        for enabled in [false, true] {
            var events: [String] = []
            let callbacks = CheckoutCallbacks(onComplete: { _ in }, onFailure: { _ in }) {
                if enabled {
                    CardCallbacks().onBinChange { _ in events.append("included") }
                }
                if enabled {
                    AddressCallbacks(onAddressLookup: { _ in [] })
                } else {
                    CardCallbacks().onBinChange { _ in events.append("alternative") }
                    AddressCallbacks(onAddressLookup: { _ in [] })
                }
            }
            let store = AdditionalCallbacksStore(callbacks.additionalCallbacks)

            store.callbacks(of: CardCallbacks.self)?.onBinChange?("411111")

            XCTAssertEqual(events, [enabled ? "included" : "alternative"])
            XCTAssertNotNil(store.callbacks(of: AddressCallbacks.self))
        }
    }

    func test_advancedAdditionalCallbacks_withConditionalEntries_shouldResolveAdvancedCallbacks() {
        for enabled in [false, true] {
            let callbacks = AdvancedCheckoutCallbacks(
                onSubmit: { _ in .completion(resultCode: "Authorised") },
                onAdditionalDetails: { _ in .completion(resultCode: "Authorised") },
                onComplete: { _ in },
                onFailure: { _ in }
            ) {
                if enabled {
                    AdvancedCallbacksStub(value: "included")
                } else {
                    AdvancedCallbacksStub(value: "alternative")
                }
                if enabled {
                    CardCallbacks()
                    AddressCallbacks(onAddressLookup: { _ in [] })
                }
            }
            let store = AdditionalCallbacksStore(callbacks.additionalCallbacks)

            XCTAssertEqual(store.callbacks(of: AdvancedCallbacksStub.self)?.value, enabled ? "included" : "alternative")
            XCTAssertEqual(store.callbacks(of: CardCallbacks.self) != nil, enabled)
            XCTAssertEqual(store.callbacks(of: AddressCallbacks.self) != nil, enabled)
        }
    }

    func test_additionalCallbacks_withDuplicateTypes_shouldKeepOnlyTheLastWholeValue() {
        var events: [String] = []
        let callbacks = CheckoutCallbacks(onComplete: { _ in }, onFailure: { _ in }) {
            CardCallbacks()
                .onBinChange { _ in events.append("first BIN") }
                .onBinLookup { _ in events.append("first lookup") }
            AddressCallbacks(onAddressLookup: { _ in [] })
            CardCallbacks().onBinChange { _ in events.append("last BIN") }
        }
        let store = AdditionalCallbacksStore(callbacks.additionalCallbacks)
        let card = store.callbacks(of: CardCallbacks.self)

        card?.onBinChange?("411111")
        card?.onBinLookup?(BinLookupData(issuingCountryCode: "NL", brands: []))

        XCTAssertEqual(events, ["last BIN"])
        XCTAssertNotNil(store.callbacks(of: AddressCallbacks.self))
    }

    func test_advancedAdditionalCallbacks_withDuplicateTypes_shouldKeepTheLastValue() {
        let callbacks = AdvancedCheckoutCallbacks(
            onSubmit: { _ in .completion(resultCode: "Authorised") },
            onAdditionalDetails: { _ in .completion(resultCode: "Authorised") },
            onComplete: { _ in },
            onFailure: { _ in }
        ) {
            AdvancedCallbacksStub(value: "first")
            AdvancedCallbacksStub(value: "last")
        }

        XCTAssertEqual(AdditionalCallbacksStore(callbacks.additionalCallbacks).callbacks(of: AdvancedCallbacksStub.self)?.value, "last")
    }

    func test_cardCallbacks_withModifiers_shouldPreserveIndependentCopies() {
        var events: [String] = []
        let original = CardCallbacks()
        let first = original.onBinChange { _ in events.append("first") }
        let second = first.onBinChange { _ in events.append("second") }

        original.onBinChange?("411111")
        first.onBinChange?("411111")
        second.onBinChange?("411111")

        XCTAssertEqual(events, ["first", "second"])
    }

    func test_addressCallbacks_withModifiers_shouldPreserveLookupAndIndependentCopies() async throws {
        let result = AddressLookupResult(identifier: "address", postalAddress: PostalAddress(city: "Amsterdam"))
        var receivedQueries: [String] = []
        let original = AddressCallbacks(onAddressLookup: { query in
            receivedQueries.append(query)
            return [result]
        })
        let first = original.onAddressSelected { _ in PostalAddress(city: "London") }
        let second = first.onAddressSelected { _ in PostalAddress(city: "Paris") }

        let results = await second.onAddressLookup("search")
        let firstAddress = try await first.onAddressSelected?(result)
        let secondAddress = try await second.onAddressSelected?(result)

        XCTAssertEqual(receivedQueries, ["search"])
        XCTAssertEqual(results.map(\.identifier), ["address"])
        XCTAssertEqual(firstAddress?.city, "London")
        XCTAssertEqual(secondAddress?.city, "Paris")
        XCTAssertNil(original.onAddressSelected)
    }

    func test_additionalCallbacksStore_withDifferentConcreteTypes_shouldResolveEachTypeIndependently() {
        let store = AdditionalCallbacksStore([
            AdvancedCallbacksStub(value: "advanced"),
            SessionCallbacksStub(value: "default")
        ])

        XCTAssertEqual(store.callbacks(of: AdvancedCallbacksStub.self)?.value, "advanced")
        XCTAssertEqual(store.callbacks(of: SessionCallbacksStub.self)?.value, "default")
        XCTAssertNil(store.callbacks(of: CardCallbacks.self))
    }

    func test_checkoutSetup_withSession_shouldForwardTheAdditionalCallbacks() async throws {
        let provider = CheckoutProviderMock()
        provider.setupWithSessionResult = try .success(makeCore())
        var receivedBin: String?
        let callbacks = CheckoutCallbacks(onComplete: { _ in }, onFailure: { _ in }) {
            CardCallbacks().onBinChange { receivedBin = $0 }
        }

        _ = try await Checkout.setup(
            with: SessionResponse(id: "session", sessionData: "data"),
            configuration: configuration,
            callbacks: callbacks,
            provider: provider
        )
        let forwarded = try XCTUnwrap(provider.sessionCallbacks)
        AdditionalCallbacksStore(forwarded.additionalCallbacks).callbacks(of: CardCallbacks.self)?.onBinChange?("411111")

        XCTAssertEqual(receivedBin, "411111")
    }

    func test_checkoutSetup_withAdvancedFlow_shouldForwardTheAdditionalCallbacks() async throws {
        let provider = CheckoutProviderMock()
        let core = try makeCore()
        provider.setupWithPaymentMethodsResult = .success(core)
        let callbacks = AdvancedCheckoutCallbacks(
            onSubmit: { _ in .completion(resultCode: "Authorised") },
            onAdditionalDetails: { _ in .completion(resultCode: "Authorised") },
            onComplete: { _ in },
            onFailure: { _ in }
        ) {
            AdvancedCallbacksStub(value: "forwarded")
        }

        _ = try await Checkout.setup(
            with: XCTUnwrap(core.paymentMethods),
            configuration: configuration,
            callbacks: callbacks,
            provider: provider
        )
        let forwarded = try XCTUnwrap(provider.advancedCallbacks)

        XCTAssertEqual(AdditionalCallbacksStore(forwarded.additionalCallbacks).callbacks(of: AdvancedCallbacksStub.self)?.value, "forwarded")
    }

    func test_createPaymentComponent_shouldDeliverCardAndAddressCallbacks() async throws {
        var receivedBin: String?
        var receivedQuery: String?
        let core = try makeCore(additionalCallbacks: AdditionalCallbacksStore([
            CardCallbacks().onBinChange { receivedBin = $0 },
            AddressCallbacks(onAddressLookup: { query in
                receivedQuery = query
                return []
            })
        ]))
        let facade = try core.createPaymentComponent(for: .scheme)
        let card = try XCTUnwrap(facade.paymentComponent as? CardComponent)

        card.didChange(bin: "411111")
        _ = await card.addressCallbacks?.onAddressLookup("Amsterdam")

        XCTAssertEqual(receivedBin, "411111")
        XCTAssertEqual(receivedQuery, "Amsterdam")
    }

    func test_createDropIn_shouldDeliverCardAndAddressCallbacksToItsCard() async throws {
        var receivedBin: String?
        var receivedQuery: String?
        let core = try makeCore(additionalCallbacks: AdditionalCallbacksStore([
            CardCallbacks().onBinChange { receivedBin = $0 },
            AddressCallbacks(onAddressLookup: { query in
                receivedQuery = query
                return []
            })
        ]))
        let dropIn = try core.createDropIn().dropInComponent
        let navigation = try XCTUnwrap(dropIn.viewController as? UINavigationController)
        let container = try XCTUnwrap(navigation.viewControllers.first as? ComponentContainerViewController)
        let secured = try XCTUnwrap(container.componentViewController as? SecuredViewController<CardViewController>)
        let card = try XCTUnwrap(secured.childViewController.delegate as? CardComponent)

        card.didChange(bin: "555555")
        _ = await card.addressCallbacks?.onAddressLookup("London")

        XCTAssertEqual(receivedBin, "555555")
        XCTAssertEqual(receivedQuery, "London")
    }

    private var configuration: CheckoutConfiguration {
        CheckoutConfiguration(apiContext: Dummy.apiContext, analyticsApiContext: nil, analyticsConfiguration: .init())
    }

    private func makeCore(additionalCallbacks: AdditionalCallbacksStore = .init()) throws -> CheckoutCore {
        let paymentMethods: PaymentMethods = try AdyenCoder.decode(["paymentMethods": [creditCardDictionary]])
        let callbacks = AdvancedCheckoutCallbacks.test()
        return CheckoutCore(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: Dummy.context,
            resultCallbacks: callbacks,
            callbackHandler: AdvancedCallbackHandler(callbacks: callbacks),
            additionalCallbacks: additionalCallbacks
        )
    }
}

private struct AdvancedCallbacksStub: AdvancedCheckoutAdditionalCallbacks {
    let value: String
}

private struct SessionCallbacksStub: CheckoutAdditionalCallbacks {
    let value: String
}
