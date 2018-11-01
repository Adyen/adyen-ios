//
// Copyright (c) 2018 Adyen B.V.
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
    
    internal var showsDisclosureIndicator: Bool {
        return true
    }
    
    internal func present(_ details: [PaymentDetail], using navigationController: UINavigationController, appearance: Appearance, completion: @escaping Completion<[PaymentDetail]>) {
        guard var issuerDetail = details.issuer else { return }
        guard case let .select(selectItems) = issuerDetail.inputType else { return }
        
        let items = selectItems.map { issuer -> ListItem in
            var item = ListItem(title: issuer.name)
            item.imageURL = issuer.logoURL
            item.selectionHandler = {
                issuerDetail.value = issuer.identifier
                completion([issuerDetail])
            }
            
            return item
        }
        
        let listViewController = ListViewController()
        listViewController.title = paymentMethod.name
        listViewController.sections = [ListSection(items: items)]
        
        navigationController.pushViewController(listViewController, animated: true)
    }
    
}
