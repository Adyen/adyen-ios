//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

@objc class PaymentManagerResult: NSObject {
    @objc
    public let status: PaymentManagerResultStatus
    
    @objc
    public let error: Swift.Error?
    
    public init(result: Result<PaymentResult>) {
        switch result {
        case let .success(payment):
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
            case .pending:
                self.status = .pending
            }
            
            self.error = nil
        case let .failure(error):
            switch error {
            case PaymentController.Error.cancelled:
                self.status = .cancelled
            default:
                self.status = .error
                break
            }
            
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
    case pending
}
