//
// Copyright © 2020 Adyen. All rights reserved.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class FormItemViewBuilderTests: XCTestCase {
    
    func testFormPhoneExtensionPickerItemView() {
        let selectableValues = [PhoneExtensionPickerItem(identifier: "test_id",
                                                         element: .init(title: "test title", phoneExtension: "test extension"))]
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
        let item = FormSplitItem(items: FormTextInputItem(), FormTextInputItem(), style: FormTextItemStyle())
        let view = item.build(with: FormItemViewBuilder())
        
        XCTAssertNotNil(view as? FormSplitItemView)
        XCTAssertEqual(view.childItemViews.count, 2)
    }
    
    func testFormPhoneNumberItemView() {
        let selectableValues = [PhoneExtensionPickerItem(identifier: "test_id", element: .init(title: "test title", phoneExtension: "test extension"))]
        let item = FormPhoneNumberItem(selectableValues: selectableValues, style: FormTextItemStyle())
        let view = item.build(with: FormItemViewBuilder())
        
        XCTAssertNotNil(view as? FormPhoneNumberItemView)
    }

    func testFormSAddressItemViewUS() {
        let item = FormAddressItem(initialCountry: "US", style: AddressStyle())
        let view = item.build(with: FormItemViewBuilder())

        XCTAssertNotNil(view as? FormVerticalStackItemView<FormAddressItem>)
        XCTAssertEqual(view.childItemViews.count, 7)
    }

    func testFormSAddressItemViewNL() {
        let item = FormAddressItem(initialCountry: "NL", style: AddressStyle())
        let view = item.build(with: FormItemViewBuilder())

        XCTAssertNotNil(view as? FormVerticalStackItemView<FormAddressItem>)
        XCTAssertEqual(view.childItemViews.count, 9)
    }

    func testFormSAddressItemViewGB() {
        let item = FormAddressItem(initialCountry: "GB", style: AddressStyle())
        let view = item.build(with: FormItemViewBuilder())

        XCTAssertNotNil(view as? FormVerticalStackItemView<FormAddressItem>)
        XCTAssertEqual(view.childItemViews.count, 8)
    }
    
}
