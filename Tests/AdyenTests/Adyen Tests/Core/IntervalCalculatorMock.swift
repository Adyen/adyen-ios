//
//  IntervalCalculatorMock.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 8/11/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenNetworking
import Foundation

internal struct IntervalCalculatorMock: IntervalCalculator {

    var getInterval: (_ counter: UInt) -> DispatchTimeInterval

    func interval(for counter: UInt) -> DispatchTimeInterval {
        getInterval(counter)
    }
}
