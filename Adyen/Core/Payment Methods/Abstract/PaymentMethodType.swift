//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The type of a payment method
public enum PaymentMethodType: RawRepresentable, Hashable, Codable {
    case card
    case scheme
    case ideal
    case entercash
    case eps
    case dotpay
    case onlineBankingPoland
    case openBankingUK
    case molPayEBankingFPXMY
    case molPayEBankingTH
    case molPayEBankingVN
    case sepaDirectDebit
    case applePay
    case payPal
    case bcmc
    case bcmcMobileQR
    case bcmcMobile
    case weChatMiniProgram
    case weChatQR
    case qiwiWallet
    case weChatPayWeb
    case weChatPaySDK
    case mbWay
    case blik
    case googlePay
    case afterpay
    case androidPay
    case amazonPay
    case dokuWallet
    case dokuAlfamart
    case dokuIndomaret
    case giftcard
    case doku
    case econtextSevenEleven
    case econtextStores
    case econtextATM
    case econtextOnline
    case boleto
    case affirm
    case oxxo
    case bacsDirectDebit
    case achDirectDebit
    case multibanco
    case atome
    case onlineBankingCZ
    case onlineBankingSK
    case mealVoucherNatixis
    case mealVoucherGroupeUp
    case mealVoucherSodexo
    case upi
    case cashAppPay
    case bizum
    case other(String)
    
    // swiftlint:disable cyclomatic_complexity function_body_length
    
    public init?(rawValue: String) {
        switch rawValue {
        case "card": self = .card
        case "scheme": self = .scheme
        case "ideal": self = .ideal
        case "entercash": self = .entercash
        case "eps": self = .eps
        case "dotpay": self = .dotpay
        case "onlineBanking_PL": self = .onlineBankingPoland
        case "openbanking_UK": self = .openBankingUK
        case "molpay_ebanking_fpx_MY": self = .molPayEBankingFPXMY
        case "molpay_ebanking_TH": self = .molPayEBankingTH
        case "molpay_ebanking_VN": self = .molPayEBankingVN
        case "sepadirectdebit": self = .sepaDirectDebit
        case "applepay": self = .applePay
        case "paypal": self = .payPal
        case "bcmc": self = .bcmc
        case "bcmc_mobile_QR": self = .bcmcMobileQR
        case "bcmc_mobile": self = .bcmcMobile
        case "wechatpayMiniProgram": self = .weChatMiniProgram
        case "wechatpayQR": self = .weChatQR
        case "qiwiwallet": self = .qiwiWallet
        case "wechatpayWeb": self = .weChatPayWeb
        case "wechatpaySDK": self = .weChatPaySDK
        case "mbway": self = .mbWay
        case "blik": self = .blik
        /// `paywithgoogle` and `googlepay` should be blocked on iOS
        case "paywithgoogle", "googlepay": self = .googlePay
        case "afterpay_default": self = .afterpay
        case "androidpay": self = .androidPay
        case "amazonpay": self = .amazonPay
        case "doku_wallet": self = .dokuWallet
        case "doku_alfamart": self = .dokuAlfamart
        case "doku_indomaret": self = .dokuIndomaret
        case "giftcard": self = .giftcard
        case "doku": self = .doku
        case "econtext_seven_eleven": self = .econtextSevenEleven
        case "econtext_stores": self = .econtextStores
        case "econtext_atm": self = .econtextATM
        case "econtext_online": self = .econtextOnline
        case "boletobancario_santander": self = .boleto
        case "affirm": self = .affirm
        case "oxxo": self = .oxxo
        case "directdebit_GB": self = .bacsDirectDebit
        case "ach": self = .achDirectDebit
        case "multibanco": self = .multibanco
        case "atome": self = .atome
        case "onlineBanking_CZ": self = .onlineBankingCZ
        case "onlineBanking_SK": self = .onlineBankingSK
        case "mealVoucher_FR_groupeup": self = .mealVoucherGroupeUp
        case "mealVoucher_FR_natixis": self = .mealVoucherNatixis
        case "mealVoucher_FR_sodexo": self = .mealVoucherSodexo
        case "upi": self = .upi
        case "cashapp": self = .cashAppPay
        case "bizum": self = .bizum
        default: self = .other(rawValue)
        }
    }
    
