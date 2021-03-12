//
// Copyright © 2020 Adyen. All rights reserved.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class FormItemViewBuilderTests: XCTestCase {
    
    func testFormPhoneExtensionPickerItemView() {
        let selectableValues = [PhoneExtensionPickerItem(identifier: "test_id", title: "test title", phoneExtension: "test extension")]
        let item = FormPhoneExtensionPickerItem(selectableValues: selectableValues, style: FormTextItemStyle())
        let view = item.build(with: FormItemViewBuilder())
        
        XCTAssertNotNil(view as? FormPhoneExtensionPickerItemView)
    }
    
    func testViewBuildableFormTextItem() {
        let item = FormTextInputItem()
        let view = item.build(with: FormItemViewBuilder())
        
        XCTAssertNotNil(view as? FormTextItemView<FormTextInputItem>)
    }
    
    func testFormSwitchItemView() {
        let item = FormSwitchItem()
        let view = item.build(with: FormItemViewBuilder())
        
        XCTAssertNotNil(view as? FormSwitchItemView)
    }
    
    func testFormSplitItemView() {
        let textItems = [FormTextInputItem(), FormTextInputItem()]
        let item = FormSplitItem(items: textItems, style: FormTextItemStyle())
        let view = item.build(with: FormItemViewBuilder())
        
        XCTAssertNotNil(view as? FormSplitItemView)
    }
    
    func testFormPhoneNumberItemView() {
        let selectableValues = [PhoneExtensionPickerItem(identifier: "test_id", title: "test title", phoneExtension: "test extension")]
        let item = FormPhoneNumberItem(selectableValues: selectableValues, style: FormTextItemStyle())
        let view = item.build(with: FormItemViewBuilder())
        
        XCTAssertNotNil(view as? FormPhoneNumberItemView)
    }
    
}
