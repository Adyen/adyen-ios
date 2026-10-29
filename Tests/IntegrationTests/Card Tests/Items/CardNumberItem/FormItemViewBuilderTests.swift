//
// Copyright (c) 2020 Adyen N.V.
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
        XCTAssertFalse(item.allowsSelection)
    }
    
    func testPhoneExtensionMultiple() {
        let presenter = UIViewController()
        let query = PhoneExtensionsQuery(paymentMethod: .generic)
        let selectableValues = PhoneExtensionsRepository.get(with: query)
        let item = FormPhoneExtensionPickerItem(
            preselectedExtension: selectableValues[0],
            selectableExtensions: selectableValues,
            validationFailureMessage: nil,
            style: .init(),
            presenter: .init(presenter)
        )
        let view = item.build(with: FormItemViewBuilder())
        
        XCTAssertNotNil(view as? FormPhoneExtensionPickerItemView)
        XCTAssertTrue(item.allowsSelection)
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

    func testToggleExposesOnlyTheLabeledNativeSwitch() throws {
        let item = FormToggleItem()
        item.title = "Remember for next time"
        item.identifier = "toggle"
        let view = FormToggleItemView(item: item)
        let label = try XCTUnwrap(view.findView(with: "toggle.titleLabel") as UILabel?)

        XCTAssertFalse(view.isAccessibilityElement)
        XCTAssertFalse(label.isAccessibilityElement)
        XCTAssertTrue(view.switchControl.isAccessibilityElement)
        XCTAssertEqual(view.switchControl.accessibilityLabel, item.title)

        NotificationCenter.default.post(name: UIAccessibility.voiceOverStatusDidChangeNotification, object: nil)
        XCTAssertFalse(view.isAccessibilityElement)
        XCTAssertTrue(view.switchControl.isAccessibilityElement)

        item.title = "Save card"
        item.value = true
        XCTAssertEqual(view.switchControl.accessibilityLabel, "Save card")
        XCTAssertTrue(view.switchControl.isOn)

        view.reset()
        XCTAssertFalse(view.switchControl.isOn)
    }

    func testTextFieldHasInitialAccessibilityLabel() {
        let item = FormTextInputItem()
        item.title = "Card number"
        let view = FormTextInputItemView(item: item)

        XCTAssertEqual(view.textField.accessibilityLabel, item.title)
    }

    func testAddressHeaderIsAnAccessibleHeading() {
        let item = FormAddressItem(
            initialCountry: "NL",
            configuration: .init(),
            presenter: nil,
            addressViewModelBuilder: DefaultAddressViewModelBuilder()
        )
        let header = item.headerItem.build(with: FormItemViewBuilder())

        XCTAssertTrue(header.accessibilityTraits.contains(.header))
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
