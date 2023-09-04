//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes a follow-up action that should be taken to complete a payment.
public enum Action: Decodable {
    
    /// Indicates the user should be redirected to a URL.
    case redirect(RedirectAction)
    
    /// Indicates the user should be redirected to an SDK.
    case sdk(SDKAction)
    
    /// Indicates a 3D Secure device fingerprint should be taken.
    case threeDS2Fingerprint(ThreeDS2FingerprintAction)
    
    /// Indicates a 3D Secure challenge should be presented.
    case threeDS2Challenge(ThreeDS2ChallengeAction)

    /// Indicates a full 3D Secure 2 flow should be executed including fingerprint collection,
    /// and potentially a challenge or a fallback to 3DS1.
    case threeDS2(ThreeDS2Action)
    
    /// Indicate that the SDK should wait for user action.
    case await (AwaitAction)

    /// Indicates that a voucher is presented to the shopper.
    case voucher(VoucherAction)
    
    /// Indicates that a QR code is presented to the shopper.
    case qrCode(QRCodeAction)
    
    /// Indicates a document action is presented to the shopper.
    case document(DocumentAction)
    
    // MARK: - Coding
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ActionType.self, forKey: .type)
        
        switch type {
        case .redirect, .nativeRedirect:
            self = try .redirect(RedirectAction(from: decoder))
        case .threeDS2Fingerprint:
            self = try .threeDS2Fingerprint(ThreeDS2FingerprintAction(from: decoder))
        case .threeDS2Challenge:
            self = try .threeDS2Challenge(ThreeDS2ChallengeAction(from: decoder))
        case .threeDS2:
            self = try .threeDS2(ThreeDS2Action(from: decoder))
        case .sdk:
            self = try .sdk(SDKAction(from: decoder))
        case .await:
            self = try .await(AwaitAction(from: decoder))
        case .voucher:
            self = try Self.handleVoucherType(from: decoder)
        case .qrCode:
            self = try Self.handleQRCodeType(from: decoder)
        }
    }
    
    /// :nodoc:
    private static func handleQRCodeType(from decoder: Decoder) throws -> Action {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if (try? container.decode(QRCodePaymentMethod.self, forKey: .paymentMethodType)) != nil {
            return try .qrCode(QRCodeAction(from: decoder))
        } else {
            return try .redirect(RedirectAction(from: decoder))
        }
    }
    
    private static func handleVoucherType(from decoder: Decoder) throws -> Action {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // extract bacs from others since it is not fully a voucher
        if (try? container.decode(String.self, forKey: .paymentMethodType)) == Constant.bacsDirectDebitName {
            return try .document(DocumentAction(from: decoder))
        } else {
            return try .voucher(VoucherAction(from: decoder))
        }
    }
    
    private enum ActionType: String, Decodable {
        case redirect
        case nativeRedirect
        case threeDS2Fingerprint
        case threeDS2Challenge
        case threeDS2
        case sdk
        case qrCode
        case `await`
        case voucher
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case paymentMethodType
    }
    
    private enum Constant {
        static let bacsDirectDebitName = "directdebit_GB"
    }
    
}
