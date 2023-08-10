//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import XCTest
@_spi(AdyenInternal) @testable import Adyen

extension XCTestCase {
    
    func setupRootViewController(_ viewController: UIViewController) throws {
        let window = try XCTUnwrap(UIApplication.shared.adyen.mainKeyWindow)
        window.rootViewController = viewController
        window.layer.speed = 10 // 10x Animation speed
        wait(for: .aMoment) // Waiting for a moment to give the viewController time to be presented
    }
}

extension DispatchTimeInterval {
    
    /// .milliseconds(50)
    static var aMoment: Self { .milliseconds(50) }
}
