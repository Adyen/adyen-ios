//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Represents payment result codes from Adyen's servers.
public enum CheckoutResultCode: RawRepresentable, Decodable, Equatable {
    case authenticationFinished
    case authenticationNotRequired
    case authorised
    case refused
    case pending
    case cancelled
    case error
    case received
    case redirectShopper
    case identifyShopper
    case challengeShopper
    case presentToShopper
    case other(String)
    
    // swiftlint:disable cyclomatic_complexity
    public init(rawValue: String) {
        switch rawValue {
        case "AuthenticationFinished":
            self = .authenticationFinished
        case "AuthenticationNotRequired":
            self = .authenticationNotRequired
        case "Authorised":
            self = .authorised
        case "Refused":
            self = .refused
        case "Pending":
            self = .pending
        case "Cancelled":
            self = .cancelled
        case "Received":
            self = .received
        case "RedirectShopper":
            self = .redirectShopper
        case "IdentifyShopper":
            self = .identifyShopper
        case "ChallengeShopper":
            self = .challengeShopper
        case "PresentToShopper":
            self = .presentToShopper
        default:
            self = .other(rawValue)
        }
    }
    
    public var rawValue: String {
        switch self {
        case .authenticationFinished:
            "AuthenticationFinished"
        case .authenticationNotRequired:
            "AuthenticationNotRequired"
        case .authorised:
            "Authorised"
        case .refused:
            "Refused"
        case .pending:
            "Pending"
        case .cancelled:
            "Cancelled"
        case .error:
            "Error"
        case .received:
            "Received"
        case .redirectShopper:
            "RedirectShopper"
        case .identifyShopper:
            "IdentifyShopper"
        case .challengeShopper:
            "ChallengeShopper"
        case .presentToShopper:
            "PresentToShopper"
        case let .other(code):
            code
        }
    }
}
