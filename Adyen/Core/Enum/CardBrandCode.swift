//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/**
 Codes for card brands.
 
 - mc:  MasterCard.
 - amex: American Express.
 */
enum CardBrandCode: String {
    case mc //swiftlint:disable:this identifier_name
    case amex
    case jcb
    case diners
    case kcp_creditcard //swiftlint:disable:this identifier_name
    case hipercard
    case discover
    case elo
    case visa
    case unionpay
    case maestro
    case bcmc
    case cartebancaire
    case visadankort
    case bijcard
    case dankort
    case uatp
    case maestrouk
    case accel
    case cabal
    case pulse
    case star
    case nyce
    case hiper
    case cu24
    case argencard
    case netplus
    case shopping
    case warehouse
    case oasis
    case cencosud
    case chequedejeneur
    case karenmillen
}
