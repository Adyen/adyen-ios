//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Enum containing most known types of credit and debit cards.
public enum CardType: RawRepresentable, Codable, Equatable, Hashable {
    
    /// Accel
    case accel
    
    /// Alpha Bank Bonus MasterCard
    case alphaBankBonusMasterCard
    
    /// Alpha Bank Bonus VISA
    case alphaBankBonusVISA
    
    /// Argencard
    case argencard
    
    /// American Express
    case americanExpress
    
    /// BCMC
    case bcmc
    
    /// de Bijenkorf Card
    case bijenkorfCard
    
    /// Cabal
    case cabal
    
    /// Carte Bancaire
    case carteBancaire
    
    /// Cencosud
    case cencosud
    
    /// Chèque Déjeuner
    case chequeDejeneur
    
    /// China UnionPay
    case chinaUnionPay
    
    /// Codensa
    case codensa
    
    /// Credit Union 24
    case creditUnion24
    
    /// Dankort
    case dankort
    
    /// Dankort VISA
    case dankortVISA
    
    /// Diners Club
    case diners
    
    /// Discover
    case discover
    
    /// Elo
    case elo
    
    /// Forbrugsforeningen
    case forbrugsforeningen
    
    /// Hiper
    case hiper
    
    /// Hipercard
    case hipercard
    
    /// JCB
    case jcb
    
    /// KarenMillen
    case karenMillen
    
    /// Korea Cyber Payment
    case kcp

    /// Korean local card
    case koreanLocalCard
    
    /// Laser (Discontinued in 2014)
    case laser
    
    /// Maestro
    case maestro
    
    /// Maestro UK
    case maestroUK
    
    /// MasterCard
    case masterCard
    
    /// Mir
    case mir
    
    /// Naranja
    case naranja
    
    /// Net+
    case netplus
    
    /// NYCE
    case nyce
    
    /// Oasis
    case oasis
    
    /// Pulse
    case pulse
    
    /// Shopping
    case shopping
    
    /// Solo
    case solo
    
    /// STAR
    case star
    
    /// Troy
    case troy
    
    /// Universal Air Travel Plan
    case uatp
    
    /// VISA
    case visa
    
    /// The Warehouse
    case warehouse
    
    /// Fallback option for any other scheme name
    case other(named: String)
    
    // swiftlint:disable cyclomatic_complexity function_body_length
    public init(rawValue: String) {
        switch rawValue {
        case "accel": self = .accel
        case "mcalphabankbonus": self = .alphaBankBonusMasterCard
        case "visaalphabankbonus": self = .alphaBankBonusVISA
        case "argencard": self = .argencard
        case "amex": self = .americanExpress
        case "bcmc": self = .bcmc
        case "bijcard": self = .bijenkorfCard
        case "cabal": self = .cabal
        case "cartebancaire": self = .carteBancaire
        case "cencosud": self = .cencosud
        case "chequeDejeneur": self = .chequeDejeneur
        case "cup": self = .chinaUnionPay
        case "codensa": self = .codensa
        case "cu24": self = .creditUnion24
        case "dankort": self = .dankort
        case "visadankort": self = .dankortVISA
        case "diners": self = .diners
        case "discover": self = .discover
        case "elo": self = .elo
        case "forbrugsforeningen": self = .forbrugsforeningen
        case "hiper": self = .hiper
        case "hipercard": self = .hipercard
        case "jcb": self = .jcb
        case "karenmillen": self = .karenMillen
        case "kcp_creditcard": self = .kcp
        case "korean_local_card": self = .koreanLocalCard
        case "laser": self = .laser
        case "maestro": self = .maestro
        case "maestrouk": self = .maestroUK
        case "mc": self = .masterCard
        case "mir": self = .mir
        case "naranja": self = .naranja
        case "netplus": self = .netplus
        case "nyce": self = .nyce
        case "oasis": self = .oasis
        case "pulse": self = .pulse
        case "shopping": self = .shopping
        case "solo": self = .solo
        case "star": self = .star
        case "troy": self = .troy
        case "uatp": self = .uatp
        case "visa": self = .visa
        case "warehouse": self = .warehouse
        default: self = .other(named: rawValue)
        }
    }

    // swiftlint:enable cyclomatic_complexity function_body_length
    
