//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// Defines types of payment details.
public enum InputType: RawRepresentable, Equatable {
    
    /// Text input type.
    case text
    
    /// Boolean input type.
    case boolean
    
    /// Input type should be selected from the given list.
    case select
    
    /// IBAN input type.
    case iban
    
    /// CVC input type.
    case cvc
    
    /// Card token input type. By default, cvcOptional is false.
    case cardToken(cvcOptional: Bool)
    
    /// Apple Pay token input type.
    case applePayToken
    
    /// Address input type.
    case address
    
    // MARK: - RawRepresentable
    
    /// :nodoc:
    public init?(rawValue: String) {
        if rawValue == "text" {
            self = .text
        } else if rawValue == "boolean" {
            self = .boolean
        } else if rawValue == "select" {
            self = .select
        } else if rawValue == "iban" {
            self = .iban
        } else if rawValue == "cvc" {
            self = .cvc
        } else if rawValue == "cardToken" {
            self = .cardToken(cvcOptional: false)
        } else if rawValue == "applePayToken" {
            self = .applePayToken
        } else if rawValue == "address" {
            self = .address
        } else {
            return nil
        }
    }
    
    /// :nodoc:
    public var rawValue: String {
        switch self {
        case .text:
            return "text"
        case .boolean:
            return "boolean"
        case .select:
            return "select"
        case .iban:
            return "iban"
        case .cvc:
            return "cvc"
        case .cardToken:
            return "cardToken"
        case .applePayToken:
            return "applePayToken"
        case .address:
            return "address"
        }
    }
    
    // MARK: - Equatable
    
    /// :nodoc:
    public static func ==(lhs: InputType, rhs: InputType) -> Bool {
        switch (lhs, rhs) {
        case (.text, .text):
            return true
        case (.boolean, .boolean):
            return true
        case (.select, .select):
            return true
        case (.iban, .iban):
            return true
        case (.cvc, .cvc):
            return true
        case let (.cardToken(a), .cardToken(b)):
            return a == b
        case (.applePayToken, .applePayToken):
            return true
        case (.address, .address):
            return true
        default:
            return false
        }
    }
    
}
