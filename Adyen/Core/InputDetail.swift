//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/**
 An object describing a payment detail required to process the transaction.
 The detail has a `type` (`InputType`). If `type` is `.select`, selection should be made from list of `InputSelectItem`.
 The detail value can be set as a string (`stringValue`) or a bool value (`boolValue`).
*/
public class InputDetail {
    
    // MARK: - Initializing
    
    init(type: InputType, key: String, value: String? = nil, optional: Bool = false, items: [InputSelectItem]? = nil, inputDetails: [InputDetail]? = nil, configuration: [String: Any]? = nil) {
        self.type = type
        self.key = key
        self.value = value
        self.optional = optional
        self.items = items
        self.inputDetails = inputDetails
        self.configuration = configuration
    }
    
    convenience init?(info: [String: Any]) {
        //  Type and Key
        guard
            let typeRawValue = info["type"] as? String,
            var type = InputType(rawValue: typeRawValue),
            let key = info["key"] as? String
        else {
            return nil
        }
        
        let configuration = info["configuration"] as? [String: Any]
        
        // cvcOptional
        // For cardToken type, info may contain a configuration object,
        // which may hold additional info about whether or not cvc is allowed to be optional.
        if case .cardToken = type {
            let cvcOptionalString = configuration?["cvcOptional"] as? String
            let cvcOptional = cvcOptionalString?.boolValue() ?? false
            
            type = .cardToken(cvcOptional: cvcOptional)
        }
        
        // Initial value
        let value = info["value"] as? String
        
        //  Optional
        let optionalString = info["optional"] as? String
        let optionalBoolean = info["optional"] as? Bool
        let optional = optionalString?.boolValue() ?? optionalBoolean ?? false
        
        //  Select Items
        var items = [InputSelectItem]()
        if let itemsInfo = info["items"] as? [[String: Any]] {
            for info in itemsInfo {
                if let item = InputSelectItem(info: info) {
                    items.append(item)
                }
            }
        }
        let selectItems: [InputSelectItem]? = items.count > 0 ? items : nil
        
        // Embedded Input Details
        let inputDetails = (info["inputDetails"] as? [[String: Any]])?.flatMap { InputDetail(info: $0) }
        
        self.init(type: type, key: key, value: value, optional: optional, items: selectItems, inputDetails: inputDetails, configuration: configuration)
    }
    
    // MARK: - Accessing Detail Information
    
    /// The detail type. See `InputType`.
    public let type: InputType
    
    /// Whether or not the detail is optional.
    public let optional: Bool
    
    // MARK: - Accessing List of Selectable Items
    
    /// An array of `InputSelectItem`. Only be available if `type` is `.select`.
    public let items: [InputSelectItem]?
    
    // MARK: - Accessing Nested Details
    
    /// An array of input details nested in the receiver.
    public let inputDetails: [InputDetail]?
    
    // MARK: - Managing Input Values
    
    /// Detail string value.
    public var stringValue: String? {
        get {
            return value
        }
        
        set {
            value = newValue
        }
    }
    
    /// Detail bool value.
    public var boolValue: Bool? {
        get {
            return value?.boolValue()
        }
        
        set {
            value = newValue?.stringValue()
        }
    }
    
    // MARK: - Internal
    
    let key: String
    var value: String?
    
    internal let configuration: [String: Any]?
}

// MARK: - Helpers

internal extension Array where Element == InputDetail {
    
    internal subscript(key: String) -> InputDetail? {
        return first { $0.key == key }
    }
    
}
