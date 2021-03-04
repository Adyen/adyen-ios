//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

class PresentableComponentMock: PresentableComponent {
    
    var payment: Payment?
    
    var viewController: UIViewController {
        let controll = UIViewController(nibName: nil, bundle: nil)
        controll.title = "Test"
        return controll
    }
    
    func stopLoading(completion: (() -> Void)?) {}
    
    var environment: Environment = .test
}
