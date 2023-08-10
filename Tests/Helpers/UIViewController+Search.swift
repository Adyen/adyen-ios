//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import XCTest
@_spi(AdyenInternal) @testable import Adyen

public extension UIViewController {

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

    static func topPresenter() throws -> UIViewController {
        let rootViewController = try XCTUnwrap(UIApplication.shared.adyen.mainKeyWindow?.rootViewController)
        return rootViewController.adyen.topPresenter
    }
}
