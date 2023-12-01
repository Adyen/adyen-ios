//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

private extension [PaymentMethodField] {
    var isAnyFieldRequired: Bool {
        contains { $0.isRequired }
    }
}

private struct PaymentMethodField: Decodable {
    
    fileprivate var key: String
    
    fileprivate var type: String
    
    fileprivate var isOptional: Bool?
    
    fileprivate var isRequired: Bool {
        isOptional.map { !$0 } ?? true
    }
    
    private enum CodingKeys: String, CodingKey {
        case key, type, isOptional = "optional"
    }
    
}

internal enum AnyPaymentMethodInterpreter {
    
    private static var interpreters: [PaymentMethodType: PaymentMethodInterpreter] = [

        // Unsupported payment methods
        .bcmcMobileQR: UnsupportedPaymentMethodInterpreter(),
        .weChatMiniProgram: UnsupportedPaymentMethodInterpreter(),
        .weChatQR: UnsupportedPaymentMethodInterpreter(),
        .weChatPayWeb: UnsupportedPaymentMethodInterpreter(),
        .googlePay: UnsupportedPaymentMethodInterpreter(),
        .afterpay: UnsupportedPaymentMethodInterpreter(),
        .androidPay: UnsupportedPaymentMethodInterpreter(),
        .amazonPay: UnsupportedPaymentMethodInterpreter(),
        .bizum: UnsupportedPaymentMethodInterpreter(),

        // Supported payment methods
        .card: CardPaymentMethodInterpreter(),
        .scheme: CardPaymentMethodInterpreter(),
        .ideal: IssuerListPaymentMethodInterpreter(),
        .entercash: IssuerListPaymentMethodInterpreter(),
        .eps: IssuerListPaymentMethodInterpreter(),
        .dotpay: IssuerListPaymentMethodInterpreter(),
        .onlineBankingPoland: IssuerListPaymentMethodInterpreter(),
        .openBankingUK: IssuerListPaymentMethodInterpreter(),
        .molPayEBankingFPXMY: IssuerListPaymentMethodInterpreter(),
        .molPayEBankingTH: IssuerListPaymentMethodInterpreter(),
        .molPayEBankingVN: IssuerListPaymentMethodInterpreter(),
        .sepaDirectDebit: SEPADirectDebitPaymentMethodInterpreter(),
        .bacsDirectDebit: BACSDirectDebitPaymentMethodInterpreter(),
        .achDirectDebit: ACHDirectDebitPaymentMethodInterpreter(),
        .applePay: ApplePayPaymentMethodInterpreter(),
        .payPal: PayPalPaymentMethodInterpreter(),
        .bcmc: BCMCCardPaymentMethodInterpreter(),
        .weChatPaySDK: WeChatPayPaymentMethodInterpreter(),
        .qiwiWallet: QiwiWalletPaymentMethodInterpreter(),
        .mbWay: MBWayPaymentMethodInterpreter(),
        .blik: BLIKPaymentMethodInterpreter(),
        .dokuWallet: DokuPaymentMethodInterpreter(),
        .dokuAlfamart: DokuPaymentMethodInterpreter(),
        .dokuIndomaret: DokuPaymentMethodInterpreter(),
        .giftcard: GiftCardPaymentMethodInterpreter(),
        .mealVoucherSodexo: MealVoucherPaymentMethodInterpreter(),
        .mealVoucherNatixis: MealVoucherPaymentMethodInterpreter(),
        .mealVoucherGroupeUp: MealVoucherPaymentMethodInterpreter(),
        .econtextSevenEleven: SevenElevenPaymentMethodInterpreter(),
        .econtextStores: EContextStoresPaymentMethodInterpreter(),
        .econtextATM: EContextATMPaymentMethodInterpreter(),
        .econtextOnline: EContextOnlinePaymentMethodInterpreter(),
        .boleto: BoletoPaymentMethodInterpreter(),
        .affirm: AffirmPaymentMethodInterpreter(),
        .atome: AtomePaymentMethodInterpreter(),
        .onlineBankingCZ: OnlineBankingPaymentMethodInterpreter(),
        .onlineBankingSK: OnlineBankingPaymentMethodInterpreter(),
        .upi: UPIPaymentMethodInterpreter(),
        .cashAppPay: CashAppPayPaymentMethodInterpreter()
    ]
    
    private static var defaultInterpreter: PaymentMethodInterpreter = InstantPaymentMethodInterpreter()
    
