//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal enum PaymentMethodType: String {
    case card
    case scheme
    case ideal
    case entercash
    case eps
    case dotpay
    case openBankingUK = "openbanking_UK"
    case molPayEBankingFPXMY = "molpay_ebanking_fpx_MY"
    case molPayEBankingTH = "molpay_ebanking_TH"
    case molPayEBankingVN = "molpay_ebanking_VN"
    case sepaDirectDebit = "sepadirectdebit"
    case applePay = "applepay"
    case payPal = "paypal"
    case bcmc
}

internal enum AnyPaymentMethodDecoder {
    private static var decoders: [PaymentMethodType: PaymentMethodDecoder] = [
        .card: CardPaymentMethodDecoder(),
        .scheme: CardPaymentMethodDecoder(),
        .ideal: IssuerListPaymentMethodDecoder(),
        .entercash: IssuerListPaymentMethodDecoder(),
        .eps: IssuerListPaymentMethodDecoder(),
        .dotpay: IssuerListPaymentMethodDecoder(),
        .openBankingUK: IssuerListPaymentMethodDecoder(),
        .molPayEBankingFPXMY: IssuerListPaymentMethodDecoder(),
        .molPayEBankingTH: IssuerListPaymentMethodDecoder(),
        .molPayEBankingVN: IssuerListPaymentMethodDecoder(),
        .sepaDirectDebit: SEPADirectDebitPaymentMethodDecoder(),
        .applePay: ApplePayPaymentMethodDecoder(),
        .payPal: PayPalPaymentMethodDecoder(),
        .bcmc: BCMCCardPaymentMethodDecoder()
    ]
    
    private static var defaultDecoder: PaymentMethodDecoder = RedirectPaymentMethodDecoder()
    
    internal static func decode(from decoder: Decoder) -> AnyPaymentMethod {
        do {
            let container = try decoder.container(keyedBy: AnyPaymentMethod.CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            let isStored = decoder.codingPath.contains { $0.stringValue == PaymentMethods.CodingKeys.stored.stringValue }
            let requiresDetails = container.contains(.details)
            let brand = try? container.decode(String.self, forKey: .brand)
            
            // This is a hack to handle stored Bancontact as a separate
            // payment method, even though Bancontact is just another
            // scheme of a card payment method,
            // Since Bancontact doesn't need CVC.
            // Please consider using a composit matching hashable struct,
            // That includes brand, type, isStored, and requiresDetails,
            // This matching struct will be used as the key to the decoders
            // dictionary.
            if isStored, brand == "bcmc", type == "scheme" {
                return try decoders[.bcmc, default: defaultDecoder].decode(from: decoder, isStored: true, requiresDetails: requiresDetails)
            }
            
            let paymentDecoder = PaymentMethodType(rawValue: type).map { decoders[$0, default: defaultDecoder] } ?? defaultDecoder
            
            return try paymentDecoder.decode(from: decoder, isStored: isStored, requiresDetails: requiresDetails)
        } catch {
            return .none
        }
    }
}

private protocol PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool, requiresDetails: Bool) throws -> AnyPaymentMethod
}

private struct CardPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool, requiresDetails: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return .storedCard(try StoredCardPaymentMethod(from: decoder))
        } else {
            return .card(try CardPaymentMethod(from: decoder))
        }
    }
}

private struct BCMCCardPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool, requiresDetails: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return .storedBCMC(try StoredBCMCPaymentMethod(from: decoder))
        } else {
            return .card(try BCMCPaymentMethod(from: decoder))
        }
    }
}

private struct IssuerListPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool, requiresDetails: Bool) throws -> AnyPaymentMethod {
        return .issuerList(try IssuerListPaymentMethod(from: decoder))
    }
}

private struct SEPADirectDebitPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool, requiresDetails: Bool) throws -> AnyPaymentMethod {
        return .sepaDirectDebit(try SEPADirectDebitPaymentMethod(from: decoder))
    }
}

private struct ApplePayPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool, requiresDetails: Bool) throws -> AnyPaymentMethod {
        return .applePay(try ApplePayPaymentMethod(from: decoder))
    }
}

private struct PayPalPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool, requiresDetails: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return .storedPayPal(try StoredPayPalPaymentMethod(from: decoder))
        } else {
            return try RedirectPaymentMethodDecoder().decode(from: decoder, isStored: isStored, requiresDetails: requiresDetails)
        }
    }
}

private struct RedirectPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool, requiresDetails: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return .storedRedirect(try StoredRedirectPaymentMethod(from: decoder))
        } else if !requiresDetails {
            return .redirect(try RedirectPaymentMethod(from: decoder))
        } else {
            return .none
        }
    }
}
