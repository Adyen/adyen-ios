//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// An object representing a payment method used to complete a payment.
public final class PaymentMethod: Equatable {
    
    // MARK: - Initializing
    
    internal init(name: String, type: String, isOneClick: Bool, oneClickInfo: OneClickInfo?, logoURL: URL?, inputDetails: [InputDetail]?, members: [PaymentMethod]?, group: Group?, paymentMethodData: String) {
        self.name = name
        self.type = type
        self.isOneClick = isOneClick
        self.oneClickInfo = oneClickInfo
        self.logoURL = logoURL
        self.inputDetails = inputDetails
        self.members = members
        self.group = group
        self.paymentMethodData = paymentMethodData
        self.txVariant = PaymentMethodType(rawValue: type) ?? .other
    }
    
    internal convenience init?(info: [String: Any], logoBaseURL: String, isOneClick: Bool) {
        guard
            let type = info["type"] as? String,
            let data = info["paymentMethodData"] as? String,
            let name = info["name"] as? String
        else {
            return nil
        }
        
        var oneClickInfo: OneClickInfo?
        if let cardInfo = info["card"] as? [String: Any] {
            oneClickInfo = CardOneClickInfo(dictionary: cardInfo)
        } else if let emailAddress = info["emailAddress"] as? String, type == "paypal" {
            oneClickInfo = PayPalOneClickInfo(emailAddress: emailAddress)
        }
        
        let logoURL = URL(string: logoBaseURL + type + UIScreen.retinaExtension() + ".png")
        let inputDetailDescriptions = info["inputDetails"] as? [[String: Any]]
        let inputDetails = inputDetailDescriptions?.flatMap { InputDetail(info: $0) }
        
        var group: Group?
        if let groupInfo = info["group"] as? [String: Any] {
            group = Group(info: groupInfo)
        }
        
        self.init(name: name, type: type, isOneClick: isOneClick, oneClickInfo: oneClickInfo, logoURL: logoURL, inputDetails: inputDetails, members: nil, group: group, paymentMethodData: data)
        
        configuration = info["configuration"] as? [String: Any]
        
        self.logoBaseURL = logoBaseURL
    }
    
    internal convenience init?(members: [PaymentMethod]) {
        guard members.count > 0 else {
            return nil
        }
        
        let method = members[0]
        let group = method.group!
        
        self.init(name: group.name, type: group.type, isOneClick: false, oneClickInfo: nil, logoURL: method.groupLogoURL, inputDetails: method.inputDetails, members: members, group: nil, paymentMethodData: group.data)
    }
    
    // MARK: - Equatable
    
    /// :nodoc:
    public static func ==(lhs: PaymentMethod, rhs: PaymentMethod) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type
    }
    
    // MARK: - Accessing Payment Method Information
    
    /// The name of the payment method.
    public let name: String
    
    /// The payment method type.
    public let type: String
    
    /// A URL to the logo of the payment method.
    public let logoURL: URL?
    
    // MARK: - Handling Grouped Payment Methods
    
    /// Members of the payment method (only applicable when the receiver is a group).
    public let members: [PaymentMethod]?
    
    // MARK: - Handling Pre-Stored Information
    
    /// A Boolean value indicating whether the payment method is a one-click payment method, which means that it can be easily completed by the user.
    public let isOneClick: Bool
    
    /// The information that was stored for this payment payment method, or `nil` if this is not a one-click payment method.
    public let oneClickInfo: OneClickInfo?
    
    // MARK: - Managing Required Details
    
    /// The input details that should be filled in to complete the payment.
    public let inputDetails: [InputDetail]?
    
    // MARK: - Internal
    
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
    
    internal let group: Group?
    
    internal let paymentMethodData: String
    
    internal var txVariant: PaymentMethodType
    internal var additionalRequiredFields: [String: Any]?
    internal var providedAdditionalRequiredFields: [String: Any]?
    internal var configuration: [String: Any]?
    internal var fulfilledPaymentDetails: PaymentDetails?
    
    internal func requiresPaymentDetails() -> Bool {
        return inputDetails?.isEmpty == false && fulfilledPaymentDetails == nil
    }
    
    internal var requiresPlugin: Bool {
        return MethodRequiresPlugin(rawValue: txVariant.rawValue) != nil
    }
    
    // MARK: - Private
    
    private var logoBaseURL: String?
    
    private lazy var groupLogoURL: URL? = {
        guard
            let baseURL = self.logoBaseURL,
            let groupType = self.group?.type
        else {
            return nil
        }
        
        return URL(string: baseURL + groupType + ".png")
    }()
    
}

public extension PaymentMethod {
    
    // MARK: - Deprecated
    
    /// A Boolean value indicating whether the payment method is a one-click payment method, which means that it can be easily completed by the user.
    @available(*, deprecated, message: "Use isOneClick instead.")
    public var oneClick: Bool {
        return isOneClick
    }
    
}
