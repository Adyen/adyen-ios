//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
@_spi(AdyenInternal) @testable import AdyenUI

final class DualBrandAccessoryViewTests: XCTestCase {
    var sut: FormCardNumberItemView.DualBrandAccessoryView!
    private var imageLoader: ImageLoaderMock!
    var brandSelectionCount: Int!
    
    override func setUp() {
        super.setUp()
        
        brandSelectionCount = 0
        imageLoader = ImageLoaderMock()
        sut = FormCardNumberItemView.DualBrandAccessoryView(
            style: brandImageStyle,
            imageLoader: imageLoader
        )
    }
    
    override func tearDown() {
        sut = nil
        imageLoader = nil
        brandSelectionCount = nil
        super.tearDown()
    }
    
    func testUpdateCurrentLogos_WhenResettingLoadedImages_ShouldResetToPlaceholder() {
        // Given: Set up dual brand state with loaded images
        let expectation = expectation(description: "Wait for image loading")
        expectation.expectedFulfillmentCount = 2 // Two images to load
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
        let dualBrandLogos = [
            FormCardLogosItem.CardTypeLogo(url: URL(string: "https://example.com/visa.png")!, type: .visa),
            FormCardLogosItem.CardTypeLogo(url: URL(string: "https://example.com/bcmc.png")!, type: .bcmc)
        ]
            
        // Load initial dual brand state
        sut.updateCurrentLogos(dualBrandLogos)
        
        wait(for: [expectation], timeout: 0.1)
            
        // Verify initial state
        XCTAssertEqual(sut.primaryLogoView.image, visaImage, "Primary logo should show visa image")
        XCTAssertEqual(sut.secondaryLogoView.image, bcmcImage, "Secondary logo should show bcmc image")
        XCTAssertFalse(sut.secondaryLogoView.isHidden, "Secondary logo should be visible")

        // When: Update with empty logos array
        sut.updateCurrentLogos([])
            
        // Then
        XCTAssertEqual(sut.primaryLogoView.image, placeholderImage, "Primary logo should show placeholder")
        XCTAssertEqual(sut.primaryLogoView.alpha, 1.0, "Primary logo should have full opacity")
        XCTAssertTrue(sut.secondaryLogoView.isHidden, "Secondary logo should be hidden")
    }

    func testUpdateCurrentLogos_changingFromDualToSingle_resetsAndShowsSingleBrand() {
        // Given: Set up dual brand state
        let dualBrandLogos = [
            FormCardLogosItem.CardTypeLogo(url: URL(string: "https://example.com/visa.png")!, type: .visa),
            FormCardLogosItem.CardTypeLogo(url: URL(string: "https://example.com/bcmc.png")!, type: .bcmc)
        ]
        sut.updateCurrentLogos(dualBrandLogos)
        
        // When: Update with single brand
        let singleBrandLogo = [
            FormCardLogosItem.CardTypeLogo(url: URL(string: "https://example.com/amex.png")!, type: .americanExpress)
        ]
        sut.updateCurrentLogos(singleBrandLogo)
        
        // Then
        XCTAssertTrue(sut.secondaryLogoView.isHidden, "Secondary logo should be hidden")
    }
    
    private var brandImageStyle: ImageStyle = .init(
        borderColor: nil,
        borderWidth: 0.0,
        cornerRadius: 0.0,
        clipsToBounds: true,
        contentMode: .scaleAspectFit
    )

}