    internal static func decode(from decoder: Decoder) -> AnyPaymentMethod {
        do {
            let container = try decoder.container(keyedBy: AnyPaymentMethod.CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            let isStored = decoder.codingPath.contains { $0.stringValue == PaymentMethods.CodingKeys.stored.stringValue }
            let brand = try? container.decode(String.self, forKey: .brand)
            let isIssuersList = try container.containsValue(.issuers)

            if isIssuersList {
                if type == "onlineBanking_CZ" || type == "onlineBanking_SK" {
                    return try OnlineBankingPaymentMethodInterpreter().decode(from: decoder, isStored: isStored)
                }
                return try IssuerListPaymentMethodInterpreter().decode(from: decoder, isStored: isStored)
            }
            
            // This is a hack to handle stored Bancontact as a separate
            // payment method, even though Bancontact is just another
            // scheme of a card payment method,
            // Since Bancontact doesn't need CVC.
            // Please consider using a composite matching hashable struct,
            // That includes brand, type, isStored, and requiresDetails,
            // This matching struct will be used as the key to the decoders
            // dictionary.
            if isStored, brand == "bcmc", type == "scheme" {
                return try interpreters[.bcmc, default: defaultInterpreter].decode(from: decoder, isStored: true)
            }

            let paymentDecoder = PaymentMethodType(rawValue: type).map { interpreters[$0, default: defaultInterpreter] } ?? defaultInterpreter
            return try paymentDecoder.decode(from: decoder, isStored: isStored)
        } catch {
            return .none
        }
    }
    
    internal static func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod {
        let paymentDecoder = interpreters[paymentMethod.type] ?? defaultInterpreter
        return paymentDecoder.toAnyPaymentMethod(paymentMethod) ?? .instant(paymentMethod)
    }
}

private protocol PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod
    func toAnyPaymentMethod(_ paymentMethod: any PaymentMethod) -> AnyPaymentMethod?
}

private struct CardPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return try .storedCard(StoredCardPaymentMethod(from: decoder))
        } else {
            return try .card(CardPaymentMethod(from: decoder))
        }
    }
    
    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        if let method = paymentMethod as? StoredCardPaymentMethod {
            return .storedCard(method)
        }
        if let method = paymentMethod as? CardPaymentMethod {
            return .card(method)
        }
        return nil
    }
}

private struct BCMCCardPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return try .storedBCMC(StoredBCMCPaymentMethod(from: decoder))
        } else {
            return try .card(BCMCPaymentMethod(from: decoder))
        }
    }
    
    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        if let method = paymentMethod as? StoredBCMCPaymentMethod {
            return .storedBCMC(method)
        }
        if let method = paymentMethod as? BCMCPaymentMethod {
            return .card(method)
        }
        return nil
    }
}

private struct IssuerListPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .issuerList(IssuerListPaymentMethod(from: decoder))
    }
    
    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? IssuerListPaymentMethod).map { .issuerList($0) }
    }
}

private struct SEPADirectDebitPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .sepaDirectDebit(SEPADirectDebitPaymentMethod(from: decoder))
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? SEPADirectDebitPaymentMethod).map { .sepaDirectDebit($0) }
    }
}

private struct BACSDirectDebitPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .bacsDirectDebit(BACSDirectDebitPaymentMethod(from: decoder))
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? BACSDirectDebitPaymentMethod).map { .bacsDirectDebit($0) }
    }
}

private struct ACHDirectDebitPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return try .storedAchDirectDebit(StoredACHDirectDebitPaymentMethod(from: decoder))
        } else {
            return try .achDirectDebit(ACHDirectDebitPaymentMethod(from: decoder))
        }
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        if let method = paymentMethod as? StoredACHDirectDebitPaymentMethod {
            return .storedAchDirectDebit(method)
        }
        if let method = paymentMethod as? ACHDirectDebitPaymentMethod {
            return .achDirectDebit(method)
        }
        return nil
    }
}

private struct ApplePayPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .applePay(ApplePayPaymentMethod(from: decoder))
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? ApplePayPaymentMethod).map { .applePay($0) }
    }
}

private struct PayPalPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return try .storedPayPal(StoredPayPalPaymentMethod(from: decoder))
        } else {
            return try .instant(InstantPaymentMethod(from: decoder))
        }
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        if let method = paymentMethod as? StoredPayPalPaymentMethod {
            return .storedPayPal(method)
        }
        if let method = paymentMethod as? InstantPaymentMethod {
            return .instant(method)
        }
        return nil
    }
}

