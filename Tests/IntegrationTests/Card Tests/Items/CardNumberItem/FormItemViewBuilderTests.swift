//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class FormItemViewBuilderTests: XCTestCase {
    
    func testFormPhoneExtensionPickerItemView() {
        let presenter = UIViewController()
        let selectableValues: [PhoneExtension] = [.init(value: "+31", countryCode: "NL")]
        let item = FormPhoneExtensionPickerItem(
            preselectedExtension: selectableValues[0],
            selectableExtensions: selectableValues,
            validationFailureMessage: nil,
            style: .init(),
            presenter: .init(presenter)
        )
        let view = item.build(with: FormItemViewBuilder())
        
        XCTAssertNotNil(view as? FormPhoneExtensionPickerItemView)
    }
    
    func testViewBuildableFormTextItem() {
        let item = FormTextInputItem()
        let view = item.build(with: FormItemViewBuilder())
        
        XCTAssertNotNil(view as? FormTextItemView<FormTextInputItem>)
    }
    
    func testFormToggleItemView() {
        let item = FormToggleItem()
        let view = item.build(with: FormItemViewBuilder())
        
        XCTAssertNotNil(view as? FormToggleItemView)
    }
    
    func testFormSplitItemView() {
        let item = FormSplitItem(items: FormTextInputItem(), FormTextInputItem(), style: FormTextItemStyle())
        let view = item.build(with: FormItemViewBuilder())
        
        XCTAssertNotNil(view as? FormSplitItemView)
        XCTAssertEqual(view.childItemViews.count, 2)
    }
    
    func testFormPhoneNumberItemView() {
        let presenter = UIViewController()
        let selectableValues: [PhoneExtension] = [.init(value: "+31", countryCode: "NL")]
        let item = FormPhoneNumberItem(
            phoneNumber: nil,
            selectableValues: selectableValues,
            style: .init(),
            presenter: .init(presenter)
        )
        let view = item.build(with: FormItemViewBuilder())
        
        XCTAssertNotNil(view as? FormPhoneNumberItemView)
    }

    func testFormSAddressItemViewUS() {
        let item = FormAddressItem(
            initialCountry: "US",
            configuration: .init(),
            presenter: nil,
            addressViewModelBuilder: DefaultAddressViewModelBuilder()
        )
        let view = item.build(with: FormItemViewBuilder())

        XCTAssertNotNil(view as? FormVerticalStackItemView<FormAddressItem>)
        XCTAssertEqual(view.childItemViews.count, 7)
    }

    func testFormSAddressItemViewNL() {
        let item = FormAddressItem(
            initialCountry: "NL",
            configuration: .init(),
            presenter: nil,
            addressViewModelBuilder: DefaultAddressViewModelBuilder()
        )
        let view = item.build(with: FormItemViewBuilder())

        XCTAssertNotNil(view as? FormVerticalStackItemView<FormAddressItem>)
        XCTAssertEqual(view.childItemViews.count, 9)
    }

    func testFormSAddressItemViewGB() {
        let item = FormAddressItem(
            initialCountry: "GB",
            configuration: .init(),
            presenter: nil,
            addressViewModelBuilder: DefaultAddressViewModelBuilder()
        )
        let view = item.build(with: FormItemViewBuilder())

        XCTAssertNotNil(view as? FormVerticalStackItemView<FormAddressItem>)
        XCTAssertEqual(view.childItemViews.count, 7)
    }
    
}
