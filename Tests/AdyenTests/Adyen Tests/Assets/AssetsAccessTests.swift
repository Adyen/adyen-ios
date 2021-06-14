//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenActions)
    import AdyenActions
#endif
import XCTest

class AssetsAccessTests: XCTestCase {

    func testCoreResourcesAccess() throws {
        let bundle = Bundle(for: SubmitButton.self)
        XCTAssertNotNil(UIImage(named: "verification_false", in: bundle, compatibleWith: nil))
    }

    func testActionResourcesAccess() throws {
        let bundle = Bundle(for: AdyenActionComponent.self)
        XCTAssertNotNil(UIImage(named: "mbway", in: bundle, compatibleWith: nil))
        XCTAssertNotNil(UIImage(named: "blik", in: bundle, compatibleWith: nil))
    }
}
