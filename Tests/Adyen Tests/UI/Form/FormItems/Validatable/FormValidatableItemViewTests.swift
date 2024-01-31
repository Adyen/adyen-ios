//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_documentation(visibility: internal) @testable import Adyen
import AdyenCard
import XCTest

private class FormValidatableValueItemMock: FormValidatableValueItem<String> {
    required init() {
        super.init(value: "", style: .init())
    }
}

private class FormValidatableValueItemViewMock: FormValidatableValueItemView<String, FormValidatableValueItemMock> {}

class FormValidatableItemViewTests: XCTestCase {
    
    private let item = FormValidatableValueItemMock()
    private lazy var sut = FormValidatableValueItemViewMock(item: item)
    
    override func tearDown() {
        AdyenAssertion.listener = nil
    }
    
    func testItemIsValidAssert() {
        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "'isValid()' needs to be implemented on 'FormValidatableValueItemMock'")
        }
        
        _ = item.isValid()
    }
    
    func testItemViewAccessibilityLabelViewAssert() {
        AdyenAssertion.listener = { message in
            XCTAssertEqual(message, "'accessibilityLabelView' needs to be implemented on 'FormValidatableValueItemViewMock'")
        }
        
        sut.resetValidationStatus()
    }
}
