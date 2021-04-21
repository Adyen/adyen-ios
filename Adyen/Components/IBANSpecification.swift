//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains the country-specific specifications for countries that adopt the IBAN standard.
/// :nodoc:
public struct IBANSpecification {
    
    /// The highest possible length of an IBAN.
    /// :nodoc:
    public static let highestMaximumLength = 32
    
    /// The code of the country to which the specifications apply.
    /// :nodoc:
    public let countryCode: String
    
    /// The length of a valid IBAN.
    /// :nodoc:
    public let length: Int
    
    /// The structure of the underlying BBAN.
    /// :nodoc:
    public let structure: String
    
    /// An example of a valid IBAN.
    /// :nodoc:
    public let example: String
    
    /// Returns the IBAN specification for the country with the given code, or `nil` if none could be found.
    ///
    /// - Parameter countryCode: The code of the country to retrieve the IBAN specification for.
    /// :nodoc:
    public init?(forCountryCode countryCode: String) {
        guard let specification = IBANSpecification.specifications[countryCode] else {
            return nil
        }
        
        self = specification
    }
    
    /// Initializes the IBAN specification structure.
    ///
    /// - Parameters:
    ///   - countryCode: The code of the country to which the specifications apply.
    ///   - length: The length of a valid IBAN.
    ///   - structure: The structure of the underlying BBAN.
    ///   - example: An example of a valid IBAN.
    /// :nodoc:
    private init(countryCode: String, length: Int, structure: String, example: String) {
        self.countryCode = countryCode
        self.length = length
        self.structure = structure
        self.example = example
    }

