//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

import XCTest
@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@testable import AdyenComponents

class SecuredViewControllerUITests: XCTestCase {
    
    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
    func testBlur() throws {
        // temp deleted
    }
}
