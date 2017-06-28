//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Payment method information.
public final class PaymentMethod {
    
    /// Payment method name.
    public let name: String
    
    /// Payment method type.
    public let type: String
    
    /// Indicates if the payment method is One-Click.
    internal(set) public var oneClick: Bool = false
    
    /// Logo URL.
    internal(set) public var logoURL: URL?
    
    /// Input details required for the payment method.
    var inputDetails = [InputDetail]()
    
    /// Members of the payment method.
    internal(set) public var members: [PaymentMethod]?
    
    var txVariant: PaymentMethodType
    var logoBaseURL: String?
    var group: PaymentMethodGroup?
    var paymentMethodData: String?
    var additionalRequiredFields: [String: Any]?
    var providedAdditionalRequiredFields: [String: Any]?
    var configuration: [String: Any]?
    
    lazy var plugin: BasePlugin? = PluginLoader().plugin(for: self)
    
    lazy var groupLogoURL: URL? = {
        guard
            let baseURL = self.logoBaseURL,
            let groupType = self.group?.type
        else {
            return nil
        }
        
        return URL(string: baseURL + groupType + ".png")
    }()
    
    init(name: String, displayName: String, type: String, oneClick: Bool = false) {
        self.name = displayName
        self.type = type
        self.oneClick = oneClick
        txVariant = PaymentMethodType(rawValue: type) ?? .other
        
        members = nil
    }
    
    func isAvailableOnDevice() -> Bool {
        if requiresPlugin() && plugin == nil {
            return false
        }
        
        var available = false
        
        switch name {
        case "Android Pay", "androidpay":
            available = false
        case "Samsung Pay", "samsungpay":
            available = false
        default:
            available = true
        }
        
        if let plugin = plugin as? DeviceDependable {
            available = plugin.isDeviceSupported()
        }
        
        return available
    }
    
    func requiresPlugin() -> Bool {
        return MethodRequiresPlugin(rawValue: txVariant.rawValue) != nil ? true : false
    }
    
    func requiresPaymentData() -> Bool {
        return !inputDetails.isEmpty && plugin?.fullfilledFields() == nil
    }
    
    func canProvideUI() -> Bool {
        guard (plugin as? UIPresentable) != nil else {
            return false
        }
        
        return true
    }
    
    func requiresURLAuth() -> Bool {
        if name == PaymentMethodType.applepay.rawValue {
            return false
        }
        
        return true
    }
}

internal extension PaymentMethod {
    
    convenience init?(info: [String: Any], logoBaseURL: String, oneClick: Bool = false) {
        guard
            let type = info["type"] as? String,
            let data = info["paymentMethodData"] as? String,
            let name = info["name"] as? String
        else {
            return nil
        }
        
        var displayName = name
        
        if let cardInfo = info["card"] as? [String: Any],
            let digits = cardInfo["number"] as? String {
            displayName = "•••• \(digits)"
        } else if let emailInfo = info["emailAddress"] as? String {
            displayName = emailInfo
        }
        
        self.init(name: name, displayName: displayName, type: type, oneClick: oneClick)
        
        paymentMethodData = data
        configuration = info["configuration"] as? [String: Any]
        
        self.logoBaseURL = logoBaseURL
        logoURL = URL(string: logoBaseURL + type + UIScreen.retinaExtension() + ".png")
        
        if let inputDetails = info["inputDetails"] as? [[String: Any]] {
            self.inputDetails = inputDetails.flatMap({ InputDetail(info: $0) })
        }
        
        if let groupInfo = info["group"] as? [String: Any] {
            group = PaymentMethodGroup(info: groupInfo)
        }
    }
    
    convenience init?(group: [PaymentMethod]) {
        guard group.count > 0 else {
            return nil
        }
        
        let method = group[0]
        
        self.init(name: method.group!.name, displayName: method.group!.name, type: method.group!.type)
        
        members = group
        logoURL = method.groupLogoURL
        inputDetails = method.inputDetails
        paymentMethodData = method.group!.data
    }
}

extension PaymentMethod: Equatable {
    
    /// :nodoc:
    public static func ==(lhs: PaymentMethod, rhs: PaymentMethod) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type
    }
}
