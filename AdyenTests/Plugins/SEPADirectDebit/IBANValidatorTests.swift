//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenSEPA
import XCTest

class IBANValidatorTests: XCTestCase {
    func testValidation() {
        for iban in validIBANs {
            XCTAssertTrue(IBANValidator().isValid(iban), "\(iban) is not valid.")
        }
    }
    
    func testCanonicalization() {
        XCTAssertEqual(IBANValidator().canonicalize("nl36test 0236169114"), "NL36TEST0236169114")
        XCTAssertEqual(IBANValidator().canonicalize("NL 82 test 0836169255"), "NL82TEST0836169255")
        XCTAssertEqual(IBANValidator().canonicalize(" DE94 8888 8888 9876 5432 10"), "DE94888888889876543210")
        XCTAssertEqual(IBANValidator().canonicalize("it60 x054 2811 1010 0000 0123 456"), "IT60X0542811101000000123456")
        XCTAssertEqual(IBANValidator().canonicalize("%FR1420041010050500013M02606%"), "FR1420041010050500013M02606")
        XCTAssertEqual(IBANValidator().canonicalize("ES9121000418450200051332"), "ES9121000418450200051332")
        XCTAssertEqual(IBANValidator().canonicalize("D K 8 6 1 2 3 4 1 2 3 4 5 6 7 8 9 0"), "DK8612341234567890")
    }
    
    func testExtractingCountryCode() {
        XCTAssertEqual(IBANValidator().countryCode(in: "NL13TEST0123456789"), "NL")
        XCTAssertEqual(IBANValidator().countryCode(in: "DE87123456781234567890"), "DE")
        XCTAssertEqual(IBANValidator().countryCode(in: "GB"), "GB")
        XCTAssertEqual(IBANValidator().countryCode(in: "MK87"), "MK")
        
        XCTAssertEqual(IBANValidator().countryCode(in: "6789NL13TEST012345"), nil)
        XCTAssertEqual(IBANValidator().countryCode(in: "678913012345"), nil)
        XCTAssertEqual(IBANValidator().countryCode(in: "6NL78913012345"), nil)
        XCTAssertEqual(IBANValidator().countryCode(in: "D"), nil)
    }
    
    func testRearranging() {
        XCTAssertEqual(IBANValidator().rearrange("NL13TEST0123456789"), "TEST0123456789NL13")
        XCTAssertEqual(IBANValidator().rearrange("DE87123456781234567890"), "123456781234567890DE87")
        XCTAssertEqual(IBANValidator().rearrange("MK63"), "MK63")
        XCTAssertEqual(IBANValidator().rearrange("NL05TEST0236169114"), "TEST0236169114NL05")
        XCTAssertEqual(IBANValidator().rearrange("IT60X0542811101000000123456"), "X0542811101000000123456IT60")
    }
    
    func testNumerification() {
        XCTAssertEqual(IBANValidator().numerify("WEST12345698765432GB82"), "3214282912345698765432161182")
        XCTAssertEqual(IBANValidator().numerify("TEST0236169114NL05"), "291428290236169114232105")
        XCTAssertEqual(IBANValidator().numerify("123456781234567890DE87"), "123456781234567890131487")
    }
    
    func testMod97() {
        XCTAssertEqual(IBANValidator().mod97("3214282912345698765432161182"), 1)
    }
    
    // MARK: Constants
    
    private let validIBANs = [
        "AD1200012030200359100100",
        "AE070331234567890123456",
        "AL47212110090000000235698741",
        "AT611904300234573201",
        "AZ21NABZ00000000137010001944",
        "BA391290079401028494",
        "BE68539007547034",
        "BG80BNBG96611020345678",
        "BH67BMAG00001299123456",
        "BR7724891749412660603618210F3",
        "CH9300762011623852957",
        "CY17002001280000001200527600",
        "CZ6508000000192000145399",
        "DE89370400440532013000",
        "DK5000400440116243",
        "DO28BAGR00000001212453611324",
        "EE382200221020145685",
        "ES9121000418450200051332",
        "FI2112345600000785",
        "FO7630004440960235",
        "FR1420041010050500013M02606",
        "GB29NWBK60161331926819",
        "GE29NB0000000101904917",
        "GI75NWBK000000007099453",
        "GL4330003330229543",
        "GR1601101250000000012300695",
        "GT82TRAJ01020000001210029690",
        "HR1210010051863000160",
        "HU42117730161111101800000000",
        "IE29AIBK93115212345678",
        "IL620108000000099999999",
        "IS140159260076545510730339",
        "IT60X0542811101000000123456",
        "KW81CBKU0000000000001234560101",
        "KZ86125KZT5004100100",
        "LB62099900000001001901229114",
        "LI21088100002324013AA",
        "LT121000011101001000",
        "LU280019400644750000",
        "LV80BANK0000435195001",
        "MC1112739000700011111000h79",
        "MD24AG000225100013104168",
        "ME25505000012345678951",
        "MK07300000000042425",
        "MR1300020001010000123456753",
        "MT84MALT011000012345MTLCAST001S",
        "MU17BOMM0101101030300200000MUR",
        "NL91ABNA0417164300",
        "NO9386011117947",
        "PK36SCBL0000001123456702",
        "PL27114020040000300201355387",
        "PS92PALS000000000400123456702",
        "PT50000201231234567890154",
        "QA58DOHB00001234567890ABCDEFG",
        "RO49AAAA1B31007593840000",
        "RS35260005601001611379",
        "SA0380000000608010167519",
        "SE3550000000054910000003",
        "SI56191000000123438",
        "SK3112000000198742637541",
        "SM86U0322509800000000270100",
        "TL380080012345678910157",
        "TN5914207207100707129648",
        "TR330006100519786457841326",
        "VG96VPVG0000012345678901",
        "XK051212012345678906"
    ]
    
}
