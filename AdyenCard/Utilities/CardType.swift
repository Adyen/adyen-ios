//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Enum containing most known types of credit and debit cards.
internal enum CardType: String {
    /// Accel
    case accel
    
    /// Alpha Bank Bonus MasterCard
    case alphaBankBonusMasterCard = "mcalphabankbonus"
    
    /// Alpha Bank Bonus VISA
    case alphaBankBonusVISA = "visaalphabankbonus"
    
    /// Argencard
    case argencard
    
    /// American Express
    case americanExpress = "amex"
    
    /// BCMC
    case bcmc
    
    /// de Bijenkorf Card
    case bijenkorfCard = "bijcard"
    
    /// Cabal
    case cabal
    
    /// Carte Bancaire
    case carteBancaire = "cartebancaire"
    
    /// Cencosud
    case cencosud
    
    /// Chèque Déjeuner
    case chequeDejeneur
    
    /// China UnionPay
    case chinaUnionPay = "cup"
    
    /// Codensa
    case codensa
    
    /// Credit Union 24
    case creditUnion24 = "cu24"
    
    /// Dankort
    case dankort
    
    /// Dankort VISA
    case dankortVISA = "visadankort"
    
    /// Diners Club
    case diners
    
    /// Discover
    case discover
    
    /// Elo
    case elo
    
    /// Hiper
    case hiper
    
    /// Hipercard
    case hipercard
    
    /// JCB
    case jcb
    
    /// KarenMillen
    case karenMillen = "karenmillen"
    
    /// Korea Cyber Payment
    case kcp = "kcp_creditcard"
    
    /// Maestro
    case maestro
    
    /// Maestro UK
    case maestroUK = "maestrouk"
    
    /// MasterCard
    case masterCard = "mc"
    
    /// Mir
    case mir
    
    /// Net+
    case netplus
    
    /// NYCE
    case nyce
    
    /// Oasis
    case oasis
    
    /// Pulse
    case pulse
    
    /// Solo
    case solo
    
    /// Shopping
    case shopping
    
    /// STAR
    case star
    
    /// Universal Air Travel Plan
    case uatp
    
    /// UnionPay
    case unionPay = "unionpay"
    
    /// VISA
    case visa
    
    /// The Warehouse
    case warehouse
    
    /// Array containing all card types in this enum.
    public static let all = [masterCard, americanExpress, visa, diners, discover, jcb, elo, hipercard, unionPay, bijenkorfCard, maestroUK, solo, bcmc, dankort, uatp, chinaUnionPay, codensa, alphaBankBonusVISA, dankortVISA, alphaBankBonusMasterCard, hiper, oasis, karenMillen, warehouse, mir, maestro, carteBancaire, kcp, cabal, accel, pulse, star, nyce, creditUnion24, argencard, netplus, shopping, cencosud, chequeDejeneur]
    
}

internal extension CardType {
    var regex: String? {
        switch self {
        case .americanExpress:
            return "^3[47][0-9]{0,13}$"
        case .visa:
            return "^4[0-9]{0,16}$"
        case .masterCard:
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
        case .bijenkorfCard:
            return "^(5100081)[0-9]{0,9}$"
        case .maestroUK:
            return "^(6759)[0-9]{0,15}$"
        case .solo:
            return "^(6767)[0-9]{0,15}$"
        case .bcmc:
            return "^((6703)[0-9]{0,15}|(479658|606005)[0-9]{0,13})$"
        case .dankort:
            return "^(5019)[0-9]{0,12}$"
        case .uatp:
            return "^1[0-9]{0,14}$"
        case .chinaUnionPay:
            return "^(62)[0-9]{0,17}$"
        case .codensa:
            return "^(590712)[0-9]{0,10}$"
        case .alphaBankBonusVISA:
            return "^(450903)[0-9]{0,10}$"
        case .dankortVISA:
            return "^(4571)[0-9]{0,12}$"
        case .alphaBankBonusMasterCard:
            return "^(510099)[0-9]{0,10}$"
        case .hiper:
            return "^(637095|637599|637609|637612)[0-9]{0,10}$"
        case .oasis:
            return "^(982616)[0-9]{0,10}$"
        case .karenMillen:
            return "^(98261465)[0-9]{0,8}$"
        case .warehouse:
            return "^(982633)[0-9]{0,10}$"
        case .mir:
            return "^(220)[0-9]{0,16}$"
        case .maestro:
            return "^(5[6-8][0-9]{0,17}|6[0-9]{0,18})$"
        case .carteBancaire:
            return "^[4-6][0-9]{0,15}$"
        default:
            return nil
        }
    }
}

internal extension CardType {
    func matches(cardNumber: String) -> Bool {
        guard let pattern = regex else {
            return false
        }
        
        do {
            let regularExpression = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: cardNumber.count)
            
            return regularExpression.firstMatch(in: cardNumber, options: [], range: range) != nil
        } catch {
            return false
        }
    }
    
}
