//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard
import XCTest

class FormCardNumberItemTests: XCTestCase {

    var apiClient: APIClientMock!
    var publicKeyProvider: PublicKeyProviderMock!
    let supportedCardTypes: [CardType] = [.visa, .masterCard, .americanExpress, .chinaUnionPay, .maestro]
    var cardTypeProvider: CardTypeProvider!

    override func setUp() {
        apiClient = APIClientMock()
        publicKeyProvider = PublicKeyProviderMock()
        cardTypeProvider = CardTypeProvider(cardPublicKeyProvider: publicKeyProvider,
                                            apiClient: apiClient)
    }

    override func tearDown() {
        apiClient = nil
        publicKeyProvider = nil
        cardTypeProvider = nil
    }

    func testInternalBinLookup() {
        let item = FormCardNumberItem(supportedCardTypes: supportedCardTypes, environment: .test)
        XCTAssertEqual(item.cardTypeLogos.count, 5)
        
        let visa = item.cardTypeLogos[0]
        let mc = item.cardTypeLogos[1]
        let amex = item.cardTypeLogos[2]
        let cup = item.cardTypeLogos[3]
        let maestro = item.cardTypeLogos[4]
        
        // Initially, all card type logos should be visible.
        XCTAssertEqual(visa.isHidden, false)
        XCTAssertEqual(mc.isHidden, false)
        XCTAssertEqual(amex.isHidden, false)
        XCTAssertEqual(cup.isHidden, false)
        XCTAssertEqual(maestro.isHidden, false)
        
        // When typing unknown combination, all logos should be hidden.
        item.value = "5"
        cardTypeProvider.requestCardType(for: item.value, supported: supportedCardTypes) { response in
            item.detectedCardsDidChange(detectedCards: response)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
        
        // When typing Maestro pattern, only Maestro should be visible.
        item.value = "56"
        cardTypeProvider.requestCardType(for: item.value, supported: supportedCardTypes) { response in
            item.detectedCardsDidChange(detectedCards: response)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, false)
        }
        
        // When typing Mastercard pattern, only Mastercard should be visible.
        item.value = "55"
        cardTypeProvider.requestCardType(for: item.value, supported: supportedCardTypes) { response in
            item.detectedCardsDidChange(detectedCards: response)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, false)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
        
        // When continuing to type, Mastercard should remain visible.
        item.value = "5555"
        cardTypeProvider.requestCardType(for: item.value, supported: supportedCardTypes) { response in
            item.detectedCardsDidChange(detectedCards: response)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, false)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
        
        // Clearing the field should bring back both logos.
        item.value = ""
        
        XCTAssertEqual(visa.isHidden, false)
        XCTAssertEqual(mc.isHidden, false)
        XCTAssertEqual(amex.isHidden, false)
        XCTAssertEqual(cup.isHidden, false)
        XCTAssertEqual(maestro.isHidden, false)
        
        // When typing VISA pattern, only VISA should be visible.
        item.value = "4"
        cardTypeProvider.requestCardType(for: item.value, supported: supportedCardTypes) { response in
            item.detectedCardsDidChange(detectedCards: response)
            XCTAssertEqual(visa.isHidden, false)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
        
        // When typing Amex pattern, only Amex should be visible.
        item.value = "34"
        cardTypeProvider.requestCardType(for: item.value, supported: supportedCardTypes) { response in
            item.detectedCardsDidChange(detectedCards: response)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, false)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
        
        // When typing common pattern, all matching cards should be visible.
        item.value = "62"
        cardTypeProvider.requestCardType(for: item.value, supported: supportedCardTypes) { response in
            item.detectedCardsDidChange(detectedCards: response)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, false)
            XCTAssertEqual(maestro.isHidden, false)
        }
    }

