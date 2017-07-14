//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Represents a locale payment method that can be used to complete a payment.
public final class PaymentMethod {
    
    /// The name of the payment method.
    public let name: String
    
    /// The payment method type.
    public let type: String
    
    /// A Boolean value indicating whether the payment method is a one-click payment method, which means that it can be easily completed by the user.
    public let isOneClick: Bool
    
    /// A URL to the logo of the payment method.
    public let logoURL: URL?
    
    /// The input details that should be filled in to complete the payment method.
    public let inputDetails: [InputDetail]?
    
    /// Members of the payment method (only applicable when the receiver is a group).
    public let members: [PaymentMethod]?
    
    /// The group to which this payment method belongs.
    internal let group: Group?
    
    var txVariant: PaymentMethodType
    var logoBaseURL: String?
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
    
    internal init(name: String, type: String, isOneClick: Bool, logoURL: URL?, inputDetails: [InputDetail]?, members: [PaymentMethod]?, group: Group?) {
        self.name = name
        self.type = type
        self.isOneClick = isOneClick
        self.logoURL = logoURL
        self.inputDetails = inputDetails
        self.members = members
        self.group = group
        self.txVariant = PaymentMethodType(rawValue: type) ?? .other
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
        return inputDetails?.isEmpty == false && plugin?.fullfilledFields() == nil
    }
    
    func requiresURLAuth() -> Bool {
        if name == PaymentMethodType.applepay.rawValue {
            return false
        }
        
        return true
    }
}

internal extension PaymentMethod {
    
    convenience init?(info: [String: Any], logoBaseURL: String, isOneClick: Bool) {
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
        
        let logoURL = URL(string: logoBaseURL + type + UIScreen.retinaExtension() + ".png")
        let inputDetails = (info["inputDetails"] as? [[String: Any]])?.flatMap { InputDetail(info: $0) }
        
        var group: Group?
        if let groupInfo = info["group"] as? [String: Any] {
            group = Group(info: groupInfo)
        }
        
        self.init(name: displayName, type: type, isOneClick: isOneClick, logoURL: logoURL, inputDetails: inputDetails, members: nil, group: group)
        
        paymentMethodData = data
        configuration = info["configuration"] as? [String: Any]
        
        self.logoBaseURL = logoBaseURL
    }
    
    convenience init?(members: [PaymentMethod]) {
        guard members.count > 0 else {
            return nil
        }
        
        let method = members[0]
        let group = method.group!
        
        self.init(name: group.name, type: group.type, isOneClick: false, logoURL: method.groupLogoURL, inputDetails: method.inputDetails, members: members, group: nil)
        
        paymentMethodData = method.group!.data
    }
    
    internal struct Group {
        
        internal let type: String
        
        internal let name: String
        
        internal let data: String
        
        internal init?(info: [String: Any]) {
            guard
                let type = info["type"] as? String,
                let name = info["name"] as? String,
                let data = info["paymentMethodData"] as? String
            else {
                return nil
            }
            
            self.type = type
            self.name = name
            self.data = data
        }
        
    }
    
}

extension PaymentMethod: Equatable {
    
    /// :nodoc:
    public static func ==(lhs: PaymentMethod, rhs: PaymentMethod) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type
    }
}

// MARK: - Deprecated

public extension PaymentMethod {
    
    /// A Boolean value indicating whether the payment method is a one-click payment method, which means that it can be easily completed by the user.
    @available(*, deprecated, message: "Use isOneClick instead.")
    public var oneClick: Bool {
        return isOneClick
    }
    
}
