//
// Copyright (c) 2024 Adyen N.V.
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

// swiftlint:disable file_length
internal enum AnyPaymentMethodDecoder {
    
    private static var decoders: [PaymentMethodType: PaymentMethodDecoder] = [
        // Unsupported payment methods
        .bcmcMobileQR: UnsupportedPaymentMethodDecoder(),
        .weChatMiniProgram: UnsupportedPaymentMethodDecoder(),
        .weChatQR: UnsupportedPaymentMethodDecoder(),
        .weChatPayWeb: UnsupportedPaymentMethodDecoder(),
        .googlePay: UnsupportedPaymentMethodDecoder(),
        .afterpay: UnsupportedPaymentMethodDecoder(),
        .androidPay: UnsupportedPaymentMethodDecoder(),
        .amazonPay: UnsupportedPaymentMethodDecoder(),
        .bizum: UnsupportedPaymentMethodDecoder(),
        .upiQr: UnsupportedPaymentMethodDecoder(),
        .upiIntent: UnsupportedPaymentMethodDecoder(),
        .upiCollect: UnsupportedPaymentMethodDecoder(),
                                                                              
        // Supported payment methods
        .card: CardPaymentMethodDecoder(),
        .scheme: CardPaymentMethodDecoder(),
        .entercash: IssuerListPaymentMethodDecoder(),
        .eps: IssuerListPaymentMethodDecoder(),
        .dotpay: IssuerListPaymentMethodDecoder(),
        .onlineBankingPoland: IssuerListPaymentMethodDecoder(),
        .openBankingUK: IssuerListPaymentMethodDecoder(),
        .molPayEBankingFPXMY: IssuerListPaymentMethodDecoder(),
        .molPayEBankingTH: IssuerListPaymentMethodDecoder(),
        .molPayEBankingVN: IssuerListPaymentMethodDecoder(),
        .sepaDirectDebit: SEPADirectDebitPaymentMethodDecoder(),
        .bacsDirectDebit: BACSDirectDebitPaymentMethodDecoder(),
        .achDirectDebit: ACHDirectDebitPaymentMethodDecoder(),
        .applePay: ApplePayPaymentMethodDecoder(),
        .payPal: PayPalPaymentMethodDecoder(),
        .bcmc: BCMCCardPaymentMethodDecoder(),
        .weChatPaySDK: WeChatPayPaymentMethodDecoder(),
        .qiwiWallet: QiwiWalletPaymentMethodDecoder(),
        .mbWay: MBWayPaymentMethodDecoder(),
        .blik: BLIKPaymentMethodDecoder(),
        .dokuWallet: DokuPaymentMethodDecoder(),
        .dokuAlfamart: DokuPaymentMethodDecoder(),
        .dokuIndomaret: DokuPaymentMethodDecoder(),
        .giftcard: GiftCardPaymentMethodDecoder(),
        .mealVoucherSodexo: MealVoucherPaymentMethodDecoder(),
        .mealVoucherNatixis: MealVoucherPaymentMethodDecoder(),
        .mealVoucherGroupeUp: MealVoucherPaymentMethodDecoder(),
        .econtextSevenEleven: SevenElevenPaymentMethodDecoder(),
        .econtextStores: EContextStoresPaymentMethodDecoder(),
        .econtextATM: EContextATMPaymentMethodDecoder(),
        .econtextOnline: EContextOnlinePaymentMethodDecoder(),
        .boleto: BoletoPaymentMethodDecoder(),
        .affirm: AffirmPaymentMethodDecoder(),
        .atome: AtomePaymentMethodDecoder(),
        .onlineBankingCZ: OnlineBankingPaymentMethodDecoder(),
        .onlineBankingSK: OnlineBankingPaymentMethodDecoder(),
        .upi: UPIPaymentMethodDecoder(),
        .cashAppPay: CashAppPayPaymentMethodDecoder(),
        .twint: TwintPaymentMethodDecoder()
    ]
    
    private static var defaultDecoder: PaymentMethodDecoder = InstantPaymentMethodDecoder()
    
