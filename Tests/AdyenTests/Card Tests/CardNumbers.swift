//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

// Utility class with example test card numbers.
enum CardNumbers {
    
    static let masterCard = [
        "2223000048410010", // Credit    NL
        "2223520443560010", // Debit     NL
        "2222410740360010", // Corporate NL
        "5100081112223332", // Bijenkorf NL
        "5103221911199245", // Prepaid   US
        "5100290029002909", // Consumer  NL
        "5577000055770004", // Consumer  PL
        "5136333333333335", // Consumer  FR
        "5585558555855583", // Consumer  ES
        "5555444433331111", // Consumer  GB
        "5555555555554444", // Corporate GB
        "5500000000000004", // Debit     US
        "5424000000000015" // Pro       EC
    ]
    
    static let visa = [
        "4111111111111111", // Consumer  NL
        "4988438843884305", // Classic   ES
        "4166676667666746", // Classic   NL
        "4646464646464644", // Classic   PL
        "4444333322221111", // Corporate GB
        "4400000000000008", // Debit     US
        "4977949494949497" // Gold      FR
    ]
    
    static let jcb = [
        "3569990010095841" // Consumer   US
    ]
    
    static let cartebancaire = [
        "4035501000000008", // Visadebit/Cartebancaire  FR
        "4360000001000005" // Cartebancaire            FR
    ]
    
    static let amex = [
        "370000000000002" // NL
    ]
    
    static let diners = [
        "36006666333344", // US
        "30000000000004"
    ]
    
    static let discover = [
        "6011601160116611", // US
        "6445644564456445" // GB
    ]
    
    static let bancontact = [
        "6703444444444449" // BE
    ]
    
    static let hipercard = [
        "6062828888666688" // BR
    ]
    
    static let elo = [
        "5066991111111118" // BR
    ]
    
    static let dankort = [
        "5019555544445555"
    ]
    
    static let unionPay = [
        "6250946000000016", // Debit
        "6250947000000014", // Credit
        "6243030000000001" // Express Pay
    ]
    
    static let uatp = [
        "135410014004955"
    ]
    
    static let invalid = [
        "4111111111111112",
        "370000000000000",
        "50195555",
        "1234567890",
        "0"
    ]
    
    static var valid: [String] {
        [
            masterCard,
            visa,
            jcb,
            cartebancaire,
            amex,
            diners,
            discover,
            bancontact,
            hipercard,
            elo,
            dankort,
            unionPay,
            uatp
        ].flatMap { $0 }
    }
}
