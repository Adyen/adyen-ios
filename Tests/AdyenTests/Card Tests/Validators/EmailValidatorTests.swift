//
//  EmailValidatorTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 7/30/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class EmailValidatorTests: XCTestCase {

    func testLengthValidation() {
        let sut = EmailValidator()

        // Minimum 6 characters
        XCTAssertTrue(sut.isValid("y@g.co"))

        // Max 320 characters.
        XCTAssertFalse(sut.isValid("yLIUGIUGPIUGIUGIUiubiugibebfiouehfo2hf3oi2hoi3hroi23hriu32hriu32hri23ohro32ih2io3hroi32hriuo32hrioyLIUGIUGPIUGIUGIUiubiugibebfiouehfo2hf3oi2hoi3hroi23hriu32hriu32hri23ohro32ih2io3hroi32hriuo32hrio@gqilwudgqwiugddwqdqwdwqqwfqwfqwfyLIUGIUGPIUGIUGIUiubiugibebfiouehfo2hf3oi2hoi3hroi23hriu32hriu32hri23ohro32ih2io3hroi32hriuo32hrioyLIUGIUGPIUGIUGIUiubiugibebfiouehfo2hf3oi2hoi3hroi23hriu32hriu32hri23ohro32ih2io3hroi32hriuo32hrioyLIUGIUGPIUGIUGIUiubiugibebfiouehfo2hf3oi2hoi3hroi23hriu32hriu32hri23ohro32ih2io3hroi32hriuo32hrio"))
    }

    func testValidationOfDomainPart() {
        let sut = EmailValidator()

        XCTAssertTrue(sut.isValid("john.smith@mohamed12.eldoheiri"))
        XCTAssertTrue(sut.isValid("john.smith@[12.2.344.45]"))

        // Domain part is an one or more alpha-numeric strings separated by a dot.
        XCTAssertTrue(sut.isValid("john.smith@abc-12CB-FVCbh45.co"))

        // Domain last component must be alphabetical string.
        XCTAssertFalse(sut.isValid("john.smith@abc-12CB-FVCbh45.co1"))

        // The DomainPart before and after dot should be at least 2 characters
        XCTAssertFalse(sut.isValid("john.smith@1.c"))

        // Domain part can be an IP address of four of 1-3 long numbers separated by a dot.
        XCTAssertFalse(sut.isValid("john.smith@[12.2.344.45].com"))

        // The Domain part is not a valid IP address.
        XCTAssertFalse(sut.isValid("john.smith@[12.2.344]"))
    }

    func testValidationOfLocalPart() {
        let sut = EmailValidator()

        // Quoted local part can contain any character except for line terminators
        XCTAssertTrue(sut.isValid("\"UYFG)O^R&|.:;(%&*]T*T*[&GIU\"@gmail.com"))

        // Local part contains a "\n"
        XCTAssertFalse(sut.isValid("\"UYFG)O^R&|\n.:;(%&*]T*T*[&GIU\"@gmail.com"))

        // Unquoted local part should't contain any of those characters "("   ")"   "["   "]"   "\"   ","   ";"   ":"   "\s"   "@"
        XCTAssertTrue(sut.isValid("UYFGO^R&%&*T.*T*&GIU@gmail.com"))

        // Local part contains ";"
        XCTAssertFalse(sut.isValid("UYFGO^R&%;&*T*T*&GIU@gmail.com"))

        // Local part contains a space
        XCTAssertFalse(sut.isValid("UYFGO^R&% &*T*T*&GIU@gmail.com"))

        // Local part contains a ","
        XCTAssertFalse(sut.isValid("UYFGO^R&%,&*T*T*&GIU@gmail.com"))

        // Local part contains a ":"
        XCTAssertFalse(sut.isValid("UYFGO^R&%:&*T*T*&GIU@gmail.com"))

        // Local part contains a "@"
        XCTAssertFalse(sut.isValid("UYFGO^R&%@&*T*T*&GIU@gmail.com"))
    }

}
