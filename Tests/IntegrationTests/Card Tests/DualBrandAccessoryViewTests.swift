//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class DualBrandAccessoryViewTests: XCTestCase {
    private var sut: DualBrandAccessoryView!
    private var imageLoader: ImageLoaderMock!

    override func setUp() {
        super.setUp()

        imageLoader = ImageLoaderMock()
        sut = DualBrandAccessoryView(
            colors: .default,
            imageLoader: imageLoader
        )
    }

    override func tearDown() {
        sut = nil
        imageLoader = nil
        super.tearDown()
    }

    // MARK: - Logo updates

    func test_updateCurrentLogos_withEmptyLogosAfterLoadedImages_shouldResetToPlaceholder() {
        let expectation = expectation(description: "Wait for image loading")
        expectation.expectedFulfillmentCount = 2
        let placeholderImage = UIImage(named: "ic_card_front", in: .cardInternalResources, compatibleWith: nil)
        let visaImage = UIImage()
        let bcmcImage = UIImage()

        imageLoader.imageProvider = { url in
            expectation.fulfill()
            if url.absoluteString.contains("visa") {
                return visaImage
            } else if url.absoluteString.contains("bcmc") {
                return bcmcImage
            }
            return nil
        }

        sut.updateCurrentLogos(makeDualBrandLogos(), mode: .dualSelectable)

        wait(for: [expectation], timeout: 0.1)

        XCTAssertEqual(sut.primaryLogoView.image, visaImage)
        XCTAssertEqual(sut.secondaryLogoView.image, bcmcImage)
        XCTAssertFalse(sut.secondaryLogoView.isHidden)

        sut.updateCurrentLogos([])

        XCTAssertEqual(sut.primaryLogoView.image, placeholderImage)
        XCTAssertTrue(sut.secondaryLogoView.isHidden)
    }

    func test_updateCurrentLogos_fromDualToSingleBrand_shouldHideSecondaryLogo() {
        sut.updateCurrentLogos(makeDualBrandLogos(), mode: .dualSelectable)

        sut.updateCurrentLogos(makeSingleBrandLogo())

        XCTAssertTrue(sut.secondaryLogoView.isHidden)
    }

    // MARK: - Selection

    func test_currentSelection_inDualSelectableMode_shouldDefaultToPrimary() {
        sut.updateCurrentLogos(makeDualBrandLogos(), mode: .dualSelectable)

        XCTAssertEqual(sut.currentSelection, .primary)
    }

    // MARK: - Display mode

    func test_segmentedBackground_inDualSelectableMode_shouldBeVisible() {
        sut.updateCurrentLogos(makeDualBrandLogos(), mode: .dualSelectable)

        XCTAssertFalse(segmentedBackground(of: sut)?.isHidden ?? true)
    }

    func test_segmentedBackground_inSingleMode_shouldBeHiddenWithoutGestures() {
        sut.updateCurrentLogos(makeSingleBrandLogo())

        XCTAssertTrue(segmentedBackground(of: sut)?.isHidden ?? true)
        XCTAssertTrue(gestureRecognizers(ofOptionContaining: sut.primaryLogoView).isEmpty)
    }

    func test_options_inDualSelectableMode_shouldHaveTapGestures() {
        sut.updateCurrentLogos(makeDualBrandLogos(), mode: .dualSelectable)

        XCTAssertEqual(gestureRecognizers(ofOptionContaining: sut.primaryLogoView).count, 1)
        XCTAssertEqual(gestureRecognizers(ofOptionContaining: sut.secondaryLogoView).count, 1)
    }

    func test_options_fromDualSelectableToSingleBrand_shouldRemoveTapGestures() {
        sut.updateCurrentLogos(makeDualBrandLogos(), mode: .dualSelectable)
        XCTAssertEqual(gestureRecognizers(ofOptionContaining: sut.primaryLogoView).count, 1)

        sut.updateCurrentLogos(makeSingleBrandLogo())

        XCTAssertTrue(gestureRecognizers(ofOptionContaining: sut.primaryLogoView).isEmpty)
    }

    func test_options_fromSingleToDualSelectableMode_shouldAddTapGestures() {
        sut.updateCurrentLogos(makeSingleBrandLogo())
        XCTAssertTrue(gestureRecognizers(ofOptionContaining: sut.primaryLogoView).isEmpty)

        sut.updateCurrentLogos(makeDualBrandLogos(), mode: .dualSelectable)

        XCTAssertEqual(gestureRecognizers(ofOptionContaining: sut.primaryLogoView).count, 1)
        XCTAssertFalse(segmentedBackground(of: sut)?.isHidden ?? true)
    }

    func test_updateCurrentLogos_inDualUnselectableMode_shouldShowBothLogosWithoutInteraction() {
        sut.updateCurrentLogos(makeDualBrandLogos(), mode: .dualUnselectable)

        XCTAssertFalse(sut.secondaryLogoView.isHidden)
        XCTAssertTrue(segmentedBackground(of: sut)?.isHidden ?? true)
        XCTAssertTrue(gestureRecognizers(ofOptionContaining: sut.primaryLogoView).isEmpty)
        XCTAssertTrue(gestureRecognizers(ofOptionContaining: sut.secondaryLogoView).isEmpty)
    }

    func test_updateCurrentLogos_inSingleMode_shouldShowOnlyPrimaryLogo() {
        sut.updateCurrentLogos(makeSingleBrandLogo())

        XCTAssertTrue(sut.secondaryLogoView.isHidden)
        XCTAssertTrue(segmentedBackground(of: sut)?.isHidden ?? true)
        XCTAssertTrue(gestureRecognizers(ofOptionContaining: sut.primaryLogoView).isEmpty)
    }

    func test_updateCurrentLogos_fromDualSelectableToDualUnselectable_shouldRemoveInteraction() {
        let dualBrandLogos = makeDualBrandLogos()
        sut.updateCurrentLogos(dualBrandLogos, mode: .dualSelectable)
        XCTAssertEqual(gestureRecognizers(ofOptionContaining: sut.primaryLogoView).count, 1)
        XCTAssertFalse(segmentedBackground(of: sut)?.isHidden ?? true)

        sut.updateCurrentLogos(dualBrandLogos, mode: .dualUnselectable)

        XCTAssertTrue(gestureRecognizers(ofOptionContaining: sut.primaryLogoView).isEmpty)
        XCTAssertTrue(segmentedBackground(of: sut)?.isHidden ?? true)
        XCTAssertFalse(sut.secondaryLogoView.isHidden)
    }

    func test_updateCurrentLogos_fromDualUnselectableToSingle_shouldHideSecondaryLogo() {
        sut.updateCurrentLogos(makeDualBrandLogos(), mode: .dualUnselectable)
        XCTAssertFalse(sut.secondaryLogoView.isHidden)

        sut.updateCurrentLogos(makeSingleBrandLogo())

        XCTAssertTrue(sut.secondaryLogoView.isHidden)
    }

    // MARK: - Overflow hit test

    func test_updateSelection_withSecondary_shouldUpdateCurrentSelection() {
        sut.updateCurrentLogos(makeDualBrandLogos(), mode: .dualSelectable)
        XCTAssertEqual(sut.currentSelection, .primary)

        sut.updateSelection(with: .secondary)

        XCTAssertEqual(sut.currentSelection, .secondary)
    }

    func test_updateSelection_withSecondary_shouldNotCallOnBrandSelection() {
        var callCount = 0
        sut.onBrandSelection = { _ in callCount += 1 }
        sut.updateCurrentLogos(makeDualBrandLogos(), mode: .dualSelectable)

        sut.updateSelection(with: .secondary)

        XCTAssertEqual(callCount, 0)
    }

    func test_updateSelection_fromSecondaryToPrimary_shouldUpdateCurrentSelection() {
        sut.updateCurrentLogos(makeDualBrandLogos(), mode: .dualSelectable)
        sut.updateSelection(with: .secondary)
        XCTAssertEqual(sut.currentSelection, .secondary)

        sut.updateSelection(with: .primary)

        XCTAssertEqual(sut.currentSelection, .primary)
    }

    func test_overflowHitTest_inSingleMode_shouldReturnNil() {
        sut.updateCurrentLogos(makeSingleBrandLogo())
        layout(sut)

        XCTAssertNil(sut.overflowHitTest(point: .zero, with: nil))
    }

    func test_overflowHitTest_inDualSelectableModeInsidePicker_shouldReturnView() throws {
        sut.updateCurrentLogos(makeDualBrandLogos(), mode: .dualSelectable)
        layout(sut)
        let backgroundView = try XCTUnwrap(segmentedBackground(of: sut))

        let point = CGPoint(x: backgroundView.frame.midX, y: backgroundView.frame.midY)

        XCTAssertNotNil(sut.overflowHitTest(point: point, with: nil))
    }

    func test_overflowHitTest_inDualSelectableModeOutsidePicker_shouldReturnNil() throws {
        sut.updateCurrentLogos(makeDualBrandLogos(), mode: .dualSelectable)
        layout(sut)
        let backgroundView = try XCTUnwrap(segmentedBackground(of: sut))

        let point = CGPoint(x: backgroundView.frame.maxX + 10, y: backgroundView.frame.maxY + 10)

        XCTAssertNil(sut.overflowHitTest(point: point, with: nil))
    }

    // MARK: - Helpers

    private func makeDualBrandLogos() -> [FormCardLogosItem.CardBrandLogo] {
        [
            FormCardLogosItem.CardBrandLogo(url: URL(string: "https://example.com/visa.png")!, brand: .visa),
            FormCardLogosItem.CardBrandLogo(url: URL(string: "https://example.com/bcmc.png")!, brand: .bcmc)
        ]
    }

    private func makeSingleBrandLogo() -> [FormCardLogosItem.CardBrandLogo] {
        [
            FormCardLogosItem.CardBrandLogo(url: URL(string: "https://example.com/amex.png")!, brand: .americanExpress)
        ]
    }

    /// The segmented background is the only subview that isn't the logos stack view.
    private func segmentedBackground(of view: DualBrandAccessoryView) -> UIView? {
        view.subviews.first { !($0 is UIStackView) }
    }

    private func gestureRecognizers(ofOptionContaining logoView: UIImageView) -> [UIGestureRecognizer] {
        logoView.superview?.gestureRecognizers ?? []
    }

    private func layout(_ view: DualBrandAccessoryView) {
        view.frame = CGRect(origin: .zero, size: view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize))
        view.layoutIfNeeded()
    }
}
