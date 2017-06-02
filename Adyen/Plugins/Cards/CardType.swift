//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Supported card types
enum CardType: String {
    
    /// MasterCard card type
    case mc // swiftlint:disable:this identifier_name
    
    case unknown
    case amex
    case visa
    case diners
    case discover
    case jcb
    case elo
    case hipercard
    case unionPay
    case bijcard
    case maestrouk
    case solo
    case bcmc
    case dankort
    case uatp
    case cup
    case codensa
    case visaalphabankbonus
    case visadankort
    case mcalphabankbonus
    case hiper
    case oasis
    case karenmillen
    case warehouse
    case mir
    case maestro
    case cartebancaire
    
    static let allCards = [mc, amex, visa, diners, discover, jcb, elo, hipercard, unionPay, bijcard, maestrouk, solo, bcmc, dankort, uatp, cup, codensa, visaalphabankbonus, visadankort, mcalphabankbonus, hiper, oasis, karenmillen, warehouse, mir, maestro, cartebancaire]
    
    var imageName: String {
        let type = rawValue.lowercased()
        return "card_" + type
    }
    
    public var regex: String {
        switch self {
        case .amex:
            return "^3[47][0-9]{0,13}$"
        case .visa:
            return "^4[0-9]{0,16}$"
        case .mc:
            return "^(5[1-5][0-9]{0,14}|2[2-7][0-9]{0,14})$"
        case .diners:
            return "^(36)[0-9]{0,12}$"
        case .discover:
            return "^(6011[0-9]{0,12}|(644|645|646|647|648|649)[0-9]{0,13}|65[0-9]{0,14})$"
        case .jcb:
            return "^(352[8,9]{1}[0-9]{0,15}|35[4-8]{1}[0-9]{0,16})$"
        case .unionPay:
            return "^(62|88)[0-9]{5,}$"
        case .hipercard:
            return "^(606282)[0-9]{0,10}$"
        case .elo:
            return "^((((506699)|(506770)|(506771)|(506772)|(506773)|(506774)|(506775)|(506776)|(506777)|(506778)"
                + "|(401178)|(438935)|(451416)|(457631)|(457632)|(504175)|(627780)|(636368)|(636297))[0-9]"
                + "{0,10})|((50676)|(50675)|(50674)|(50673)|(50672)|(50671)|(50670))[0-9]{0,11})$"
        case .bijcard:
            return "^(5100081)[0-9]{0,9}$"
        case .maestrouk:
            return "^(6759)[0-9]{0,15}$"
        case .solo:
            return "^(6767)[0-9]{0,15}$"
        case .bcmc:
            return "^((6703)[0-9]{0,15}|(479658|606005)[0-9]{0,13})$"
        case .dankort:
            return "^(5019)[0-9]{0,12}$"
        case .uatp:
            return "^1[0-9]{0,14}$"
        case .cup:
            return "^(62)[0-9]{0,17}$"
        case .codensa:
            return "^(590712)[0-9]{0,10}$"
        case .visaalphabankbonus:
            return "^(450903)[0-9]{0,10}$"
        case .visadankort:
            return "^(4571)[0-9]{0,12}$"
        case .mcalphabankbonus:
            return "^(510099)[0-9]{0,10}$"
        case .hiper:
            return "^(637095|637599|637609|637612)[0-9]{0,10}$"
        case .oasis:
            return "^(982616)[0-9]{0,10}$"
        case .karenmillen:
            return "^(98261465)[0-9]{0,8}$"
        case .warehouse:
            return "^(982633)[0-9]{0,10}$"
        case .mir:
            return "^(220)[0-9]{0,16}$"
        case .maestro:
            return "^(5[6-8][0-9]{0,17}|6[0-9]{0,18})$"
        case .cartebancaire:
            return "^[4-6][0-9]{0,15}$"
            
        default:
            return ""
        }
    }
}
