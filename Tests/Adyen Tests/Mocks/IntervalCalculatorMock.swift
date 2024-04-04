//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenNetworking
import Foundation

internal struct IntervalCalculatorMock: IntervalCalculator {

    var getInterval: (_ counter: UInt) -> DispatchTimeInterval

    func interval(for counter: UInt) -> DispatchTimeInterval {
        getInterval(counter)
    }
}
