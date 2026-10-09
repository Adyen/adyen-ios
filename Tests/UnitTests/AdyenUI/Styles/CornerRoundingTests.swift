//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenUI
import Testing

struct CornerRoundingTests {

    @Test func noneEqualsNone() {
        #expect(CornerRounding.none == .none)
    }

    @Test func sameValuesAreEqual() {
        #expect(CornerRounding.fixed(4) == .fixed(4))
        #expect(CornerRounding.percent(0.5) == .percent(0.5))
    }

    @Test func differentValuesAreNotEqual() {
        #expect(CornerRounding.fixed(4) != .fixed(8))
        #expect(CornerRounding.percent(0.25) != .percent(0.5))
        #expect(CornerRounding.fixed(0) != .none)
        #expect(CornerRounding.fixed(0.5) != .percent(0.5))
    }
}
