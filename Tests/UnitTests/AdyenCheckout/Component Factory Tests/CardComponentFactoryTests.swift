//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
import XCTest

@MainActor
final class CardComponentFactoryTests: XCTestCase {

    private var context: AdyenContext!

    override func setUp() {
        super.setUp()
        context = Dummy.context
    }

    override func tearDown() {
        context = nil
        super.tearDown()
    }

    func test_create_passesConfigurationToComponent() throws {
        let paymentMethod = try XCTUnwrap(createCardPaymentMethod())
        let merchantInstallments = InstallmentConfiguration(
            defaultOptions: InstallmentOptions(maxInstallments: 3)
        )
        let configuration = CardConfiguration()
            .showStorePaymentMethod(false)
            .installmentConfiguration(merchantInstallments)
        let factory = CardComponentFactory<CardPaymentMethod>()

        let component = factory.create(
            with: paymentMethod,
            context: context,
            configuration: configuration,
            callbacks: nil
        )

        XCTAssertFalse(component.configuration.showStorePaymentMethod)
        XCTAssertEqual(component.configuration.installmentConfiguration, merchantInstallments)
    }

    func test_create_withCallbacks_passesThemToComponent() async throws {
        let paymentMethod = try XCTUnwrap(createCardPaymentMethod())
        var receivedBin: String?
        var receivedQuery: String?
        var callbacks = CardCallbacks().onBinChange { receivedBin = $0 }
        callbacks.addressCallbacks = AddressCallbacks(onAddressLookup: { query in
            receivedQuery = query
            return []
        })

        let component = CardComponentFactory<CardPaymentMethod>().create(
            with: paymentMethod,
            context: context,
            configuration: CardConfiguration(),
            callbacks: callbacks
        )
        component.callbacks.onBinChange?("411111")
        _ = await component.callbacks.addressCallbacks?.onAddressLookup("Amsterdam")

        XCTAssertEqual(receivedBin, "411111")
        XCTAssertEqual(receivedQuery, "Amsterdam")
    }

    func test_create_withoutCallbacks_usesEmptyCallbacks() throws {
        let paymentMethod = try XCTUnwrap(createCardPaymentMethod())

        let component = CardComponentFactory<CardPaymentMethod>().create(
            with: paymentMethod,
            context: context,
            configuration: CardConfiguration(),
            callbacks: nil
        )

        XCTAssertNil(component.callbacks.onBinChange)
        XCTAssertNil(component.callbacks.onBinLookup)
        XCTAssertNil(component.callbacks.addressCallbacks)
    }

    func test_callbacks_withCardAndAddressCallbacks_combinesThem() async throws {
        var receivedBin: String?
        var receivedQuery: String?
        let store = AdditionalCallbacksStore([
            CardCallbacks().onBinChange { receivedBin = $0 },
            AddressCallbacks(onAddressLookup: { query in
                receivedQuery = query
                return []
            })
        ])

        let callbacks = try XCTUnwrap(CardComponentFactory<CardPaymentMethod>().callbacks(from: store))
        callbacks.onBinChange?("411111")
        _ = await callbacks.addressCallbacks?.onAddressLookup("Amsterdam")

        XCTAssertEqual(receivedBin, "411111")
        XCTAssertEqual(receivedQuery, "Amsterdam")
    }

    func test_callbacks_withOnlyAddressCallbacks_attachesThemToEmptyCardCallbacks() throws {
        let store = AdditionalCallbacksStore([AddressCallbacks(onAddressLookup: { _ in [] })])

        let callbacks = try XCTUnwrap(CardComponentFactory<CardPaymentMethod>().callbacks(from: store))

        XCTAssertNil(callbacks.onBinChange)
        XCTAssertNil(callbacks.onBinLookup)
        XCTAssertNotNil(callbacks.addressCallbacks)
    }

    func test_callbacks_withoutEntries_returnsEmptyCardCallbacks() throws {
        let callbacks = try XCTUnwrap(CardComponentFactory<CardPaymentMethod>().callbacks(from: AdditionalCallbacksStore()))

        XCTAssertNil(callbacks.onBinChange)
        XCTAssertNil(callbacks.onBinLookup)
        XCTAssertNil(callbacks.addressCallbacks)
    }

    func test_callbacks_withRepeatedEntries_usesLastEntryOfEachType() async throws {
        var receivedBins: [String] = []
        var receivedQueries: [String] = []
        let store = AdditionalCallbacksStore([
            CardCallbacks().onBinChange { receivedBins.append("first-\($0)") },
            AddressCallbacks(onAddressLookup: { query in
                receivedQueries.append("first-\(query)")
                return []
            }),
            CardCallbacks().onBinChange { receivedBins.append("last-\($0)") },
            AddressCallbacks(onAddressLookup: { query in
                receivedQueries.append("last-\(query)")
                return []
            })
        ])

        let callbacks = try XCTUnwrap(CardComponentFactory<CardPaymentMethod>().callbacks(from: store))
        callbacks.onBinChange?("411111")
        _ = await callbacks.addressCallbacks?.onAddressLookup("Amsterdam")

        XCTAssertEqual(receivedBins, ["last-411111"])
        XCTAssertEqual(receivedQueries, ["last-Amsterdam"])
    }

    private func createCardPaymentMethod() -> CardPaymentMethod? {
        let dictionary: [String: Any] = [
            "type": "scheme",
            "name": "Cards",
            "brands": ["mc", "visa"]
        ]
        return try? AdyenCoder.decode(dictionary) as CardPaymentMethod
    }
}
