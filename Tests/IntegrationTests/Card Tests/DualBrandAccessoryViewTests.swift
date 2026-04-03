//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard

final class DualBrandAccessoryViewTests: XCTestCase {
    var sut: DualBrandAccessoryView!
    private var imageLoader: ImageLoaderMock!
    var brandSelectionCount: Int!
    var lastSelectedBrand: DualBrandAccessoryView.BrandSelection?
    
    override func setUp() {
        super.setUp()
        
        brandSelectionCount = 0
        lastSelectedBrand = nil
        imageLoader = ImageLoaderMock()
        sut = DualBrandAccessoryView(
            style: brandImageStyle,
            imageLoader: imageLoader
        )
        sut.onBrandSelection = { [weak self] selection in
            self?.brandSelectionCount += 1
            self?.lastSelectedBrand = selection
        }
    }
    
    override func tearDown() {
        sut = nil
        imageLoader = nil
        brandSelectionCount = nil
        lastSelectedBrand = nil
        super.tearDown()
    }
    
    func testUpdateCurrentLogos_WhenResettingLoadedImages_ShouldResetToPlaceholder() throws {
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
        let dualBrandLogos = try [
            FormCardLogosItem.CardTypeLogo(url: XCTUnwrap(URL(string: "https://example.com/visa.png")), type: .visa),
            FormCardLogosItem.CardTypeLogo(url: XCTUnwrap(URL(string: "https://example.com/bcmc.png")), type: .bcmc)
        ]
            
        sut.updateCurrentLogos(dualBrandLogos)
        
        wait(for: [expectation], timeout: 0.1)
            
        XCTAssertEqual(sut.primaryLogoView.image, visaImage, "Primary logo should show visa image")
        XCTAssertEqual(sut.secondaryLogoView.image, bcmcImage, "Secondary logo should show bcmc image")
        XCTAssertFalse(sut.secondaryLogoView.isHidden, "Secondary option should be visible")

        sut.updateCurrentLogos([])
            
        XCTAssertEqual(sut.primaryLogoView.image, placeholderImage, "Primary logo should show placeholder")
        XCTAssertEqual(sut.primaryLogoView.alpha, 1.0, "Primary logo should have full opacity")
        XCTAssertTrue(sut.secondaryLogoView.isHidden, "Secondary option should be hidden")
    }

    func testUpdateCurrentLogos_changingFromDualToSingle_resetsAndShowsSingleBrand() throws {
        let dualBrandLogos = try [
            FormCardLogosItem.CardTypeLogo(url: XCTUnwrap(URL(string: "https://example.com/visa.png")), type: .visa),
            FormCardLogosItem.CardTypeLogo(url: XCTUnwrap(URL(string: "https://example.com/bcmc.png")), type: .bcmc)
        ]
        sut.updateCurrentLogos(dualBrandLogos)
        
        let singleBrandLogo = try [
            FormCardLogosItem.CardTypeLogo(url: XCTUnwrap(URL(string: "https://example.com/amex.png")), type: .americanExpress)
        ]
        sut.updateCurrentLogos(singleBrandLogo)
        
        XCTAssertTrue(sut.secondaryLogoView.isHidden, "Secondary option should be hidden")
    }
    
    // MARK: - Selection Tests
    
    func testDualBrand_defaultSelectionIsPrimary() throws {
        let dualBrandLogos = try [
            FormCardLogosItem.CardTypeLogo(url: XCTUnwrap(URL(string: "https://example.com/visa.png")), type: .visa),
            FormCardLogosItem.CardTypeLogo(url: XCTUnwrap(URL(string: "https://example.com/bcmc.png")), type: .bcmc)
        ]
        sut.updateCurrentLogos(dualBrandLogos)
        
        XCTAssertEqual(sut.selectedBrand, .primary, "Default selection should be primary")
    }
    
    func testDualBrand_segmentedPickerAppearance() throws {
        let dualBrandLogos = try [
            FormCardLogosItem.CardTypeLogo(url: XCTUnwrap(URL(string: "https://example.com/visa.png")), type: .visa),
            FormCardLogosItem.CardTypeLogo(url: XCTUnwrap(URL(string: "https://example.com/bcmc.png")), type: .bcmc)
        ]
        sut.updateCurrentLogos(dualBrandLogos)
        
        let backgroundView = sut.subviews.first { $0.layer.cornerRadius == 8 }
        XCTAssertNotNil(backgroundView, "Segmented background should exist")
        XCTAssertFalse(backgroundView?.isHidden ?? true, "Segmented background should be visible")
    }
    
    func testSingleBrand_noSegmentedPickerAppearance() throws {
        let singleBrandLogo = try [
            FormCardLogosItem.CardTypeLogo(url: XCTUnwrap(URL(string: "https://example.com/visa.png")), type: .visa)
        ]
        sut.updateCurrentLogos(singleBrandLogo)
        
        let backgroundView = sut.subviews.first { $0.layer.cornerRadius == 8 }
        XCTAssertTrue(backgroundView?.isHidden ?? true, "Segmented background should be hidden for single brand")
        XCTAssertTrue(sut.primaryLogoView.superview?.gestureRecognizers?.isEmpty ?? true, "Single brand should have no gesture recognizers")
    }
    
    func testDualBrand_hasGestureRecognizers() throws {
        let dualBrandLogos = try [
            FormCardLogosItem.CardTypeLogo(url: XCTUnwrap(URL(string: "https://example.com/visa.png")), type: .visa),
            FormCardLogosItem.CardTypeLogo(url: XCTUnwrap(URL(string: "https://example.com/bcmc.png")), type: .bcmc)
        ]
        sut.updateCurrentLogos(dualBrandLogos)
        
        XCTAssertEqual(sut.primaryLogoView.superview?.gestureRecognizers?.count, 1, "Primary option should have a tap gesture")
        XCTAssertEqual(sut.secondaryLogoView.superview?.gestureRecognizers?.count, 1, "Secondary option should have a tap gesture")
    }
    
    func testDualBrandToSingle_removesGestureRecognizers() throws {
        let dualBrandLogos = try [
            FormCardLogosItem.CardTypeLogo(url: XCTUnwrap(URL(string: "https://example.com/visa.png")), type: .visa),
            FormCardLogosItem.CardTypeLogo(url: XCTUnwrap(URL(string: "https://example.com/bcmc.png")), type: .bcmc)
        ]
        sut.updateCurrentLogos(dualBrandLogos)
        XCTAssertEqual(sut.primaryLogoView.superview?.gestureRecognizers?.count, 1)
        
        let singleBrandLogo = try [
            FormCardLogosItem.CardTypeLogo(url: XCTUnwrap(URL(string: "https://example.com/amex.png")), type: .americanExpress)
        ]
        sut.updateCurrentLogos(singleBrandLogo)
        
        XCTAssertTrue(sut.primaryLogoView.superview?.gestureRecognizers?.isEmpty ?? true, "Gesture recognizers should be removed after switching to single brand")
    }
    
    private var brandImageStyle: ImageStyle = .init(
        borderColor: nil,
        borderWidth: 0.0,
        cornerRadius: 0.0,
        clipsToBounds: true,
        contentMode: .scaleAspectFit
    )
}