    /// :nodoc:
    private static let specifications = [
        "AD": IBANSpecification(countryCode: "AD", length: 24, structure: "F04F04A12", example: "AD1200012030200359100100"),
        "AE": IBANSpecification(countryCode: "AE", length: 23, structure: "F03F16", example: "AE070331234567890123456"),
        "AL": IBANSpecification(countryCode: "AL", length: 28, structure: "F08A16", example: "AL47212110090000000235698741"),
        "AO": IBANSpecification(countryCode: "AO", length: 25, structure: "F21", example: "AO69123456789012345678901"),
        "AT": IBANSpecification(countryCode: "AT", length: 20, structure: "F05F11", example: "AT611904300234573201"),
        "AZ": IBANSpecification(countryCode: "AZ", length: 28, structure: "U04A20", example: "AZ21NABZ00000000137010001944"),
        "BA": IBANSpecification(countryCode: "BA", length: 20, structure: "F03F03F08F02", example: "BA391290079401028494"),
        "BE": IBANSpecification(countryCode: "BE", length: 16, structure: "F03F07F02", example: "BE68539007547034"),
        "BF": IBANSpecification(countryCode: "BF", length: 27, structure: "F23", example: "BF2312345678901234567890123"),
        "BG": IBANSpecification(countryCode: "BG", length: 22, structure: "U04F04F02A08", example: "BG80BNBG96611020345678"),
        "BH": IBANSpecification(countryCode: "BH", length: 22, structure: "U04A14", example: "BH67BMAG00001299123456"),
        "BI": IBANSpecification(countryCode: "BI", length: 16, structure: "F12", example: "BI41123456789012"),
        "BJ": IBANSpecification(countryCode: "BJ", length: 28, structure: "F24", example: "BJ39123456789012345678901234"),
        "BR": IBANSpecification(countryCode: "BR", length: 29, structure: "F08F05F10U01A01", example: "BR9700360305000010009795493P1"),
        "CH": IBANSpecification(countryCode: "CH", length: 21, structure: "F05A12", example: "CH9300762011623852957"),
        "CI": IBANSpecification(countryCode: "CI", length: 28, structure: "U01F23", example: "CI17A12345678901234567890123"),
        "CM": IBANSpecification(countryCode: "CM", length: 27, structure: "F23", example: "CM9012345678901234567890123"),
        "CR": IBANSpecification(countryCode: "CR", length: 22, structure: "F04F14", example: "CR72012300000171549015"),
        "CV": IBANSpecification(countryCode: "CV", length: 25, structure: "F21", example: "CV30123456789012345678901"),
        "CY": IBANSpecification(countryCode: "CY", length: 28, structure: "F03F05A16", example: "CY17002001280000001200527600"),
        "CZ": IBANSpecification(countryCode: "CZ", length: 24, structure: "F04F06F10", example: "CZ6508000000192000145399"),
        "DE": IBANSpecification(countryCode: "DE", length: 22, structure: "F08F10", example: "DE89370400440532013000"),
        "DK": IBANSpecification(countryCode: "DK", length: 18, structure: "F04F09F01", example: "DK5000400440116243"),
        "DO": IBANSpecification(countryCode: "DO", length: 28, structure: "U04F20", example: "DO28BAGR00000001212453611324"),
        "DZ": IBANSpecification(countryCode: "DZ", length: 24, structure: "F20", example: "DZ8612345678901234567890"),
        "EE": IBANSpecification(countryCode: "EE", length: 20, structure: "F02F02F11F01", example: "EE382200221020145685"),
        "ES": IBANSpecification(countryCode: "ES", length: 24, structure: "F04F04F01F01F10", example: "ES9121000418450200051332"),
        "FI": IBANSpecification(countryCode: "FI", length: 18, structure: "F06F07F01", example: "FI2112345600000785"),
        "FO": IBANSpecification(countryCode: "FO", length: 18, structure: "F04F09F01", example: "FO6264600001631634"),
        "FR": IBANSpecification(countryCode: "FR", length: 27, structure: "F05F05A11F02", example: "FR1420041010050500013M02606"),
        "GB": IBANSpecification(countryCode: "GB", length: 22, structure: "U04F06F08", example: "GB29NWBK60161331926819"),
        "GE": IBANSpecification(countryCode: "GE", length: 22, structure: "U02F16", example: "GE29NB0000000101904917"),
        "GI": IBANSpecification(countryCode: "GI", length: 23, structure: "U04A15", example: "GI75NWBK000000007099453"),
        "GL": IBANSpecification(countryCode: "GL", length: 18, structure: "F04F09F01", example: "GL8964710001000206"),
        "GR": IBANSpecification(countryCode: "GR", length: 27, structure: "F03F04A16", example: "GR1601101250000000012300695"),
        "GT": IBANSpecification(countryCode: "GT", length: 28, structure: "A04A20", example: "GT82TRAJ01020000001210029690"),
        "HR": IBANSpecification(countryCode: "HR", length: 21, structure: "F07F10", example: "HR1210010051863000160"),
        "HU": IBANSpecification(countryCode: "HU", length: 28, structure: "F03F04F01F15F01", example: "HU42117730161111101800000000"),
        "IE": IBANSpecification(countryCode: "IE", length: 22, structure: "U04F06F08", example: "IE29AIBK93115212345678"),
        "IL": IBANSpecification(countryCode: "IL", length: 23, structure: "F03F03F13", example: "IL620108000000099999999"),
        "IR": IBANSpecification(countryCode: "IR", length: 26, structure: "F22", example: "IR861234568790123456789012"),
        "IS": IBANSpecification(countryCode: "IS", length: 26, structure: "F04F02F06F10", example: "IS140159260076545510730339"),
        "IT": IBANSpecification(countryCode: "IT", length: 27, structure: "U01F05F05A12", example: "IT60X0542811101000000123456"),
        "JO": IBANSpecification(countryCode: "JO", length: 30, structure: "A04F22", example: "JO15AAAA1234567890123456789012"),
        "KW": IBANSpecification(countryCode: "KW", length: 30, structure: "U04A22", example: "KW81CBKU0000000000001234560101"),
        "KZ": IBANSpecification(countryCode: "KZ", length: 20, structure: "F03A13", example: "KZ86125KZT5004100100"),
        "LB": IBANSpecification(countryCode: "LB", length: 28, structure: "F04A20", example: "LB62099900000001001901229114"),
        "LC": IBANSpecification(countryCode: "LC", length: 32, structure: "U04F24", example: "LC07HEMM000100010012001200013015"),
        "LI": IBANSpecification(countryCode: "LI", length: 21, structure: "F05A12", example: "LI21088100002324013AA"),
        "LT": IBANSpecification(countryCode: "LT", length: 20, structure: "F05F11", example: "LT121000011101001000"),
        "LU": IBANSpecification(countryCode: "LU", length: 20, structure: "F03A13", example: "LU280019400644750000"),
        "LV": IBANSpecification(countryCode: "LV", length: 21, structure: "U04A13", example: "LV80BANK0000435195001"),
        "MC": IBANSpecification(countryCode: "MC", length: 27, structure: "F05F05A11F02", example: "MC5811222000010123456789030"),
        "MD": IBANSpecification(countryCode: "MD", length: 24, structure: "U02A18", example: "MD24AG000225100013104168"),
        "ME": IBANSpecification(countryCode: "ME", length: 22, structure: "F03F13F02", example: "ME25505000012345678951"),
        "MG": IBANSpecification(countryCode: "MG", length: 27, structure: "F23", example: "MG1812345678901234567890123"),
        "MK": IBANSpecification(countryCode: "MK", length: 19, structure: "F03A10F02", example: "MK07250120000058984"),
        "ML": IBANSpecification(countryCode: "ML", length: 28, structure: "U01F23", example: "ML15A12345678901234567890123"),
        "MR": IBANSpecification(countryCode: "MR", length: 27, structure: "F05F05F11F02", example: "MR1300020001010000123456753"),
        "MT": IBANSpecification(countryCode: "MT", length: 31, structure: "U04F05A18", example: "MT84MALT011000012345MTLCAST001S"),
        "MU": IBANSpecification(countryCode: "MU", length: 30, structure: "U04F02F02F12F03U03", example: "MU17BOMM0101101030300200000MUR"),
        "MZ": IBANSpecification(countryCode: "MZ", length: 25, structure: "F21", example: "MZ25123456789012345678901"),
        "NL": IBANSpecification(countryCode: "NL", length: 18, structure: "U04F10", example: "NL91ABNA0417164300"),
        "NO": IBANSpecification(countryCode: "NO", length: 15, structure: "F04F06F01", example: "NO9386011117947"),
        "PK": IBANSpecification(countryCode: "PK", length: 24, structure: "U04A16", example: "PK36SCBL0000001123456702"),
        "PL": IBANSpecification(countryCode: "PL", length: 28, structure: "F08F16", example: "PL61109010140000071219812874"),
        "PS": IBANSpecification(countryCode: "PS", length: 29, structure: "U04A21", example: "PS92PALS000000000400123456702"),
        "PT": IBANSpecification(countryCode: "PT", length: 25, structure: "F04F04F11F02", example: "PT50000201231234567890154"),
        "QA": IBANSpecification(countryCode: "QA", length: 29, structure: "U04A21", example: "QA30AAAA123456789012345678901"),
        "RO": IBANSpecification(countryCode: "RO", length: 24, structure: "U04A16", example: "RO49AAAA1B31007593840000"),
        "RS": IBANSpecification(countryCode: "RS", length: 22, structure: "F03F13F02", example: "RS35260005601001611379"),
        "SA": IBANSpecification(countryCode: "SA", length: 24, structure: "F02A18", example: "SA0380000000608010167519"),
        "SE": IBANSpecification(countryCode: "SE", length: 24, structure: "F03F16F01", example: "SE4550000000058398257466"),
        "SI": IBANSpecification(countryCode: "SI", length: 19, structure: "F05F08F02", example: "SI56263300012039086"),
        "SK": IBANSpecification(countryCode: "SK", length: 24, structure: "F04F06F10", example: "SK3112000000198742637541"),
        "SM": IBANSpecification(countryCode: "SM", length: 27, structure: "U01F05F05A12", example: "SM86U0322509800000000270100"),
        "SN": IBANSpecification(countryCode: "SN", length: 28, structure: "U01F23", example: "SN52A12345678901234567890123"),
        "ST": IBANSpecification(countryCode: "ST", length: 25, structure: "F08F11F02", example: "ST68000100010051845310112"),
        "TL": IBANSpecification(countryCode: "TL", length: 23, structure: "F03F14F02", example: "TL380080012345678910157"),
        "TN": IBANSpecification(countryCode: "TN", length: 24, structure: "F02F03F13F02", example: "TN5910006035183598478831"),
        "TR": IBANSpecification(countryCode: "TR", length: 26, structure: "F05F01A16", example: "TR330006100519786457841326"),
        "UA": IBANSpecification(countryCode: "UA", length: 29, structure: "F25", example: "UA511234567890123456789012345"),
        "VG": IBANSpecification(countryCode: "VG", length: 24, structure: "U04F16", example: "VG96VPVG0000012345678901"),
        "XK": IBANSpecification(countryCode: "XK", length: 20, structure: "F04F10F02", example: "XK051212012345678906")
    ]
    // swiftlint:enable line_length
    
}
