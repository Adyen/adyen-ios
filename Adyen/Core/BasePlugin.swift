//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

class BasePlugin: NSObject {
    
    weak var method: PaymentMethod?
    
    var completion: ((Data?, Error?, @escaping (PaymentStatus) -> Void) -> Void)?
    var providedHostViewController: UIViewController?
    var paymentRequest: InternalPaymentRequest?
    var providedPaymentData: [String: Any]?
    
    var hostViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
    
    public required override init() {
        super.init()
    }
    
    public func offerRequestInfo() -> [String: Any] {
        var prefilledFields = [String: Any]()
        
        if let request = self.paymentRequest {
            prefilledFields["paymentData"] = request.paymentData
            
            if let paymentMethod = request.paymentMethod,
                let paymentMethodData = paymentMethod.paymentMethodData {
                //  Use group data if available
                prefilledFields["paymentMethodData"] = paymentMethodData
            }
        }
        
        if let offer = self.fullfilledFields() {
            var initiation = offer
            
            if let method = paymentRequest?.paymentMethod,
                let additionalFields = filledAdditionalFields(keys: method.additionalRequiredFields, values: method.providedAdditionalRequiredFields) {
                initiation.formUnion(additionalFields)
            }
            
            prefilledFields["paymentDetails"] = initiation
        }
        
        return prefilledFields
    }
    
    func deleteRequestInfo() -> [String: Any] {
        var info = [String: Any]()
        
        if let request = self.paymentRequest {
            info["paymentData"] = request.paymentData
            
            if let paymentMethod = method,
                let paymentMethodData = paymentMethod.paymentMethodData {
                //  Use group data if available
                info["paymentMethodData"] = paymentMethodData
            }
        }
        
        return info
    }
    
    public func fullfilledFields() -> [String: Any]? {
        return providedPaymentData
    }
    
    func reset() {
        providedPaymentData = nil
    }
}

extension BasePlugin {
    
    func filledAdditionalFields(keys: [String: Any]?, values: [String: Any]?) -> [String: Any]? {
        return values
    }
}
