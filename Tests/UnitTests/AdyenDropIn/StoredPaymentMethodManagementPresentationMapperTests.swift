//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenDropIn
import XCTest

final class StoredPaymentMethodManagementPresentationMapperTests: XCTestCase {

    func test_sections_groupsConcreteStoredCardModelsBeforeOtherMethods() throws {
        let schemeCard = try decode(storedCreditCardDictionary, as: StoredCardPaymentMethod.self)
        var cardTypeDictionary = storedCreditCardDictionary
        cardTypeDictionary["type"] = "card"
        cardTypeDictionary["id"] = "card-type-id"
        let cardTypeCard = try decode(cardTypeDictionary, as: StoredCardPaymentMethod.self)
        let bcmc = try decode(storedBcmcDictionary, as: StoredBCMCPaymentMethod.self)
        let schemeGeneric = try decode(
            [
                "type": "scheme",
                "id": "scheme-generic-id",
                "name": "Scheme generic",
                "supportedShopperInteractions": ["Ecommerce"]
            ],
            as: StoredGenericPaymentMethod.self
        )
        let payPal = try decode(
            [
                "type": "paypal",
                "id": "paypal-id",
                "name": "PayPal",
                "shopperEmail": "shopper@example.com",
                "supportedShopperInteractions": ["Ecommerce"]
            ],
            as: StoredPayPalPaymentMethod.self
        )

        let sections = makeSections(from: [payPal, schemeCard, cardTypeCard, bcmc, schemeGeneric])

        XCTAssertEqual(sections.map(\.kind), [.cards, .other])
        XCTAssertEqual(sections[0].items.map(\.paymentMethod.identifier), [schemeCard.identifier, cardTypeCard.identifier, bcmc.identifier])
        XCTAssertEqual(sections[1].items.map(\.paymentMethod.identifier), [payPal.identifier, schemeGeneric.identifier])
    }

    func test_sections_omitsEmptyGroups() throws {
        let payPal = try decode(
            [
                "type": "paypal",
                "id": "paypal-id",
                "name": "PayPal",
                "shopperEmail": "shopper@example.com",
                "supportedShopperInteractions": ["Ecommerce"]
            ],
            as: StoredPayPalPaymentMethod.self
        )

        let sections = makeSections(from: [payPal])

        XCTAssertEqual(sections.map(\.kind), [.other])
    }

