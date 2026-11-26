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
    }

    @Test func none_when_resolvingRadius_then_returnsZero() {
        let sut = makeSUT(.none)
        #expect(sut.radius == 0)
    }

    @Test func fixed_when_resolvingRadius_then_returnsAssociatedValue() {
        let sut = makeSUT(.fixed(4))
        #expect(sut.radius == 4)
    }

    @Test func fixedZero_when_resolvingRadius_then_returnsZero() {
        let sut = makeSUT(.fixed(0))
        #expect(sut.radius == 0)
    }

    private func makeSUT(_ rounding: CornerRounding) -> CornerRounding {
        rounding
    }

    @Test func differentValuesAreNotEqual() {
        #expect(CornerRounding.fixed(4) != .fixed(8))
        #expect(CornerRounding.fixed(0) != .none)
    }
}
