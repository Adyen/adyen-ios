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

    func testCreateBankAccountNumberItemShouldReturnItemWithCorrectProperties() throws {
        // Given
        let expectedTitle = "Bank account number"
        let expectedPlaceholder = "Bank account number"
        let expectedValidationFailureMessage = "Invalid bank account number"
        let expectedIdentifier = ".bankAccountNumberItem"


        // When
        let bankAccountItem = sut.createBankAccountNumberItem()

        // Then
        XCTAssertEqual(expectedTitle, bankAccountItem.title)
        XCTAssertEqual(expectedPlaceholder, bankAccountItem.placeholder)
        XCTAssertNotNil(bankAccountItem.validator)
        XCTAssertEqual(expectedValidationFailureMessage, bankAccountItem.validationFailureMessage)
        XCTAssertTrue(bankAccountItem.autocapitalizationType == .none)
        XCTAssertTrue(bankAccountItem.keyboardType == .numberPad)

        let identifier = try XCTUnwrap(bankAccountItem.identifier)
        XCTAssertEqual(expectedIdentifier, identifier)
    }

    func testCreateSortCodeItemShouldReturnItemWithCorrectProperties() throws {
        // Given
        let expectedTitle = "Sort code"
        let expectedPlaceholder = "Sort code"
        let expectedValidationFailureMessage = "Invalid sort code"
        let expectedIdentifier = ".sortCodeItem"


        // When
        let sortCodeItem = sut.createSortCodeItem()

        // Then
        XCTAssertEqual(expectedTitle, sortCodeItem.title)
        XCTAssertEqual(expectedPlaceholder, sortCodeItem.placeholder)
        XCTAssertNotNil(sortCodeItem.validator)
        XCTAssertEqual(expectedValidationFailureMessage, sortCodeItem.validationFailureMessage)
        XCTAssertTrue(sortCodeItem.autocapitalizationType == .none)
        XCTAssertTrue(sortCodeItem.keyboardType == .numberPad)

        let identifier = try XCTUnwrap(sortCodeItem.identifier)
        XCTAssertEqual(expectedIdentifier, identifier)
    }

    func testCreateEmailItemShouldReturnItemWithCorrectProperties() throws {
        // Given
        let expectedTitle = "Email address"
        let expectedPlaceholder = "Email address"
        let expectedValidationFailureMessage = "Invalid email address"
        let expectedIdentifier = ".emailItem"


        // When
        let emailItem = sut.createEmailItem()

        // Then
        XCTAssertEqual(expectedTitle, emailItem.title)
        XCTAssertEqual(expectedPlaceholder, emailItem.placeholder)
        XCTAssertNotNil(emailItem.validator)
        XCTAssertEqual(expectedValidationFailureMessage, emailItem.validationFailureMessage)
        XCTAssertTrue(emailItem.autocapitalizationType == .none)
        XCTAssertTrue(emailItem.keyboardType == .emailAddress)

        let identifier = try XCTUnwrap(emailItem.identifier)
        XCTAssertEqual(expectedIdentifier, identifier)
    }

}