    func testExternalBinLookupHappyflow() {
        publicKeyProvider.mockResponse = .success("SOME_PUBLIC_KEY")
        apiClient.mockedResults = [.success(BinLookupResponse(brands: [.masterCard])),
                                   .success(BinLookupResponse(brands: []))]

        let item = FormCardNumberItem(supportedCardTypes: supportedCardTypes, environment: .test)
        XCTAssertEqual(item.cardTypeLogos.count, 5)

        let visa = item.cardTypeLogos[0]
        let mc = item.cardTypeLogos[1]
        let amex = item.cardTypeLogos[2]
        let cup = item.cardTypeLogos[3]
        let maestro = item.cardTypeLogos[4]

        cardTypeProvider.requestCardType(for: "RANDOM_LONG_STRING", supported: supportedCardTypes) { response in
            item.detectedCardsDidChange(detectedCards: response)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, false)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }

        cardTypeProvider.requestCardType(for: "RANDOM_LONG_STRING", supported: supportedCardTypes) { response in
            item.detectedCardsDidChange(detectedCards: response)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
    }

    func testExternalBinLookupFallback() {
        publicKeyProvider.mockResponse = .success("SOME_PUBLIC_KEY")
        apiClient.mockedResults = [.failure(DummyError.dummy), .failure(DummyError.dummy)]

        let item = FormCardNumberItem(supportedCardTypes: supportedCardTypes, environment: .test)
        XCTAssertEqual(item.cardTypeLogos.count, 5)

        let visa = item.cardTypeLogos[0]
        let mc = item.cardTypeLogos[1]
        let amex = item.cardTypeLogos[2]
        let cup = item.cardTypeLogos[3]
        let maestro = item.cardTypeLogos[4]

        // When entering PAN, Mastercard should remain visible.
        item.value = "5577000055770004"
        cardTypeProvider.requestCardType(for: item.value, supported: supportedCardTypes) { response in
            item.detectedCardsDidChange(detectedCards: response)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, false)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }

        // When entering too long PAN, all logos should be hidden.
        item.value = "55770000557700040"
        cardTypeProvider.requestCardType(for: item.value, supported: supportedCardTypes) { response in
            item.detectedCardsDidChange(detectedCards: response)
            XCTAssertEqual(visa.isHidden, true)
            XCTAssertEqual(mc.isHidden, true)
            XCTAssertEqual(amex.isHidden, true)
            XCTAssertEqual(cup.isHidden, true)
            XCTAssertEqual(maestro.isHidden, true)
        }
    }

    func testExternalBinLookupPublicKeyError() {
        publicKeyProvider.mockResponse = .failure(DummyError.dummy)
    }
    
    func testLocalizationWithCustomTableName() {
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        let sut = FormCardNumberItem(supportedCardTypes: [.visa, .masterCard], environment: .test, localizationParameters: expectedLocalizationParameters)
        
        XCTAssertEqual(sut.title, ADYLocalizedString("adyen.card.numberItem.title", expectedLocalizationParameters))
        XCTAssertEqual(sut.placeholder, ADYLocalizedString("adyen.card.numberItem.placeholder", expectedLocalizationParameters))
        XCTAssertEqual(sut.validationFailureMessage, ADYLocalizedString("adyen.card.numberItem.invalid", expectedLocalizationParameters))
    }
    
    func testLocalizationWithCustomKeySeparator() {
        let expectedLocalizationParameters = LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_")
        let sut = FormCardNumberItem(supportedCardTypes: [.visa, .masterCard], environment: .test, localizationParameters: expectedLocalizationParameters)
        
        XCTAssertEqual(sut.title, ADYLocalizedString("adyen_card_numberItem_title", expectedLocalizationParameters))
        XCTAssertEqual(sut.placeholder, ADYLocalizedString("adyen_card_numberItem_placeholder", expectedLocalizationParameters))
        XCTAssertEqual(sut.validationFailureMessage, ADYLocalizedString("adyen_card_numberItem_invalid", expectedLocalizationParameters))
    }
    
}

internal final class PublicKeyProviderMock: AnyCardPublicKeyProvider {
    var mockResponse: Result<String, Error>!

    func fetch(completion: @escaping PublicKeyProviderMock.CompletionHandler) throws {
        completion(mockResponse)
    }
}