    internal static func decode(from decoder: Decoder) -> AnyPaymentMethod {
        do {
            let container = try decoder.container(keyedBy: AnyPaymentMethod.CodingKeys.self)
            let type = try PaymentMethodType(rawValue: container.decode(String.self, forKey: .type))
            let isStored = decoder.codingPath.contains { $0.stringValue == PaymentMethods.CodingKeys.stored.stringValue }
            let brand = try? container.decode(String.self, forKey: .brand)
            let isIssuersList = try container.containsValue(.issuers)
            
            if type == .ideal {
                return try InstantPaymentMethodDecoder().decode(from: decoder, isStored: isStored)
            }
            
            if isIssuersList {
                if type == .onlineBankingCZ || type == .onlineBankingSK {
                    return try OnlineBankingPaymentMethodDecoder().decode(from: decoder, isStored: isStored)
                }
                
                return try IssuerListPaymentMethodDecoder().decode(from: decoder, isStored: isStored)
            }

            // This is a hack to handle stored Bancontact as a separate
            // payment method, even though Bancontact is just another
            // scheme of a card payment method,
            // Since Bancontact doesn't need CVC.
            // Please consider using a composite matching hashable struct,
            // That includes brand, type, isStored, and requiresDetails,
            // This matching struct will be used as the key to the decoders
            // dictionary.
            if isStored, brand == "bcmc", type == .scheme {
                return try decoders[.bcmc, default: defaultDecoder].decode(from: decoder, isStored: true)
            }
            
            let paymentDecoder = type.map { decoders[$0, default: defaultDecoder] } ?? defaultDecoder
            return try paymentDecoder.decode(from: decoder, isStored: isStored)
        } catch {
            return .none
        }
    }
    
    internal static func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod {
        let paymentDecoder = decoders[paymentMethod.type] ?? defaultDecoder
        return paymentDecoder.anyPaymentMethod(from: paymentMethod) ?? .instant(paymentMethod)
    }
}

private protocol PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod
    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod?
}

private struct CardPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return try .storedCard(StoredCardPaymentMethod(from: decoder))
        } else {
            return try .card(CardPaymentMethod(from: decoder))
        }
    }
    
    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        if let method = paymentMethod as? StoredCardPaymentMethod {
            return .storedCard(method)
        }
        if let method = paymentMethod as? CardPaymentMethod {
            return .card(method)
        }
        return nil
    }
}

private struct BCMCCardPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return try .storedBCMC(StoredBCMCPaymentMethod(from: decoder))
        } else {
            return try .card(BCMCPaymentMethod(from: decoder))
        }
    }
    
    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        if let method = paymentMethod as? StoredBCMCPaymentMethod {
            return .storedBCMC(method)
        }
        if let method = paymentMethod as? BCMCPaymentMethod {
            return .card(method)
        }
        return nil
    }
}

private struct IssuerListPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .issuerList(IssuerListPaymentMethod(from: decoder))
    }
    
    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? IssuerListPaymentMethod).map { .issuerList($0) }
    }
}

private struct SEPADirectDebitPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .sepaDirectDebit(SEPADirectDebitPaymentMethod(from: decoder))
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? SEPADirectDebitPaymentMethod).map { .sepaDirectDebit($0) }
    }
}

private struct BACSDirectDebitPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .bacsDirectDebit(BACSDirectDebitPaymentMethod(from: decoder))
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? BACSDirectDebitPaymentMethod).map { .bacsDirectDebit($0) }
    }
}

private struct ACHDirectDebitPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return try .storedAchDirectDebit(StoredACHDirectDebitPaymentMethod(from: decoder))
        } else {
            return try .achDirectDebit(ACHDirectDebitPaymentMethod(from: decoder))
        }
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        if let method = paymentMethod as? StoredACHDirectDebitPaymentMethod {
            return .storedAchDirectDebit(method)
        }
        if let method = paymentMethod as? ACHDirectDebitPaymentMethod {
            return .achDirectDebit(method)
        }
        return nil
    }
}

private struct ApplePayPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .applePay(ApplePayPaymentMethod(from: decoder))
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? ApplePayPaymentMethod).map { .applePay($0) }
    }
}

private struct PayPalPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return try .storedPayPal(StoredPayPalPaymentMethod(from: decoder))
        } else {
            return try .instant(InstantPaymentMethod(from: decoder))
        }
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        if let method = paymentMethod as? StoredPayPalPaymentMethod {
            return .storedPayPal(method)
        }
        if let method = paymentMethod as? InstantPaymentMethod {
            return .instant(method)
        }
        return nil
    }
}