    func test_sections_mapsStoredPaymentMethodPresentations() throws {
        let card = try decode(storedCreditCardDictionary, as: StoredCardPaymentMethod.self)
        let cashAppPay = try decode(
            [
                "type": "cashapp",
                "id": "cash-app-id",
                "name": "Cash App Pay",
                "cashtag": "$shopper",
                "supportedShopperInteractions": ["Ecommerce"]
            ],
            as: StoredCashAppPayPaymentMethod.self
        )
        let payByBank = try decode(
            [
                "type": "paybybank",
                "id": "pay-by-bank-id",
                "name": "Pay by Bank US",
                "label": "Primary checking",
                "supportedShopperInteractions": ["Ecommerce"]
            ],
            as: StoredPayByBankUSPaymentMethod.self
        )
        let payByBankWithoutLabel = try decode(
            [
                "type": "paybybank",
                "id": "pay-by-bank-no-label-id",
                "name": "Pay by Bank US",
                "supportedShopperInteractions": ["Ecommerce"]
            ],
            as: StoredPayByBankUSPaymentMethod.self
        )
        let payTo = try decode(storedPayToDictionary, as: StoredPayToPaymentMethod.self)
        let ach = try decode(storedACHDictionary, as: StoredACHDirectDebitPaymentMethod.self)
        let payPal = try decode(
            [
                "type": "paypal",
                "id": "paypal-id",
                "name": "PayPal",
                "shopperEmail": "shopper@example.com",
                "supportedShopperInteractions": ["Ecommerce"]
            ],
            as: StoredPayPalPaymentMethod.self
        )
        let generic = try decode(
            [
                "type": "custom",
                "id": "generic-id",
                "name": "Generic payment method",
                "supportedShopperInteractions": ["Ecommerce"]
            ],
            as: StoredGenericPaymentMethod.self
        )

        let paymentMethods: [any StoredPaymentMethod] = [
            card,
            cashAppPay,
            payByBank,
            payByBankWithoutLabel,
            payTo,
            ach,
            payPal,
            generic
        ]
        let items = makeSections(from: paymentMethods).flatMap(\.items)
        let itemsByIdentifier = Dictionary(uniqueKeysWithValues: items.map { ($0.paymentMethod.identifier, $0) })

        let securedCardLastFour = String.Adyen.securedString + "1111"
        XCTAssertEqual(itemsByIdentifier[card.identifier]?.title, securedCardLastFour)
        XCTAssertEqual(itemsByIdentifier[card.identifier]?.subtitle, "Expired")
        XCTAssertEqual(itemsByIdentifier[card.identifier]?.subtitleStatus, .warning)

        XCTAssertEqual(itemsByIdentifier[cashAppPay.identifier]?.title, "$shopper")
        XCTAssertEqual(itemsByIdentifier[cashAppPay.identifier]?.subtitle, "Cash App Pay")

        XCTAssertEqual(itemsByIdentifier[payByBank.identifier]?.title, "Primary checking")
        XCTAssertEqual(itemsByIdentifier[payByBank.identifier]?.subtitle, "Pay by Bank US")
        XCTAssertEqual(itemsByIdentifier[payByBankWithoutLabel.identifier]?.title, "Pay by Bank US")
        XCTAssertNil(itemsByIdentifier[payByBankWithoutLabel.identifier]?.subtitle)

        XCTAssertEqual(itemsByIdentifier[payTo.identifier]?.title, "•••••••2311")
        XCTAssertEqual(itemsByIdentifier[payTo.identifier]?.subtitle, "payto")

        let securedACHLastFour = String.Adyen.securedString + "6789"
        XCTAssertEqual(itemsByIdentifier[ach.identifier]?.title, securedACHLastFour)
        XCTAssertEqual(itemsByIdentifier[ach.identifier]?.subtitle, "ACH Direct Debit")

        XCTAssertEqual(itemsByIdentifier[payPal.identifier]?.title, "PayPal")
        XCTAssertEqual(itemsByIdentifier[payPal.identifier]?.subtitle, "shopper@example.com")
        XCTAssertEqual(itemsByIdentifier[generic.identifier]?.title, "Generic payment method")
        XCTAssertNil(itemsByIdentifier[generic.identifier]?.subtitle)
        for paymentMethod in paymentMethods {
            try assertItemCopiesDisplayInformation(
                XCTUnwrap(itemsByIdentifier[paymentMethod.identifier]),
                from: paymentMethod
            )
        }
    }

    func test_sections_mapRemovalActionTitlesUsingOriginalPaymentMethodMetadata() throws {
        let card = try decode(storedCreditCardDictionary, as: StoredCardPaymentMethod.self)
        let bcmc = try decode(storedBcmcDictionary, as: StoredBCMCPaymentMethod.self)
        let ach = try decode(storedACHDictionary, as: StoredACHDirectDebitPaymentMethod.self)
        let payPal = try decode(storedPayPalDictionary, as: StoredPayPalPaymentMethod.self)
        let items = makeSections(from: [card, bcmc, ach, payPal]).flatMap(\.items)

        XCTAssertEqual(
            items.map(\.removalActionTitle),
            [
                "Remove VISA \(String.Adyen.securedString)1111",
                "Remove Maestro \(String.Adyen.securedString)4449",
                "Remove ACH Direct Debit \(String.Adyen.securedString)6789",
                "Remove PayPal"
            ]
        )
    }

    private func assertItemCopiesDisplayInformation(
        _ item: StoredPaymentMethodManagementItem,
        from paymentMethod: any StoredPaymentMethod,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let displayInformation = paymentMethod.displayInformation(using: nil)
        XCTAssertEqual(item.title, displayInformation.title, file: file, line: line)
        XCTAssertEqual(item.subtitle, displayInformation.subtitle, file: file, line: line)
        XCTAssertEqual(item.subtitleStatus, displayInformation.subtitleStatus, file: file, line: line)
        XCTAssertEqual(item.accessibilityLabel, displayInformation.accessibilityLabel, file: file, line: line)
    }

    private func makeSections(from paymentMethods: [any StoredPaymentMethod]) -> [StoredPaymentMethodManagementSection] {
        makeMapper().sections(from: paymentMethods)
    }

    private func makeMapper() -> StoredPaymentMethodManagementPresentationMapper {
        StoredPaymentMethodManagementPresentationMapper(
            localizationParameters: nil,
            logoURLProvider: LogoURLProvider(environment: Dummy.apiContext.environment)
        )
    }

    private func decode<T: StoredPaymentMethod>(_ dictionary: [String: Any], as _: T.Type) throws -> T {
        try AdyenCoder.decode(dictionary)
    }
}
