//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The type of a payment method, also known as `txVariant`.
public struct PaymentMethodType: RawRepresentable, Hashable, Codable, Sendable {

    /// The raw value as returned in the `/paymentMethods` response.
    public let rawValue: String

    /// Creates a payment method type with the given raw value.
    /// - Parameter rawValue: The `txVariant` of the payment method.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    // MARK: - Coding

    public init(from decoder: Decoder) throws {
        rawValue = try decoder.singleValueContainer().decode(String.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    // MARK: - Supported types

    public static let card = PaymentMethodType(rawValue: "card")
    public static let scheme = PaymentMethodType(rawValue: "scheme")
    public static let ideal = PaymentMethodType(rawValue: "ideal")
    public static let entercash = PaymentMethodType(rawValue: "entercash")
    public static let eps = PaymentMethodType(rawValue: "eps")
    public static let dotpay = PaymentMethodType(rawValue: "dotpay")
    public static let onlineBankingPL = PaymentMethodType(rawValue: "onlineBanking_PL")
    public static let openBankingUK = PaymentMethodType(rawValue: "openbanking_UK")
    public static let molPayEBankingFPXMY = PaymentMethodType(rawValue: "molpay_ebanking_fpx_MY")
    public static let molPayEBankingTH = PaymentMethodType(rawValue: "molpay_ebanking_TH")
    public static let molPayEBankingVN = PaymentMethodType(rawValue: "molpay_ebanking_VN")
    public static let sepaDirectDebit = PaymentMethodType(rawValue: "sepadirectdebit")
    public static let applePay = PaymentMethodType(rawValue: "applepay")
    public static let payPal = PaymentMethodType(rawValue: "paypal")
    public static let bcmc = PaymentMethodType(rawValue: "bcmc")
    public static let bcmcMobile = PaymentMethodType(rawValue: "bcmc_mobile")
    public static let qiwiWallet = PaymentMethodType(rawValue: "qiwiwallet")
    public static let weChatPaySDK = PaymentMethodType(rawValue: "wechatpaySDK")
    public static let mbWay = PaymentMethodType(rawValue: "mbway")
    public static let blik = PaymentMethodType(rawValue: "blik")
    public static let dokuWallet = PaymentMethodType(rawValue: "doku_wallet")
    public static let dokuAlfamart = PaymentMethodType(rawValue: "doku_alfamart")
    public static let dokuIndomaret = PaymentMethodType(rawValue: "doku_indomaret")
    public static let giftCard = PaymentMethodType(rawValue: "giftcard")
    public static let doku = PaymentMethodType(rawValue: "doku")
    public static let econtextSevenEleven = PaymentMethodType(rawValue: "econtext_seven_eleven")
    public static let econtextStores = PaymentMethodType(rawValue: "econtext_stores")
    public static let econtextATM = PaymentMethodType(rawValue: "econtext_atm")
    public static let econtextOnline = PaymentMethodType(rawValue: "econtext_online")
    public static let boletoBancario = PaymentMethodType(rawValue: "boletobancario")
    public static let boletoBancarioSantander = PaymentMethodType(rawValue: "boletobancario_santander")
    public static let boletoBancarioItau = PaymentMethodType(rawValue: "boletobancario_itau")
    public static let primeiroPayBoleto = PaymentMethodType(rawValue: "primeiropay_boleto")
    public static let affirm = PaymentMethodType(rawValue: "affirm")
    public static let oxxo = PaymentMethodType(rawValue: "oxxo")
    public static let bacsDirectDebit = PaymentMethodType(rawValue: "directdebit_GB")
    public static let achDirectDebit = PaymentMethodType(rawValue: "ach")
    public static let multibanco = PaymentMethodType(rawValue: "multibanco")
    public static let atome = PaymentMethodType(rawValue: "atome")
    public static let onlineBankingCZ = PaymentMethodType(rawValue: "onlineBanking_CZ")
    public static let onlineBankingSK = PaymentMethodType(rawValue: "onlineBanking_SK")
    public static let mealVoucherNatixis = PaymentMethodType(rawValue: "mealVoucher_FR_natixis")
    public static let mealVoucherGroupeUp = PaymentMethodType(rawValue: "mealVoucher_FR_groupeup")
    public static let mealVoucherSodexo = PaymentMethodType(rawValue: "mealVoucher_FR_sodexo")
    public static let upi = PaymentMethodType(rawValue: "upi")
    public static let cashAppPay = PaymentMethodType(rawValue: "cashapp")
    public static let bizum = PaymentMethodType(rawValue: "bizum")
    public static let twint = PaymentMethodType(rawValue: "twint")
    public static let payByBank = PaymentMethodType(rawValue: "paybybank")
    public static let payByBankAISDD = PaymentMethodType(rawValue: "paybybank_AIS_DD")
    public static let payTo = PaymentMethodType(rawValue: "payto")
    public static let pix = PaymentMethodType(rawValue: "pix")
    public static let promptPay = PaymentMethodType(rawValue: "promptpay")
    public static let duitNow = PaymentMethodType(rawValue: "duitnow")
    public static let payNow = PaymentMethodType(rawValue: "paynow")
    public static let upiCollect = PaymentMethodType(rawValue: "upi_collect")
    public static let upiIntent = PaymentMethodType(rawValue: "upi_intent")
    public static let upiQR = PaymentMethodType(rawValue: "upi_qr")

    // MARK: - Internal types

    package static let mealVoucherFR = PaymentMethodType(rawValue: "mealVoucher_FR")

    // MARK: - Unsupported types

    package static let bcmcMobileQR = PaymentMethodType(rawValue: "bcmc_mobile_QR")
    package static let weChatPayMiniProgram = PaymentMethodType(rawValue: "wechatpayMiniProgram")
    package static let weChatPayQR = PaymentMethodType(rawValue: "wechatpayQR")
    package static let weChatPayWeb = PaymentMethodType(rawValue: "wechatpayWeb")
    package static let googlePay = PaymentMethodType(rawValue: "googlepay")
    package static let googlePayLegacy = PaymentMethodType(rawValue: "paywithgoogle")
    package static let afterpay = PaymentMethodType(rawValue: "afterpay_default")
    package static let androidPay = PaymentMethodType(rawValue: "androidpay")
    package static let amazonPay = PaymentMethodType(rawValue: "amazonpay")
}

extension PaymentMethodType {
    
    /// The brand name of the card type
    ///
    /// - Warning: Currently only intended to be used as `accessibilityLabel` as it's not localized
    package var name: String {
        switch self {
        case .card: return "card payment"
        case .entercash: return "enter-cash"
        case .eps: return "EPS"
        case .onlineBankingPL: return "online banking \(localized(country: "PL"))"
        case .openBankingUK: return "open banking UK"
        case .molPayEBankingFPXMY: return "FPX online banking \(localized(country: "MY"))"
        case .molPayEBankingTH: return "online banking \(localized(country: "TH"))"
        case .molPayEBankingVN: return "online banking \(localized(country: "VN"))"
        case .sepaDirectDebit: return "sepa direct-debit"
        case .bcmcMobileQR: return "bcmc mobile qr"
        case .bcmcMobile: return "bcmc mobile"
        case .weChatPayMiniProgram, .weChatPayQR, .weChatPayWeb, .weChatPaySDK: return "wechat pay"
        case .qiwiWallet: return "qiwi wallet"
        case .googlePay, .googlePayLegacy: return "google pay"
        case .afterpay: return "afterpay"
        case .androidPay: return "android pay"
        case .amazonPay: return "amazon pay"
        case .dokuAlfamart: return "alfamart"
        case .dokuIndomaret: return "indomaret"
        case .econtextSevenEleven: return "econtext seven-eleven"
        case .econtextATM: return "econtext ATM"
        case .boletoBancario: return "boleto bancario"
        case .boletoBancarioSantander: return "boleto bancario santander"
        case .boletoBancarioItau: return "boleto bancario itau"
        case .primeiroPayBoleto: return "primeiro pay boleto"
        case .oxxo: return "OXXO"
        case .bacsDirectDebit: return "BACS direct debit"
        case .achDirectDebit: return "ACH direct debit"
        case .onlineBankingCZ: return "online banking \(localized(country: "CZ"))"
        case .onlineBankingSK: return "online banking \(localized(country: "SK"))"
        case .mealVoucherGroupeUp: return "meal voucher groupe-up"
        case .mealVoucherNatixis: return "meal voucher natixis"
        case .mealVoucherSodexo: return "meal voucher sodexo"
        case .upi: return "UPI"
        case .upiQR: return "UPI QR"
        case .upiIntent: return "UPI Intent"
        case .upiCollect: return "UPI Collect"
        case .cashAppPay: return "cash app"
        case .payByBank: return "Pay by Bank"
        case .payByBankAISDD: return "Pay By Bank Direct Debit"
        default: return rawValue.replacingOccurrences(of: "_", with: " ")
        }
    }
}

private extension PaymentMethodType {
    func localized(country: String) -> String {
        Locale.current.localizedString(forRegionCode: country) ?? country
    }
}