private struct InstantPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return try .storedInstant(StoredInstantPaymentMethod(from: decoder))
        } else {
            return try .instant(InstantPaymentMethod(from: decoder))
        }
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        if let method = paymentMethod as? StoredInstantPaymentMethod {
            return .storedInstant(method)
        }
        if let method = paymentMethod as? InstantPaymentMethod {
            return .instant(method)
        }
        return nil
    }
}

private struct WeChatPayPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .weChatPay(WeChatPayPaymentMethod(from: decoder))
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? WeChatPayPaymentMethod).map { .weChatPay($0) }
    }
}

private struct UnsupportedPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .none
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        nil
    }
}

private struct QiwiWalletPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .qiwiWallet(QiwiWalletPaymentMethod(from: decoder))
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? QiwiWalletPaymentMethod).map { .qiwiWallet($0) }
    }
}

private struct MBWayPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .mbWay(MBWayPaymentMethod(from: decoder))
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? MBWayPaymentMethod).map { .mbWay($0) }
    }
}

private struct BLIKPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return try .storedBlik(StoredBLIKPaymentMethod(from: decoder))
        } else {
            return try .blik(BLIKPaymentMethod(from: decoder))
        }
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        if let method = paymentMethod as? StoredBLIKPaymentMethod {
            return .storedBlik(method)
        }
        if let method = paymentMethod as? BLIKPaymentMethod {
            return .blik(method)
        }
        return nil
    }
}

private struct DokuPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .doku(DokuPaymentMethod(from: decoder))
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? DokuPaymentMethod).map { .doku($0) }
    }
}

private struct GiftCardPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .giftcard(GiftCardPaymentMethod(from: decoder))
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? GiftCardPaymentMethod).map { .giftcard($0) }
    }
}

private struct MealVoucherPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .mealVoucher(MealVoucherPaymentMethod(from: decoder))
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? MealVoucherPaymentMethod).map { .mealVoucher($0) }
    }
}

private struct SevenElevenPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .sevenEleven(SevenElevenPaymentMethod(from: decoder))
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? SevenElevenPaymentMethod).map { .sevenEleven($0) }
    }
}

private struct EContextStoresPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .econtextStores(EContextPaymentMethod(from: decoder))
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? EContextPaymentMethod).map { .econtextStores($0) }
    }
}

private struct EContextATMPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .econtextATM(EContextPaymentMethod(from: decoder))
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? EContextPaymentMethod).map { .econtextATM($0) }
    }
}

private struct EContextOnlinePaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .econtextOnline(EContextPaymentMethod(from: decoder))
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? EContextPaymentMethod).map { .econtextOnline($0) }
    }
}

private struct BoletoPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .boleto(BoletoPaymentMethod(from: decoder))
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? BoletoPaymentMethod).map { .boleto($0) }
    }
}

private struct AffirmPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .affirm(AffirmPaymentMethod(from: decoder))
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? AffirmPaymentMethod).map { .affirm($0) }
    }
}

private struct AtomePaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .atome(AtomePaymentMethod(from: decoder))
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? AtomePaymentMethod).map { .atome($0) }
    }
}

private struct OnlineBankingPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .onlineBanking(OnlineBankingPaymentMethod(from: decoder))
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? OnlineBankingPaymentMethod).map { .onlineBanking($0) }
    }
}

private struct UPIPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        try .upi(UPIPaymentMethod(from: decoder))
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        (paymentMethod as? UPIPaymentMethod).map { .upi($0) }
    }
}

private struct CashAppPayPaymentMethodDecoder: PaymentMethodDecoder {
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

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
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

private struct TwintPaymentMethodDecoder: PaymentMethodDecoder {

    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        #if canImport(TwintSDK)
            if isStored {
                return try .storedTwint(StoredTwintPaymentMethod(from: decoder))
            } else {
                return try .twint(TwintPaymentMethod(from: decoder))
            }
        #else
            return AnyPaymentMethod(InstantPaymentMethod(type: .twint, name: "Twint"))
        #endif
    }

    func anyPaymentMethod(from paymentMethod: any PaymentMethod) -> AnyPaymentMethod? {
        #if canImport(TwintSDK)
            if let method = paymentMethod as? TwintPaymentMethod {
                return .twint(method)
            }
            if let method = paymentMethod as? StoredTwintPaymentMethod {
                return .storedTwint(method)
            }
        #endif
            
        return nil
    }
}

// swiftlint:enable file_length
