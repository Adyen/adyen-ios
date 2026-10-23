//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class CardFormAccessibilityTests: XCTestCase {

    func test_toggleItemView_onInit_shouldExposeTitleAsLabel() {
        let item = FormToggleItem()
        item.title = "Save for next time"

        let sut = FormToggleItemView(item: item)

        XCTAssertEqual(sut.accessibilityLabel, "Save for next time")
        XCTAssertEqual(sut.switchControl.accessibilityLabel, "Save for next time")
    }

    func test_toggleItemView_whenTitleChanges_shouldUpdateLabels() {
        let item = FormToggleItem()
        item.title = "Save for next time"
        let sut = FormToggleItemView(item: item)

        item.title = "Remember card"

        XCTAssertEqual(sut.accessibilityLabel, "Remember card")
        XCTAssertEqual(sut.switchControl.accessibilityLabel, "Remember card")
    }

    func test_sectionHeader_titleLabel_shouldHaveHeaderTrait() throws {
        let sut = FormToggleItem().withSectionHeader(title: "Billing address").build(with: FormItemViewBuilder())

        let titleLabel = try XCTUnwrap((sut as UIView).allSubviews.compactMap { $0 as? UILabel }.first { $0.text == "Billing address" })

        XCTAssertTrue(titleLabel.accessibilityTraits.contains(.header))
    }

    func test_cardLogos_shouldBeImagesThatCannotBeSelectedOrFocused() throws {
        let logo = try FormCardLogosItem.CardBrandLogo(url: XCTUnwrap(URL(string: "https://example.com/visa.png")), brand: .visa)
        let item = FormCardLogosItem(cardLogos: [logo], style: FormTextItemStyle())
        let sut = FormCardLogosItemView(item: item)
        let collectionView = try XCTUnwrap(sut.allSubviews.compactMap { $0 as? UICollectionView }.first)

        XCTAssertFalse(collectionView.allowsSelection)
        XCTAssertFalse(collectionView.allowsFocus)

        let cell = sut.collectionView(collectionView, cellForItemAt: IndexPath(item: 0, section: 0))
        let imageView = try XCTUnwrap(cell.allSubviews.compactMap { $0 as? UIImageView }.first { $0.isAccessibilityElement })

        XCTAssertEqual(imageView.accessibilityLabel, CardBrand.visa.name)
        XCTAssertEqual(imageView.accessibilityTraits, .image)
    }

    func test_textItemView_onInit_shouldExposeTitleAsLabel() {
        let item = FormTextInputItem()
        item.title = "Card number"

        let sut = FormTextInputItemView(item: item)

        XCTAssertEqual(sut.accessibilityLabelView?.accessibilityLabel, "Card number")
    }

    func test_securityCodeItemView_whenValidationFails_shouldKeepExpectedDigitsInLabel() {
        let item = FormCardSecurityCodeItem()
        item.validator = CardSecurityCodeValidator()
        let sut = FormCardSecurityCodeItemView(item: item)

        item.value = "1"
        sut.showValidation()

        let digits = localizedString(.cardCvcItemPlaceholderDigits, nil, "3")
        let expected = [item.title, digits, item.validationFailureMessage].compactMap { $0 }.joined(separator: ", ")
        XCTAssertEqual(sut.accessibilityLabelView?.accessibilityLabel, expected)
    }
}

private extension UIView {
    var allSubviews: [UIView] {
        subviews + subviews.flatMap(\.allSubviews)
    }
}
