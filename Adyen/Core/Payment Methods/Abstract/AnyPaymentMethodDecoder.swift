//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

private extension Array where Element == PaymentMethodField {
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
        
        // Supported payment methods
        .card: CardPaymentMethodDecoder(),
        .scheme: CardPaymentMethodDecoder(),
        .ideal: IssuerListPaymentMethodDecoder(),
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
        .econtextSevenEleven: SevenElevenPaymentMethodDecoder(),
        .econtextStores: EContextStoresPaymentMethodDecoder(),
        .econtextATM: EContextATMPaymentMethodDecoder(),
        .econtextOnline: EContextOnlinePaymentMethodDecoder(),
        .boleto: BoletoPaymentMethodDecoder(),
        .affirm: AffirmPaymentMethodDecoder(),
        .atome: AtomePaymentMethodDecoder(),
        .onlineBankingCZ: OnlineBankingPaymentMethodDecoder(),
        .onlineBankingSK: OnlineBankingPaymentMethodDecoder()
    ]
    
    private static var defaultDecoder: PaymentMethodDecoder = InstantPaymentMethodDecoder()
    
    internal static func decode(from decoder: Decoder) -> AnyPaymentMethod {
        do {
            let container = try decoder.container(keyedBy: AnyPaymentMethod.CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            let isStored = decoder.codingPath.contains { $0.stringValue == PaymentMethods.CodingKeys.stored.stringValue }
            let brand = try? container.decode(String.self, forKey: .brand)
            let isIssuersList = try container.containsValue(.issuers)

            if isIssuersList {
                if type == "onlineBanking_CZ" || type == "onlineBanking_SK" {
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
            if isStored, brand == "bcmc", type == "scheme" {
                return try decoders[.bcmc, default: defaultDecoder].decode(from: decoder, isStored: true)
            }

            let paymentDecoder = PaymentMethodType(rawValue: type).map { decoders[$0, default: defaultDecoder] } ?? defaultDecoder
            return try paymentDecoder.decode(from: decoder, isStored: isStored)
        } catch {
            return .none
        }
    }
}

private protocol PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod
}

private struct CardPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return .storedCard(try StoredCardPaymentMethod(from: decoder))
        } else {
            return .card(try CardPaymentMethod(from: decoder))
        }
    }
}

private struct BCMCCardPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return .storedBCMC(try StoredBCMCPaymentMethod(from: decoder))
        } else {
            return .card(try BCMCPaymentMethod(from: decoder))
        }
    }
}

private struct IssuerListPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .issuerList(try IssuerListPaymentMethod(from: decoder))
    }
}

private struct SEPADirectDebitPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .sepaDirectDebit(try SEPADirectDebitPaymentMethod(from: decoder))
    }
}

private struct BACSDirectDebitPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .bacsDirectDebit(try BACSDirectDebitPaymentMethod(from: decoder))
    }
}

private struct ACHDirectDebitPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return .storedAchDirectDebit(try StoredACHDirectDebitPaymentMethod(from: decoder))
        } else {
            return .achDirectDebit(try ACHDirectDebitPaymentMethod(from: decoder))
        }
    }
}

private struct ApplePayPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .applePay(try ApplePayPaymentMethod(from: decoder))
    }
}

private struct PayPalPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return .storedPayPal(try StoredPayPalPaymentMethod(from: decoder))
        } else {
            return .instant(try InstantPaymentMethod(from: decoder))
        }
    }
}

private struct InstantPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return .storedInstant(try StoredInstantPaymentMethod(from: decoder))
        } else {
            return .instant(try InstantPaymentMethod(from: decoder))
        }
    }
}

private struct WeChatPayPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .weChatPay(try WeChatPayPaymentMethod(from: decoder))
    }
}

private struct UnsupportedPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .none
    }
}

private struct QiwiWalletPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .qiwiWallet(try QiwiWalletPaymentMethod(from: decoder))
    }
}

private struct MBWayPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .mbWay(try MBWayPaymentMethod(from: decoder))
    }
}

private struct BLIKPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        if isStored {
            return .storedBlik(try StoredBLIKPaymentMethod(from: decoder))
        } else {
            return .blik(try BLIKPaymentMethod(from: decoder))
        }
    }
}

private struct DokuPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .doku(try DokuPaymentMethod(from: decoder))
    }
}

private struct GiftCardPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .giftcard(try GiftCardPaymentMethod(from: decoder))
    }
}

private struct SevenElevenPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .sevenEleven(try SevenElevenPaymentMethod(from: decoder))
    }
}

private struct EContextStoresPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .econtextStores(try EContextPaymentMethod(from: decoder))
    }
}

private struct EContextATMPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .econtextATM(try EContextPaymentMethod(from: decoder))
    }
}

private struct EContextOnlinePaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .econtextOnline(try EContextPaymentMethod(from: decoder))
    }
}

private struct BoletoPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .boleto(try BoletoPaymentMethod(from: decoder))
    }
}

private struct AffirmPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .affirm(try AffirmPaymentMethod(from: decoder))
    }
}

private struct AtomePaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .atome(try AtomePaymentMethod(from: decoder))
    }
}

private struct OnlineBankingPaymentMethodDecoder: PaymentMethodDecoder {
    func decode(from decoder: Decoder, isStored: Bool) throws -> AnyPaymentMethod {
        .onlineBanking(try OnlineBankingPaymentMethod(from: decoder))
    }
}
