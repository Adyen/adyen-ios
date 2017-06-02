//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/**
 The payment detail needed for the transaction.
 The detail has a `type` (`InputType`). If `type` is `.select`, a list of `InputSelectItem` will be available for selection in the `items` variable.
 The detail might be `optional`.
 The detail value can be set as a string (`stringValue`) or a bool value (`boolValue`).
*/
public class InputDetail {
    let key: String
    var value: String?
    
    /// The detail type. Check `InputType`.
    public let type: InputType
    
    /// Whether the detail is optional.
    public let optional: Bool
    
    /// Array of `InputSelectItem`. Will only be available if `type` is `.select`.
    public let items: [InputSelectItem]?
    
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
    
    init(type: InputType, key: String, optional: Bool = false, items: [InputSelectItem]? = nil) {
        self.type = type
        self.key = key
        self.optional = optional
        self.items = items
    }
    
    convenience init?(info: [String: Any]) {
        //  Type and Key
        guard
            let typeRawValue = info["type"] as? String,
            let type = InputType(rawValue: typeRawValue),
            let key = info["key"] as? String
        else {
            return nil
        }
        
        //  Optional
        let optional = info["optional"] as? Bool ?? false
        
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
        
        self.init(type: type, key: key, optional: optional, items: selectItems)
    }
}
