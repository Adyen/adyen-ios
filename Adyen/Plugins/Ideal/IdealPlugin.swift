//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

class IdealPlugin: BasePlugin {
    var presenter: IdealDetailsPresenter?
    
    override func reset() {
        super.reset()
        presenter?.issuerPickerViewController?.reset()
    }
}

extension IdealPlugin: UIPresentable {
    
    func detailsPresenter() -> PaymentMethodDetailsPresenter? {
        guard
            let details = paymentRequest?.paymentMethod?.inputDetails,
            let items = issuersDetail(from: details)?.items
        else {
            fail(with: nil)
            return nil
        }
        
        presenter = IdealDetailsPresenter(items: items)
        return presenter
    }
    
    func issuersDetail(from details: [InputDetail]) -> InputDetail? {
        return details.filter({ $0.type == .select }).first
    }
    
    func fail(with error: Error?) {
        completion?(nil, error) { _ in }
    }
}
