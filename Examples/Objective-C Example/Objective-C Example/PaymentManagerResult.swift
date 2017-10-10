//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import Adyen

@objc class PaymentManagerResult: NSObject {
    
    @objc
    public let status: PaymentManagerResultStatus
    
    @objc
    public let error: Swift.Error?
    
    public init(result: PaymentRequestResult) {
        switch result {
        case let .payment(payment):
            switch payment.status {
            case .received:
                self.status = .received
            case .authorised:
                self.status = .authorised
            case .refused:
                self.status = .refused
            case .cancelled:
                self.status = .cancelled
            case .error:
                self.status = .error
            }
            
            self.error = nil
        case let .error(error):
            self.status = .error
            self.error = error
        }
        
        super.init()
    }
    
}

@objc enum PaymentManagerResultStatus: Int {
    case received
    case authorised
    case refused
    case cancelled
    case error
}
