//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable @_spi(AdyenInternal) import Adyen

final class ListItemTests: XCTestCase {
    // Checks COIOS-797: NSInternalInconsistencyException 1008: Item identifiers are not unique
    private let imageURL = URL(string: "https://image.url")!
    
    func test_listItem_isAlwaysUnique() {
        let item1 = ListItem(title: "Test title 11", imageURL: imageURL, trailingText: "Text")
        let item2 = ListItem(title: "Test title 11", imageURL: imageURL, trailingText: "Text")

        XCTAssertNotEqual(item1, item2, "Items used for UITableView sections should be unique even if visually they are identical")
        XCTAssertNotEqual(item1.hashValue, item2.hashValue, "Items hashValues used for UITableViewDiffableDataSource should be unique even if visually they are identical")
    }
}
