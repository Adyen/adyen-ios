//
//  EmailValidatorTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 7/30/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@testable import Adyen
import XCTest

class EmailValidatorTests: XCTestCase {
    
    func testLengthValidation() {
        let sut = EmailValidator()
        
        // Minimum 6 characters
        XCTAssertTrue(sut.isValid("y@g.co"))
        
        // Max 320 characters.
        XCTAssertFalse(sut.isValid("yLIUGIUGPIUGIUGIUiubiugibebfiouehfo2hf3oi2hoi3hroi23hriu32hriu32hri23ohro32ih2io3hroi32hriuo32hrioyLIUGIUGPIUGIUGIUiubiugibebfiouehfo2hf3oi2hoi3hroi23hriu32hriu32hri23ohro32ih2io3hroi32hriuo32hrio@gqilwudgqwiugddwqdqwdwqqwfqwfqwfyLIUGIUGPIUGIUGIUiubiugibebfiouehfo2hf3oi2hoi3hroi23hriu32hriu32hri23ohro32ih2io3hroi32hriuo32hrioyLIUGIUGPIUGIUGIUiubiugibebfiouehfo2hf3oi2hoi3hroi23hriu32hriu32hri23ohro32ih2io3hroi32hriuo32hrioyLIUGIUGPIUGIUGIUiubiugibebfiouehfo2hf3oi2hoi3hroi23hriu32hriu32hri23ohro32ih2io3hroi32hriuo32hrio"))
    }
    
    func testValidEmails() {
        let sut = EmailValidator()
        
        XCTAssertTrue(sut.isValid("simple@example.com"))
        XCTAssertTrue(sut.isValid("very.common@example.com"))
        XCTAssertTrue(sut.isValid("disposable.style.email.with+symbol@example.com"))
        XCTAssertTrue(sut.isValid("other.email-with-hyphen@example.com"))
        XCTAssertTrue(sut.isValid("fully-qualified-domain@example.com"))
        XCTAssertTrue(sut.isValid("user.name+tag+sorting@example.com"))
        XCTAssertTrue(sut.isValid("x@example.com"))
        XCTAssertTrue(sut.isValid("example-indeed@strange-example.com"))
        XCTAssertTrue(sut.isValid("test/test@test.com"))
        XCTAssertTrue(sut.isValid("example@s.example"))
        XCTAssertTrue(sut.isValid("\" \"@example.org"))
        XCTAssertTrue(sut.isValid("\"john..doe\"@example.org"))
        XCTAssertTrue(sut.isValid("mailhost!username@example.org"))
        XCTAssertTrue(sut.isValid("\"very.(),:;<>[]\".VERY.\"very@\\ \"very\".unusual\"@strange.example.com"))
        XCTAssertTrue(sut.isValid("user%example.com@example.org"))
        XCTAssertTrue(sut.isValid("user-@example.org"))
        XCTAssertTrue(sut.isValid("postmaster@[123.123.123.123]"))
        
        XCTAssertTrue(sut.isValid("john.smith@mohamed12.eldoheiri"))
        XCTAssertTrue(sut.isValid("john.smith@[12.2.344.45]"))
        
        XCTAssertTrue(sut.isValid("john.smith!#$%&'*+-/=?^_`{|}~@[12.2.344.45]"))
        XCTAssertTrue(sut.isValid("john!#$%&'*+-/=?^_`{|}~.smith@[12.2.344.45]"))
        XCTAssertTrue(sut.isValid("john!#$%&'*+-/=?^_`{|}~.smith!#$%&'*+-/=?^_`{|}~.efwe!#$%&'*+-/=?^_`{|}~.weoihefw.!#$%&'*+-/=?^_`{|}~@[12.2.344.45]"))
        XCTAssertTrue(sut.isValid("\" ewc429 (%($^)*_)*(&&R%$&$&^$#     \"@mohamed12.eldoheiri"))
        
        // Domain part is an one or more alpha-numeric strings separated by a dot.
        XCTAssertTrue(sut.isValid("john.smith@abc-12CB-FVCbh45.co"))
        XCTAssertTrue(sut.isValid("john.smith@abc-12CB-FVCbh45-979HVU.uk.us.mrweew.co"))
        XCTAssertTrue(sut.isValid("john.smith@abc-12CB-FVCbh45-979HVU.uk-weoh-238y23-ewfioh234.us-wefwef.mrweew.co"))
        
        // Quoted local part can contain any character except for line terminators
        XCTAssertTrue(sut.isValid("\"UYFG)O^R&|.:;(%&*]T*T*[&GIU\"@gmail.com"))
    }
    
    func testinvalidationEmails() {
        let sut = EmailValidator()
        
        XCTAssertFalse(sut.isValid("Abc.example.com"))
        XCTAssertFalse(sut.isValid("A@b@c@example.com"))
        XCTAssertFalse(sut.isValid("a\"b(c)d,e:f;g<h>i[j\\k]l@example.com"))
        XCTAssertFalse(sut.isValid("just\"not\"right@example.com"))
        XCTAssertFalse(sut.isValid("this is\"not\\allowed@example.com"))
        XCTAssertFalse(sut.isValid("this\\ still\"not\\allowed@example.com"))
        XCTAssertFalse(sut.isValid("i_like_underscore@but_its_not_allowed_in_this_part.example.com"))
        XCTAssertFalse(sut.isValid("QA[icon]CHOCOLATE[icon]@test.com"))
        
        // Domain part components must not start with a `-` or end with it
        XCTAssertFalse(sut.isValid("john.smith@-12CB-FVCbh45.co"))
        XCTAssertFalse(sut.isValid("john.smith@abc-12CB-.co"))
        
        // The `.` in the local part shouldnot be consecutive
        XCTAssertFalse(sut.isValid("john..smith@mohamed12.eldoheiri"))
        
        // The `.` in the local part shouldnot be at the beginning or end
        XCTAssertFalse(sut.isValid(".john.smith@mohamed12.eldoheiri"))
        XCTAssertFalse(sut.isValid("john.smith.@mohamed12.eldoheiri"))
        
        // Domain part shouldn't contain not latin characters
        XCTAssertFalse(sut.isValid("あいうえお@example.com"))
        
        // Domain last component must be alphabetical string.
        XCTAssertFalse(sut.isValid("john.smith@abc-12CB-FVCbh45.co1"))
        
        // The DomainPart before and after dot should be at least 2 characters
        XCTAssertFalse(sut.isValid("john.smith@1.c"))
        
        // Domain part can be an IP address of four of 1-3 long numbers separated by a dot.
        XCTAssertFalse(sut.isValid("john.smith@[12.2.344.45].com"))
        
        // The Domain part is not a valid IP address.
        XCTAssertFalse(sut.isValid("john.smith@[12.2.344]"))
        
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
