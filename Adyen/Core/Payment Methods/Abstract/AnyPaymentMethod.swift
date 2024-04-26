//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal enum AnyPaymentMethod: Codable {
    case storedInstant(StoredInstantPaymentMethod)
    case storedCard(StoredCardPaymentMethod)
    case storedPayPal(StoredPayPalPaymentMethod)
    case storedBCMC(StoredBCMCPaymentMethod)
    case storedBlik(StoredBLIKPaymentMethod)
    case storedAchDirectDebit(StoredACHDirectDebitPaymentMethod)
    case storedCashAppPay(StoredCashAppPayPaymentMethod)
    
    case instant(PaymentMethod)
    case card(AnyCardPaymentMethod)
    case issuerList(IssuerListPaymentMethod)
    case sepaDirectDebit(SEPADirectDebitPaymentMethod)
    case bacsDirectDebit(BACSDirectDebitPaymentMethod)
    case achDirectDebit(ACHDirectDebitPaymentMethod)
    case applePay(ApplePayPaymentMethod)
    case qiwiWallet(QiwiWalletPaymentMethod)
    case weChatPay(WeChatPayPaymentMethod)
    case mbWay(MBWayPaymentMethod)
    case blik(BLIKPaymentMethod)
    case giftcard(GiftCardPaymentMethod)
    case mealVoucher(MealVoucherPaymentMethod)
    case doku(DokuPaymentMethod)
    case sevenEleven(SevenElevenPaymentMethod)
    case econtextStores(EContextPaymentMethod)
    case econtextATM(EContextPaymentMethod)
    case econtextOnline(EContextPaymentMethod)
    case boleto(BoletoPaymentMethod)
    case affirm(AffirmPaymentMethod)
    case atome(AtomePaymentMethod)
    case onlineBanking(OnlineBankingPaymentMethod)
    case upi(UPIPaymentMethod)
    case cashAppPay(CashAppPayPaymentMethod)
    case twint(TwintPaymentMethod)

    case none
    
    internal var value: PaymentMethod? {
        switch self {
        case let .storedCard(paymentMethod): return paymentMethod
        case let .storedPayPal(paymentMethod): return paymentMethod
        case let .storedBCMC(paymentMethod): return paymentMethod
        case let .instant(paymentMethod): return paymentMethod
        case let .storedInstant(paymentMethod): return paymentMethod
        case let .storedAchDirectDebit(paymentMethod): return paymentMethod
        case let .storedCashAppPay(paymentMethod): return paymentMethod
        case let .card(paymentMethod): return paymentMethod
        case let .issuerList(paymentMethod): return paymentMethod
        case let .sepaDirectDebit(paymentMethod): return paymentMethod
        case let .bacsDirectDebit(paymentMethod): return paymentMethod
        case let .achDirectDebit(paymentMethod): return paymentMethod
        case let .applePay(paymentMethod): return paymentMethod
        case let .qiwiWallet(paymentMethod): return paymentMethod
        case let .weChatPay(paymentMethod): return paymentMethod
        case let .mbWay(paymentMethod): return paymentMethod
        case let .blik(paymentMethod): return paymentMethod
        case let .storedBlik(paymentMethod): return paymentMethod
        case let .doku(paymentMethod): return paymentMethod
        case let .giftcard(paymentMethod): return paymentMethod
        case let .mealVoucher(paymentMethod): return paymentMethod
        case let .sevenEleven(paymentMethod): return paymentMethod
        case let .econtextStores(paymentMethod): return paymentMethod
        case let .econtextATM(paymentMethod): return paymentMethod
        case let .econtextOnline(paymentMethod): return paymentMethod
        case let .boleto(paymentMethod): return paymentMethod
        case let .affirm(paymentMethod): return paymentMethod
        case let .atome(paymentMethod): return paymentMethod
        case let .onlineBanking(paymentMethod): return paymentMethod
        case let .upi(paymentMethod): return paymentMethod
        case let .cashAppPay(paymentMethod): return paymentMethod
        case let .twint(paymentMethod): return paymentMethod
        case .none: return nil
        }
    }

    // MARK: - Decoding

    internal init(from decoder: Decoder) throws {
        self = AnyPaymentMethodDecoder.decode(from: decoder)
    }

    internal func encode(to encoder: Encoder) throws {
        try value?.encode(to: encoder)
    }

    internal enum CodingKeys: String, CodingKey {
        case type
        case details
        case brand
        case issuers
    }
}

extension AnyPaymentMethod {
    
    init(_ paymentMethod: PaymentMethod) {
        self = AnyPaymentMethodDecoder.anyPaymentMethod(from: paymentMethod)
    }
}

extension PaymentMethod {
    
    var toAnyPaymentMethod: AnyPaymentMethod {
        .init(self)
    }
}
