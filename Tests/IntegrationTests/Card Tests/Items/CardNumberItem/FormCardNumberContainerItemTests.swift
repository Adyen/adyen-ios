//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class FormCardNumberContainerItemTests: XCTestCase {

    private func makeContainerItem() -> FormCardNumberContainerItem {
        FormCardNumberContainerItem(
            cardBrandLogos: [],
            showSupportedCardBrandLogos: false,
            style: FormTextItemStyle(),
            localizationParameters: nil,
            scanCardHandler: nil
        )
    }

    private func makeSupportedBrand(_ brand: CardBrand) -> DetectedCardBrand {
        DetectedCardBrand(brand: brand)
    }

    func test_brandDescriptionItem_shouldBeHiddenByDefault() {
        let sut = makeContainerItem()

        XCTAssertTrue(sut.brandDescriptionItem.isHidden.wrappedValue)
    }

    func test_brandDescriptionItem_inSingleMode_shouldStayHidden() {
        let sut = makeContainerItem()

        sut.numberItem.brandDisplayMode = .single
        sut.update(brands: [makeSupportedBrand(.visa)])

        XCTAssertTrue(sut.brandDescriptionItem.isHidden.wrappedValue)
    }

    func test_brandDescriptionItem_inDualUnselectableMode_shouldStayHidden() {
        let sut = makeContainerItem()

        sut.numberItem.brandDisplayMode = .dualUnselectable
        sut.update(brands: [makeSupportedBrand(.visa), makeSupportedBrand(.bcmc)])

        XCTAssertTrue(sut.brandDescriptionItem.isHidden.wrappedValue)
    }

    func test_brandDescriptionItem_inDualSelectableModeWithInactiveField_shouldStayHidden() {
        let sut = makeContainerItem()

        sut.numberItem.brandDisplayMode = .dualSelectable
        sut.update(brands: [makeSupportedBrand(.visa), makeSupportedBrand(.bcmc)])

        XCTAssertTrue(sut.brandDescriptionItem.isHidden.wrappedValue)
    }

    func test_brandDescriptionItem_inDualSelectableModeWhenFieldIsActive_shouldShow() {
        let sut = makeContainerItem()

        sut.numberItem.brandDisplayMode = .dualSelectable
        sut.update(brands: [makeSupportedBrand(.visa), makeSupportedBrand(.bcmc)])
        sut.numberItem.isActive = true

        XCTAssertFalse(sut.brandDescriptionItem.isHidden.wrappedValue)
    }

    func test_brandDescriptionItem_whenActiveFieldBecomesInactiveWithInvalidNumber_shouldHide() {
        let sut = makeContainerItem()

        sut.numberItem.brandDisplayMode = .dualSelectable
        sut.update(brands: [makeSupportedBrand(.visa), makeSupportedBrand(.bcmc)])
        sut.numberItem.isActive = true
        XCTAssertFalse(sut.brandDescriptionItem.isHidden.wrappedValue)

        sut.numberItem.isActive = false

        XCTAssertTrue(sut.brandDescriptionItem.isHidden.wrappedValue)
    }

    func test_brandDescriptionItem_whenActiveFieldSwitchesToSingleMode_shouldStayHidden() {
        let sut = makeContainerItem()

        sut.numberItem.isActive = true
        sut.update(brands: [makeSupportedBrand(.visa)])
        XCTAssertTrue(sut.brandDescriptionItem.isHidden.wrappedValue)

        sut.numberItem.brandDisplayMode = .single
        sut.update(brands: [makeSupportedBrand(.visa)])

        XCTAssertTrue(sut.brandDescriptionItem.isHidden.wrappedValue)
    }

    func test_brandDescriptionItem_whenModeChangesToDualSelectableWithActiveField_shouldShow() {
        let sut = makeContainerItem()

        sut.numberItem.brandDisplayMode = .single
        sut.update(brands: [makeSupportedBrand(.visa)])
        sut.numberItem.isActive = true
        XCTAssertTrue(sut.brandDescriptionItem.isHidden.wrappedValue)

        sut.numberItem.brandDisplayMode = .dualSelectable
        sut.update(brands: [makeSupportedBrand(.visa), makeSupportedBrand(.bcmc)])

        XCTAssertFalse(sut.brandDescriptionItem.isHidden.wrappedValue)
    }

    func test_brandDescriptionItem_inDualSelectableModeWithUnsupportedBrands_shouldStayHidden() {
        let sut = makeContainerItem()

        sut.numberItem.brandDisplayMode = .dualSelectable
        sut.update(brands: [
            DetectedCardBrand(brand: .visa, isSupported: false),
            DetectedCardBrand(brand: .bcmc, isSupported: false)
        ])

        XCTAssertTrue(sut.brandDescriptionItem.isHidden.wrappedValue)
    }

    func test_brandDescriptionItem_shouldBeIncludedInSubitems() {
        let sut = makeContainerItem()

        XCTAssertTrue(sut.subitems.contains { $0 === sut.brandDescriptionItem })
    }
}
