//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
/// Represents an info event  in the analytics scheme that can occur
/// multiple times during the checkout flow, such as input field focus/unfocus etc.
public struct AnalyticsEventInfo: AnalyticsEvent {
    
    public var id: String = UUID().uuidString
    
    public var timestamp = Int(Date().timeIntervalSince1970)
    
    public var component: String
    
    public var type: InfoType
    
    public var target: AnalyticsEventTarget?
    
    public var isStoredPaymentMethod: Bool?
    
    public var brand: String?
    
    public var issuer: String?
    
    public var validationErrorCode: String?
    
    public var validationErrorMessage: String?
    
    public var configData: AnalyticsStringDictionaryConvertible?

    public enum InfoType: String, Encodable {
        case selected = "Selected"
        case focus = "Focus"
        case unfocus = "Unfocus"
        case validationError = "ValidationError"
        case rendered = "Rendered"
        case input = "Input"
    }
    
    public init(component: String, type: InfoType) {
        self.component = component
        self.type = type
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.timestamp, forKey: .timestamp)
        try container.encode(self.component, forKey: .component)
        try container.encode(self.type, forKey: .type)
        try container.encodeIfPresent(self.target, forKey: .target)
        try container.encodeIfPresent(self.isStoredPaymentMethod, forKey: .isStoredPaymentMethod)
        try container.encodeIfPresent(self.brand, forKey: .brand)
        try container.encodeIfPresent(self.issuer, forKey: .issuer)
        try container.encodeIfPresent(self.validationErrorCode, forKey: .validationErrorCode)
        try container.encodeIfPresent(self.validationErrorMessage, forKey: .validationErrorMessage)
        try container.encodeIfPresent(self.configData?.stringOnlyDictionary, forKey: .configData)
    }
    
    private enum CodingKeys: CodingKey {
        case id
        case timestamp
        case component
        case type
        case target
        case isStoredPaymentMethod
        case brand
        case issuer
        case validationErrorCode
        case validationErrorMessage
        case configData
    }
}

@_spi(AdyenInternal)
/// Protocol that requires a string only dictionary for analytics. Only meant for analytics as it uses mirroring.
public protocol AnalyticsStringDictionaryConvertible: Encodable {
    var stringOnlyDictionary: [String: String]? { get }
}

@_spi(AdyenInternal)
public extension AnalyticsStringDictionaryConvertible {
    var stringOnlyDictionary: [String: String]? {
        var dictionary = [String: String]()
        
        let mirror = Mirror(reflecting: self)
        mirror.children.forEach { child in
            guard let label = child.label, let value = child.value as? LosslessStringConvertible else { return }
            dictionary[label] = String(value)
        }
        return dictionary
    }
}
