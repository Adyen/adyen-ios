//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import Foundation
import Testing

struct RegionRepositoryTests {

    // MARK: - initialCountryCode

    private static let initialCountryCodeCases: [(supportedCountryCodes: Set<String>?, expected: ExpectedCode)] = [
        (["NL", "US"], .firstSupported),
        (nil, .firstISOCountryCode),
        ([], .none),
        (["XX"], .none)
    ]

    @Test(arguments: Self.initialCountryCodeCases)
    private func initialCountryCode_givenRestrictions_then_returnsExpectedCode(
        supportedCountryCodes: Set<String>?,
        expected: ExpectedCode
    ) {
        let sut = makeSUT(supportedCountryCodes: supportedCountryCodes)

        let expectedCode: String? = switch expected {
        case .firstSupported:
            NSLocale.isoCountryCodes.first { supportedCountryCodes?.contains($0) ?? false }
        case .firstISOCountryCode:
            NSLocale.isoCountryCodes.first
        case .none:
            nil
        }

        #expect(sut == expectedCode)
    }

    // MARK: - regions

    @Test func regions_givenMixedValidAndInvalidRestrictions_then_preservesFoundationOrder() {
        let supportedCountryCodes: Set = ["NL", "XX", "US", "ZZ"]

        let sut = makeSUT(locale: NSLocale(localeIdentifier: "en_US"), supportedCountryCodes: supportedCountryCodes)

        let expectedCodes = NSLocale.isoCountryCodes.filter(supportedCountryCodes.contains)
        #expect(sut.map(\.identifier) == expectedCodes)
    }

    // MARK: - SUT

    private func makeSUT(supportedCountryCodes: Set<String>?) -> String? {
        RegionRepository.initialCountryCode(supportedCountryCodes: supportedCountryCodes)
    }

    private func makeSUT(locale: NSLocale, supportedCountryCodes: Set<String>?) -> [Region] {
        RegionRepository.regions(from: locale, with: supportedCountryCodes)
    }
}

// MARK: - Helpers

private enum ExpectedCode {
    case firstSupported
    case firstISOCountryCode
    case none
}
