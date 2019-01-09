//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A universal plugin for payment methods that require issuer selection, such as iDEAL and MOLPay.
internal final class IssuerSelectionPlugin: Plugin {
    
    internal let paymentSession: PaymentSession
    internal let paymentMethod: PaymentMethod
    
    internal init(paymentSession: PaymentSession, paymentMethod: PaymentMethod) {
        self.paymentSession = paymentSession
        self.paymentMethod = paymentMethod
    }
    
}

// MARK: - PaymentDetailsPlugin

extension IssuerSelectionPlugin: PaymentDetailsPlugin {
    
    internal var canSkipPaymentMethodSelection: Bool {
        return true
    }
    
    internal var preferredPresentationMode: PaymentDetailsPluginPresentationMode {
        return .push
    }
    
    internal func viewController(for details: [PaymentDetail], appearance: Appearance, completion: @escaping Completion<[PaymentDetail]>) -> UIViewController {
        let items = issuerSelectItems(for: details).map { issuer -> ListItem in
            var item = ListItem(title: issuer.name)
            item.imageURL = issuer.logoURL
            item.selectionHandler = {
                var details = details
                details.issuer?.value = issuer.identifier
                completion(details)
            }
            
            return item
        }
        
        let listViewController = ListViewController()
        listViewController.title = paymentMethod.name
        listViewController.sections = [ListSection(items: items)]
        return listViewController
    }
    
    private func issuerSelectItems(for details: [PaymentDetail]) -> [PaymentDetail.SelectItem] {
        guard let issuerDetail = details.issuer else { return [] }
        guard case let .select(selectItems) = issuerDetail.inputType else { return [] }
        
        return selectItems
    }
    
}