    public var rawValue: String {
        switch self {
        case .card: return "card"
        case .scheme: return "scheme"
        case .ideal: return "ideal"
        case .entercash: return "entercash"
        case .eps: return "eps"
        case .dotpay: return "dotpay"
        case .onlineBankingPoland: return "onlineBanking_PL"
        case .openBankingUK: return "openbanking_UK"
        case .molPayEBankingFPXMY: return "molpay_ebanking_fpx_MY"
        case .molPayEBankingTH: return "molpay_ebanking_TH"
        case .molPayEBankingVN: return "molpay_ebanking_VN"
        case .sepaDirectDebit: return "sepadirectdebit"
        case .applePay: return "applepay"
        case .payPal: return "paypal"
        case .bcmc: return "bcmc"
        case .bcmcMobileQR: return "bcmc_mobile_QR"
        case .bcmcMobile: return "bcmc_mobile"
        case .weChatMiniProgram: return "wechatpayMiniProgram"
        case .weChatQR: return "wechatpayQR"
        case .qiwiWallet: return "qiwiwallet"
        case .weChatPayWeb: return "wechatpayWeb"
        case .weChatPaySDK: return "wechatpaySDK"
        case .mbWay: return "mbway"
        case .blik: return "blik"
        case .googlePay: return "paywithgoogle"
        case .afterpay: return "afterpay_default"
        case .androidPay: return "androidpay"
        case .amazonPay: return "amazonpay"
        case .dokuWallet: return "doku_wallet"
        case .dokuAlfamart: return "doku_alfamart"
        case .dokuIndomaret: return "doku_indomaret"
        case .giftcard: return "giftcard"
        case .doku: return "doku"
        case .econtextSevenEleven: return "econtext_seven_eleven"
        case .econtextStores: return "econtext_stores"
        case .econtextATM: return "econtext_atm"
        case .econtextOnline: return "econtext_online"
        case .boleto: return "boletobancario_santander"
        case .affirm: return "affirm"
        case .oxxo: return "oxxo"
        case .bacsDirectDebit: return "directdebit_GB"
        case .achDirectDebit: return "ach"
        case .multibanco: return "multibanco"
        case .atome: return "atome"
        case .onlineBankingCZ: return "onlineBanking_CZ"
        case .onlineBankingSK: return "onlineBanking_SK"
        case .mealVoucherGroupeUp: return "mealVoucher_FR_groupeup"
        case .mealVoucherNatixis: return "mealVoucher_FR_natixis"
        case .mealVoucherSodexo: return "mealVoucher_FR_sodexo"
        case .upi: return "upi"
        case .cashAppPay: return "cashapp"
        case .bizum: return "bizum"
        case let .other(value): return value
        }
    }
}

extension PaymentMethodType {
    
    /// The brand name of the card type
    ///
    /// - Warning: Currently only intended to be used as `accessibilityLabel` as it's not localized
    @_spi(AdyenInternal)
    public var name: String {
        switch self {
        case .card: return "card payment"
        case .scheme: return "scheme"
        case .ideal: return "ideal"
        case .entercash: return "enter-cash"
        case .eps: return "EPS"
        case .dotpay: return "dotpay"
        case .onlineBankingPoland: return "online banking \(localized(country: "PL"))"
        case .openBankingUK: return "open banking UK"
        case .molPayEBankingFPXMY: return "FPX online banking \(localized(country: "MY"))"
        case .molPayEBankingTH: return "online banking \(localized(country: "TH"))"
        case .molPayEBankingVN: return "online banking \(localized(country: "VN"))"
        case .sepaDirectDebit: return "sepa direct-debit"
        case .applePay: return "applepay"
        case .payPal: return "paypal"
        case .bcmc: return "bcmc"
        case .bcmcMobileQR: return "bcmc mobile qr"
        case .bcmcMobile: return "bcmc mobile"
        case .weChatMiniProgram: return "wechat pay"
        case .weChatQR: return "wechat pay"
        case .qiwiWallet: return "qiwi wallet"
        case .weChatPayWeb: return "wechat pay"
        case .weChatPaySDK: return "wechat pay"
        case .mbWay: return "mbway"
        case .blik: return "blik"
        case .googlePay: return "google pay"
        case .afterpay: return "afterpay"
        case .androidPay: return "android pay"
        case .amazonPay: return "amazon pay"
        case .dokuWallet: return "doku wallet"
        case .dokuAlfamart: return "alfamart"
        case .dokuIndomaret: return "indomaret"
        case .giftcard: return "giftcard"
        case .doku: return "doku"
        case .econtextSevenEleven: return "econtext seven-eleven"
        case .econtextStores: return "econtext stores"
        case .econtextATM: return "econtext ATM"
        case .econtextOnline: return "econtext online"
        case .boleto: return "boleto"
        case .affirm: return "affirm"
        case .oxxo: return "OXXO"
        case .bacsDirectDebit: return "BACS direct debit"
        case .achDirectDebit: return "ACH direct debit"
        case .multibanco: return "multibanco"
        case .atome: return "atome"
        case .onlineBankingCZ: return "online banking \(localized(country: "CZ"))"
        case .onlineBankingSK: return "online banking \(localized(country: "SK"))"
        case .mealVoucherGroupeUp: return "meal voucher groupe-up"
        case .mealVoucherNatixis: return "meal voucher natixis"
        case .mealVoucherSodexo: return "meal voucher sodexo"
        case .upi: return "UPI"
        case .cashAppPay: return "cash app"
        case .bizum: return "bizum"
        case let .other(name): return name.replacingOccurrences(of: "_", with: " ")
        }
    }
    // swiftlint:enable cyclomatic_complexity function_body_length
}

private extension PaymentMethodType {
    func localized(country: String) -> String {
        Locale.current.localizedString(forRegionCode: country) ?? country
    }
}
