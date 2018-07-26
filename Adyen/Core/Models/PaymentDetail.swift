//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A detail which should be filled in order to complete a payment.
public struct PaymentDetail: Decodable {
    /// The key of the payment detail.
    public let key: String
    
    /// The current value of the payment detail.
    public var value: String?
    
    /// The type of input requested.
    public internal(set) var inputType: InputType
    
    /// A boolean value indicating whether filling this payment detail is optional.
    public let isOptional: Bool
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or if the data read is corrupted or otherwise invalid.
    ///
    /// :nodoc:
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.key = try container.decode(String.self, forKey: .key)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        self.isOptional = try container.decodeIfPresent(Bool.self, forKey: .isOptional) ?? false
        
        do {
            self.inputType = try InputType(from: decoder)
        } catch {
            self.inputType = .text
        }
    }
    
    /// Initializes a payment detail instance.
    ///
    /// - Parameters:
    ///   - key: The key of the payment detail.
    ///   - value: The current value of the payment detail.
    ///   - inputType: The type of input requested.
    ///   - isOptional: A boolean value indicating whether filling this payment detail is optional.
    ///   - selectItems: An array of possible values to choose from. Present when inputType is select.
    internal init(key: String, value: String? = nil, inputType: InputType = .text, isOptional: Bool = false) {
        self.key = key
        self.value = value
        self.inputType = inputType
        self.isOptional = isOptional
    }
    
    // MARK: - Coding Keys
    
    private enum CodingKeys: String, CodingKey {
        case key
        case value
        case isOptional = "optional"
    }
    
}

// MARK: - PaymentDetail.InputType

public extension PaymentDetail {
    /// Enum specifying the type of input requested.
    public enum InputType: Decodable, Equatable {
        /// Text input type.
        case text
        
        /// Boolean input type.
        case boolean
        
        /// Select input type. Input should be selected from the given list.
        case select([SelectItem])
        
        /// IBAN input type.
        case iban
        
        /// Card token input type.
        case cardToken
        
        /// Apple Pay token input type.
        case applePayToken
        
        /// Address input type.
        case address
        
        /// :nodoc:
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .inputType)
            switch type {
            case "text":
                self = .text
            case "boolean":
                self = .boolean
            case "select":
                let selectItems = try container.decode([SelectItem].self, forKey: .selectItems)
                
                self = .select(selectItems)
            case "iban":
                self = .iban
            case "cardToken":
                self = .cardToken
            case "applePayToken":
                self = .applePayToken
            case "address":
                self = .address
            default:
                let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown value (\(type)) for input type.")
                
                throw DecodingError.dataCorrupted(context)
            }
        }
        
        // MARK: - Coding Keys
        
        private enum CodingKeys: String, CodingKey {
            case inputType = "type"
            case selectItems = "items"
        }
        
        // MARK: - Equatable
        
        /// :nodoc:
        public static func == (lhs: PaymentDetail.InputType, rhs: PaymentDetail.InputType) -> Bool {
            switch (lhs, rhs) {
            case (.text, .text):
                return true
            case (.boolean, .boolean):
                return true
            case let (.select(lhsItems), .select(rhsItems)):
                return lhsItems == rhsItems
            case (.iban, .iban):
                return true
            case (.cardToken, .cardToken):
                return true
            case (.applePayToken, .applePayToken):
                return true
            case (.address, .address):
                return true
            default:
                return false
            }
        }
        
    }
    
}

// MARK: - PaymentDetail.SelectItem

public extension PaymentDetail {
    /// A structure representing a selectable value for payment details with type `select`.
    public struct SelectItem: Decodable, Equatable {
        /// A string uniquely identifying the select item.
        public let identifier: String
        
        /// The name of the select item.
        public let name: String
        
        /// A logo URL for the select item, applicable when the select item represents an issuer.
        public internal(set) var logoURL: URL?
        
        private enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case name
        }
        
    }
    
}
