//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCardScanner
import XCTest

final class CardImageParserTests: XCTestCase {

    var expirationDateFormatter: ExpirationDateFormatter
    var sut: CardImageParser!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testExample() throws {
        // Given
        sut = CardImageParser(expirationDateFormatter: <#T##any ExpirationDateFormatting#>)
    }
}
