//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A follow-up action from the `/payments` response that the SDK handles to complete the payment.
///
/// Decode it from the `action` object of the `/payments` response and pass it to the SDK.
public struct Action: Decodable {

    /// The type of the action.
    public let type: ActionType

    /// The payment data to submit to the `/payments/details` endpoint, if the action has any.
    package let paymentData: String?

    /// The type of the payment method the action belongs to, if the response includes one.
    package let paymentMethodType: PaymentMethodType?

    package let kind: Kind

    /// The action the SDK performs.
    package enum Kind {

        /// The shopper is redirected to a URL.
        case redirect(RedirectAction)

        /// The shopper is redirected to a third party SDK.
        case sdk(SDKAction)

        /// A full 3D Secure 2 flow is executed, including fingerprint collection and potentially a challenge.
        case threeDS2(ThreeDS2Action)

        /// The SDK waits for the shopper to complete the payment out of band.
        case await (AwaitAction)

        /// The SDK waits for the shopper to complete the payment after a redirect.
        case redirectableAwait(RedirectableAwaitAction)

        /// A voucher is presented to the shopper.
        case voucher(VoucherAction)

        /// A QR code is presented to the shopper.
        case qrCode(QRCodeAction)

        /// A document is presented to the shopper.
        case document(DocumentAction)
    }

    package init(
        kind: Kind,
        type: ActionType,
        paymentData: String? = nil,
        paymentMethodType: PaymentMethodType? = nil
    ) {
        self.kind = kind
        self.type = type
        self.paymentData = paymentData
        self.paymentMethodType = paymentMethodType
    }

    // MARK: - Coding

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ActionType.self, forKey: .type)

        self.type = type
        self.paymentData = try? container.decodeIfPresent(String.self, forKey: .paymentData)
        self.paymentMethodType = try? container.decodeIfPresent(PaymentMethodType.self, forKey: .paymentMethodType)

        switch type {
        case .redirect, .nativeRedirect:
            self.kind = try .redirect(RedirectAction(from: decoder))
        case .threeDS2:
            self.kind = try .threeDS2(ThreeDS2Action(from: decoder))
        case .sdk:
            self.kind = try .sdk(SDKAction(from: decoder))
        case .await:
            self.kind = try Self.awaitKind(from: decoder)
        case .voucher:
            self.kind = try Self.voucherKind(from: decoder)
        case .qrCode:
            self.kind = try Self.qrCodeKind(from: decoder)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown action type \(type.rawValue)."
            )
        }
    }

    private static func qrCodeKind(from decoder: Decoder) throws -> Kind {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if (try? container.decode(QRCodePaymentMethodType.self, forKey: .paymentMethodType)) != nil {
            return try .qrCode(QRCodeAction(from: decoder))
        } else {
            return try .redirect(RedirectAction(from: decoder))
        }
    }

    private static func voucherKind(from decoder: Decoder) throws -> Kind {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // extract bacs from others since it is not fully a voucher
        if (try? container.decode(PaymentMethodType.self, forKey: .paymentMethodType)) == .bacsDirectDebit {
            return try .document(DocumentAction(from: decoder))
        } else {
            return try .voucher(VoucherAction(from: decoder))
        }
    }

    private static func awaitKind(from decoder: Decoder) throws -> Kind {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if (try? container.decode(URL.self, forKey: .redirectUrl)) != nil {
            return try .redirectableAwait(RedirectableAwaitAction(from: decoder))
        } else {
            return try .await(AwaitAction(from: decoder))
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case paymentData
        case paymentMethodType
        case redirectUrl = "url"
    }

}

/// Any action that has payment data
package protocol PaymentDataAware {
    var paymentData: String { get }
}
