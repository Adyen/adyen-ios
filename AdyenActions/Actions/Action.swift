//
// Copyright (c) 2021 Adyen N.V.
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
    case await(AwaitAction)

    /// Indicates that a voucher is presented to the shopper.
    case voucher(VoucherAction)
    
    /// Indicates that a QR code is presented to the shopper.
    case qrCode(QRCodeAction)
    
    // MARK: - Coding
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ActionType.self, forKey: .type)
        
        switch type {
        case .redirect:
            self = .redirect(try RedirectAction(from: decoder))
        case .threeDS2Fingerprint:
            self = .threeDS2Fingerprint(try ThreeDS2FingerprintAction(from: decoder))
        case .threeDS2Challenge:
            self = .threeDS2Challenge(try ThreeDS2ChallengeAction(from: decoder))
        case .threeDS2:
            self = .threeDS2(try ThreeDS2Action(from: decoder))
        case .sdk:
            self = .sdk(try SDKAction(from: decoder))
        case .await:
            self = .await(try AwaitAction(from: decoder))
        case .voucher:
            self = .voucher(try VoucherAction(from: decoder))
        case .qrCode:
            self = try Self.handleQRCodeType(from: decoder)
        }
    }
    
    /// :nodoc:
    private static func handleQRCodeType(from decoder: Decoder) throws -> Action {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if (try? container.decode(QRCodePaymentMethod.self, forKey: .paymentMethodType)) != nil {
            return .qrCode(try QRCodeAction(from: decoder))
        } else {
            return .redirect(try RedirectAction(from: decoder))
        }
    }
    
    private enum ActionType: String, Decodable {
        case redirect
        case threeDS2Fingerprint
        case threeDS2Challenge
        case threeDS2
        case sdk
        case qrCode
        case await
        case voucher
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case paymentMethodType
    }
    
}
