//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest

extension XCTestCase {

    enum Available {
        static var iOS12: Bool {
            if #available(iOS 12.0, *) {
                return true
            } else {
                return false
            }
        }

        static var iOS13: Bool {
            if #available(iOS 13.0, *) {
                return true
            } else {
                return false
            }
        }

        static var iOS15: Bool {
            if #available(iOS 15.0, *) {
                return true
            } else {
                return false
            }
        }
    }
}
