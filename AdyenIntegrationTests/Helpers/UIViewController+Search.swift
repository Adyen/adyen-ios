//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import XCTest
@_spi(AdyenInternal) @testable import Adyen

public extension UIViewController {

    /// Returns the first child of the viewControllers children that matches the type
    ///
    /// - Parameters:
    ///  - type: The type of the viewController
    func firstChild<T: UIViewController>(of type: T.Type) -> T? {
        if let result = self as? T {
            return result
        }
        
        for child in self.children {
            if let result = child.firstChild(of: T.self) {
                return result
            }
        }
        
        return nil
    }

    /// Returns the current top viewController
    ///
    /// - Throws: if there is no rootViewController can be found on the window
    static func topPresenter() throws -> UIViewController {
        let rootViewController = try XCTUnwrap(UIApplication.shared.adyen.mainKeyWindow?.rootViewController)
        return rootViewController.adyen.topPresenter
    }
}

extension UIViewController: PresentationDelegate {
    public func present(component: PresentableComponent) {
        self.present(component.viewController, animated: false, completion: nil)
    }
}
