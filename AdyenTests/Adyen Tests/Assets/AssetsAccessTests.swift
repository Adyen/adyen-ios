//
//  AssetsAccessTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 12/24/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

import XCTest
@testable import Adyen
@testable import AdyenActions

class AssetsAccessTests: XCTestCase {

    func testCoreResourcesAccess() throws {
        XCTAssertNotNil(UIImage(named: "verification_false", in: Bundle.coreInternalResources, compatibleWith: nil))
    }

    func testActionResourcesAccess() throws {
        XCTAssertNotNil(UIImage(named: "mbway", in: Bundle.actionsInternalResources, compatibleWith: nil))
        XCTAssertNotNil(UIImage(named: "blik", in: Bundle.actionsInternalResources, compatibleWith: nil))
    }
}