private struct InstantPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return try .storedInstant(StoredInstantPaymentMethod(from: decoder))
        } else {
            return try .instant(InstantPaymentMethod(from: decoder))
        }
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        if let method = paymentMethod as? StoredInstantPaymentMethod {
            return .storedInstant(method)
        }
        if let method = paymentMethod as? InstantPaymentMethod {
            return .instant(method)
        }
        return nil
    }
}

private struct WeChatPayPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .weChatPay(WeChatPayPaymentMethod(from: decoder))
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? WeChatPayPaymentMethod).map { .weChatPay($0) }
    }
}

private struct UnsupportedPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .none
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        nil
    }
}

private struct QiwiWalletPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .qiwiWallet(QiwiWalletPaymentMethod(from: decoder))
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? QiwiWalletPaymentMethod).map { .qiwiWallet($0) }
    }
}

private struct MBWayPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .mbWay(MBWayPaymentMethod(from: decoder))
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? MBWayPaymentMethod).map { .mbWay($0) }
    }
}

private struct BLIKPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return try .storedBlik(StoredBLIKPaymentMethod(from: decoder))
        } else {
            return try .blik(BLIKPaymentMethod(from: decoder))
        }
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        if let method = paymentMethod as? StoredBLIKPaymentMethod {
            return .storedBlik(method)
        }
        if let method = paymentMethod as? BLIKPaymentMethod {
            return .blik(method)
        }
        return nil
    }
}

private struct DokuPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .doku(DokuPaymentMethod(from: decoder))
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? DokuPaymentMethod).map { .doku($0) }
    }
}

private struct GiftCardPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .giftcard(GiftCardPaymentMethod(from: decoder))
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? GiftCardPaymentMethod).map { .giftcard($0) }
    }
}

private struct MealVoucherPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .mealVoucher(MealVoucherPaymentMethod(from: decoder))
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? MealVoucherPaymentMethod).map { .mealVoucher($0) }
    }
}

private struct SevenElevenPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .sevenEleven(SevenElevenPaymentMethod(from: decoder))
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? SevenElevenPaymentMethod).map { .sevenEleven($0) }
    }
}

private struct EContextStoresPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .econtextStores(EContextPaymentMethod(from: decoder))
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? EContextPaymentMethod).map { .econtextStores($0) }
    }
}

private struct EContextATMPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .econtextATM(EContextPaymentMethod(from: decoder))
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? EContextPaymentMethod).map { .econtextATM($0) }
    }
}

private struct EContextOnlinePaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .econtextOnline(EContextPaymentMethod(from: decoder))
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? EContextPaymentMethod).map { .econtextOnline($0) }
    }
}

private struct BoletoPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .boleto(BoletoPaymentMethod(from: decoder))
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? BoletoPaymentMethod).map { .boleto($0) }
    }
}

private struct AffirmPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .affirm(AffirmPaymentMethod(from: decoder))
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? AffirmPaymentMethod).map { .affirm($0) }
    }
}

private struct AtomePaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .atome(AtomePaymentMethod(from: decoder))
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? AtomePaymentMethod).map { .atome($0) }
    }
}

private struct OnlineBankingPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .onlineBanking(OnlineBankingPaymentMethod(from: decoder))
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? OnlineBankingPaymentMethod).map { .onlineBanking($0) }
    }
}

private struct UPIPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .upi(UPIPaymentMethod(from: decoder))
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? UPIPaymentMethod).map { .upi($0) }
    }
}

private struct CashAppPayPaymentMethodInterpreter: PaymentMethodInterpreter {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        #if canImport(PayKit)
            if isStored {
                return try .storedCashAppPay(StoredCashAppPayPaymentMethod(from: decoder))
            } else {
                return try .cashAppPay(CashAppPayPaymentMethod(from: decoder))
            }
        #else
            return .none
        #endif
    }

    func toAnyPaymentMethod(_ paymentMethod: PaymentMethod) -> AnyPaymentMethod? {
        #if canImport(PayKit)
            if let method = paymentMethod as? StoredCashAppPayPaymentMethod {
                return .storedCashAppPay(method)
            }
            if let method = paymentMethod as? CashAppPayPaymentMethod {
                return .cashAppPay(method)
            }
        #endif
        
        return nil
    }
}
