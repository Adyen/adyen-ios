//
// Copyright © 2020 Adyen. All rights reserved.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import AdyenActions
@_spi(AdyenInternal) import Adyen
import Foundation

final class ActionComponentDelegateMock: ActionComponentDelegate {
    
    var onDidProvide: ((_ data: ActionComponentData, _ component: ActionComponent) -> Void)?
    
    func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        onDidProvide?(data, component)
    }
    
    var onDidFail: ((_ error: Error, _ component: ActionComponent) -> Void)?
    
    func didFail(with error: Error, from component: ActionComponent) {
        onDidFail?(error, component)
    }

    func didComplete(from component: ActionComponent) {}
    
    var onDidOpenExternalApplication: ((_ component: ActionComponent) -> Void)?
    
    func didOpenExternalApplication(component: ActionComponent) {
        onDidOpenExternalApplication?(component)
    }
}