    public var rawValue: String {
        switch self {
        case .accel: return "accel"
        case .alphaBankBonusMasterCard: return "mcalphabankbonus"
        case .alphaBankBonusVISA: return "visaalphabankbonus"
        case .argencard: return "argencard"
        case .americanExpress: return "amex"
        case .bcmc: return "bcmc"
        case .bijenkorfCard: return "bijcard"
        case .cabal: return "cabal"
        case .carteBancaire: return "cartebancaire"
        case .cencosud: return "cencosud"
        case .chequeDejeneur: return "chequeDejeneur"
        case .chinaUnionPay: return "cup"
        case .codensa: return "codensa"
        case .creditUnion24: return "cu24"
        case .dankort: return "dankort"
        case .dankortVISA: return "visadankort"
        case .diners: return "diners"
        case .discover: return "discover"
        case .elo: return "elo"
        case .forbrugsforeningen: return "forbrugsforeningen"
        case .hiper: return "hiper"
        case .hipercard: return "hipercard"
        case .jcb: return "jcb"
        case .karenMillen: return "karenmillen"
        case .kcp: return "kcp_creditcard"
        case .koreanLocalCard: return "korean_local_card"
        case .laser: return "laser"
        case .maestro: return "maestro"
        case .maestroUK: return "maestrouk"
        case .masterCard: return "mc"
        case .mir: return "mir"
        case .naranja: return "naranja"
        case .netplus: return "netplus"
        case .nyce: return "nyce"
        case .oasis: return "oasis"
        case .pulse: return "pulse"
        case .shopping: return "shopping"
        case .solo: return "solo"
        case .star: return "star"
        case .troy: return "troy"
        case .uatp: return "uatp"
        case .visa: return "visa"
        case .warehouse: return "warehouse"
        case let .other(named: name): return name
        }
    }
    
}

extension CardType {
    
    internal var pattern: String? {
        switch self { // NOSONAR
        case .alphaBankBonusMasterCard:
            return "^(510099)[0-9]{0,10}$"
        case .alphaBankBonusVISA:
            return "^(450903)[0-9]{0,10}$"
        case .americanExpress:
            return "^3[47][0-9]{0,13}$"
        case .argencard:
            return "^(50)(1)\\d*$"
        case .bcmc:
            return "^((6703)[0-9]{0,15}|(479658|606005)[0-9]{0,13})$"
        case .bijenkorfCard:
            return "^(5100081)[0-9]{0,9}$"
        case .cabal:
            return "^(58|6[03])([03469])\\d*$"
        case .carteBancaire:
            return "^[4-6][0-9]{0,15}$"
        case .codensa:
            return "^(590712)[0-9]{0,10}$"
        case .chinaUnionPay:
            return "^(62|81)[0-9]{0,17}$"
        case .dankort:
            return "^(5019)[0-9]{0,12}$"
        case .dankortVISA:
            return "^(4571)[0-9]{0,12}$"
        case .diners:
            return "^(3[60])[0-9]{0,12}$"
        case .discover:
            return "^(6011[0-9]{0,12}|(644|645|646|647|648|649)[0-9]{0,13}|65[0-9]{0,14})$"
        case .elo:
            return "^((((506699)|(506770)|(506771)|(506772)|(506773)|(506774)|(506775)|(506776)|(506777)|(506778)"
                + "|(401178)|(438935)|(451416)|(457631)|(457632)|(504175)|(627780)|(636368)|(636297))[0-9]"
                + "{0,10})|((50676)|(50675)|(50674)|(50673)|(50672)|(50671)|(50670))[0-9]{0,11})$"
        case .forbrugsforeningen:
            return "^(60)(0)\\d*$"
        case .hiper:
            return "^(637095|637599|637609|637612)[0-9]{0,10}$"
        case .hipercard:
            return "^(606282)[0-9]{0,10}$"
        case .jcb:
            return "^(352[8,9]{1}[0-9]{0,15}|35[4-8]{1}[0-9]{0,16})$"
        case .karenMillen:
            return "^(98261465)[0-9]{0,8}$"
        case .laser:
            return "^(6304|6706|6709|6771)[0-9]{0,15}$"
        case .maestro:
            return "^(5[0|6-8][0-9]{0,17}|6[0-9]{0,18})$"
        case .maestroUK:
            return "^(6759)[0-9]{0,15}$"
        case .masterCard:
            return "^(5[1-5][0-9]{0,14}|2[2-7][0-9]{0,14})$"
        case .mir:
            return "^(220)[0-9]{0,16}$"
        case .naranja:
            return "^(37|40|5[28])([279])\\d*$"
        case .oasis:
            return "^(982616)[0-9]{0,10}$"
        case .shopping:
            return "^(27|58|60)([39])\\d*$"
        case .solo:
            return "^(6767)[0-9]{0,15}$"
        case .troy:
            return "^(97)(9)\\d*$"
        case .uatp:
            return "^1[0-9]{0,14}$"
        case .visa:
            return "^4[0-9]{0,19}$"
        case .warehouse:
            return "^(982633)[0-9]{0,10}$"
        case .koreanLocalCard:
            return "^94[0-9]{0,18}$"
        case .accel,
             .cencosud,
             .chequeDejeneur,
             .creditUnion24,
             .kcp,
             .netplus,
             .nyce,
             .pulse,
             .star,
             .other:
            return nil
        }
    }
}

extension CardType {
    
    internal func matches(cardNumber: String) -> Bool {
        guard let pattern else {
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
