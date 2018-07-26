//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A universal plugin for payment methods that require issuer selection, such as iDEAL and MOLPay.
internal final class IssuerSelectionPlugin: Plugin {

    // MARK: - Plugin
    
    override var showsDisclosureIndicator: Bool {
        return true
    }
    
    override func present(using navigationController: UINavigationController, completion: @escaping Completion<[PaymentDetail]>) {
        guard var detail = paymentMethod.details.issuer else { return }
        guard case let .select(selectItems) = detail.inputType else { return }
        
        let items = selectItems.map { issuer -> ListItem in
            var item = ListItem(title: issuer.name)
            item.imageURL = issuer.logoURL
            item.selectionHandler = {
                detail.value = issuer.identifier
                completion([detail])
            }
            
            return item
        }
        
        let listViewController = ListViewController()
        listViewController.title = paymentMethod.name
        listViewController.sections = [ListSection(items: items)]
        
        navigationController.pushViewController(listViewController, animated: true)
    }
    
}
