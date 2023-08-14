//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) import AdyenCard
import XCTest

private let placeholderText = "Placeholder"

private class FormSelectableValueItemMock: FormSelectableValueItem<String?> {
    required init() {
        super.init(value: "", style: .init(), placeholder: placeholderText)
    }
}

private class FormSelectableValueItemViewMock: FormSelectableValueItemView<String, FormSelectableValueItemMock> {}

class FormSelectableItemViewTests: XCTestCase {
    
    private var item: FormSelectableValueItemMock!
    private var sut: FormSelectableValueItemViewMock!
    
    override func setUp() {
        item = FormSelectableValueItemMock()
        sut = FormSelectableValueItemViewMock(item: item)
    }
    
    override func tearDown() {
        item = nil
        sut = nil
        
        AdyenAssertion.listener = nil
    }
    
    func testSelectionHandler() {
        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "'selectionHandler' needs to be provided on 'FormSelectableValueItemMock'")
        }
        sut.selectionButtonTapped()
        
        let expectation = expectation(description: "selection handler is called")
        item.selectionHandler = { expectation.fulfill() }
        sut.selectionButtonTapped()
        waitForExpectations(timeout: 1)
    }
    
    func testValueUpdate() {
        
        XCTAssertNil(item.formattedValue)
        XCTAssertEqual(sut.valueLabel.text, placeholderText)
        
        item.formattedValue = ""
        XCTAssertEqual(sut.valueLabel.text, placeholderText)
        
        item.formattedValue = "Hello World"
        XCTAssertEqual(sut.valueLabel.text, item.formattedValue)
    }
}
