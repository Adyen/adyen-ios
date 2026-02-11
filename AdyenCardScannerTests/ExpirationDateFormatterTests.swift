//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCardScanner
import XCTest

final class ExpirationDateFormatterTests: XCTestCase {

    var sut: ExpirationDateFormatter!
    var dateFormatter = DateFormatter()

    override func setUpWithError() throws {
        try super.setUpWithError()
        dateFormatter.dateFormat = "MM/yyyy"
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testDateFromStringWithShortFormatDate() throws {
        // Given
        let stringDate = "03/2028"
        let expectedDate = dateFormatter.date(from: stringDate)

        let shortFormatDate = "03/28"
        sut = ExpirationDateFormatter()

        // When
        let receivedDate = try XCTUnwrap(sut.date(from: shortFormatDate))

        // Then
        XCTAssertEqual(receivedDate, expectedDate)
    }

    func testDateFromStringWithLongFormatDate() throws {
        // Given
        let stringDate = "03/2028"
        let expectedDate = dateFormatter.date(from: stringDate)

        let longFormatDate = "03/2028"
        sut = ExpirationDateFormatter()

        // When
        let receivedDate = try XCTUnwrap(sut.date(from: longFormatDate))

        // Then
        XCTAssertEqual(receivedDate, expectedDate)
    }

    func testDateFromStringWithInvalidFormatDateShouldReturnNil() {
        // Given
        let longFormatDate = "2028/03"
        sut = ExpirationDateFormatter()

        // When
        let receivedDate = sut.date(from: longFormatDate)

        // Then
        XCTAssertNil(receivedDate)
    }

}
