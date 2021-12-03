//
//  BACSDirectDebitItemsFactoryTests.swift
//  AdyenUIKitTests
//
//  Created by Naufal Aros on 12/3/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@testable import Adyen
@testable import AdyenComponents
import XCTest


class BACSDirectDebitItemsFactoryTests: XCTestCase {

    var sut: BACSDirectDebitItemsFactory!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let styleProvider = FormComponentStyle()
        sut = BACSDirectDebitItemsFactory(styleProvider: styleProvider,
                                          localizationParameters: LocalizationParameters(),
                                          scope: "")
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testCreateHolderNameItemShouldReturnItemWithCorrectProperties() throws {
        // Given
        let expectedTitle = "Bank account holder name"
        let expectedPlaceholder = "Bank account holder name"
        let expectedValidationFailureMessage = "Invalid bank account holder name"
        let expectedIdentifier = ".holderNameItem"


        // When
        let holderNameItem = sut.createHolderNameItem()

        // Then
        XCTAssertEqual(expectedTitle, holderNameItem.title)
        XCTAssertEqual(expectedPlaceholder, holderNameItem.placeholder)
        XCTAssertNotNil(holderNameItem.validator)
        XCTAssertEqual(expectedValidationFailureMessage, holderNameItem.validationFailureMessage)
        XCTAssertTrue(holderNameItem.autocapitalizationType == .words)

        let identifier = try XCTUnwrap(holderNameItem.identifier)
        XCTAssertEqual(expectedIdentifier, identifier)
    }
}
