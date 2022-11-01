//
//  XCTestCaseExtensions.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 12/1/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import UIKit
import XCTest

extension XCTestCase {
    func wait(for interval: DispatchTimeInterval) {
        let dummyExpectation = XCTestExpectation(description: "wait for a few seconds.")

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval) {
            dummyExpectation.fulfill()
        }

        wait(for: [dummyExpectation], timeout: 100)
    }
    
    func waitFor(predicate: @escaping () -> Bool) {
        let dummyExpectation = XCTNSPredicateExpectation(predicate: NSPredicate(block: { _, _ in
            predicate()
        }), object: nil)

        wait(for: [dummyExpectation], timeout: 100)
    }
}
