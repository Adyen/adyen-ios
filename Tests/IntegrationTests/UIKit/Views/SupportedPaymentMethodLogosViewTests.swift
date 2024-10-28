//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class SupportedPaymentMethodLogosViewTests: XCTestCase {
    
    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
    func test_setup() throws {
        let trailingText = "TRAILING_TEXT"
        let supportedLogosView = SupportedPaymentMethodLogosView(
            imageUrls: [URL(string: "https://adyen.com")!],
            trailingText: trailingText
        )
        XCTAssertEqual(supportedLogosView.subviews.count, 0)
        XCTAssertNil(supportedLogosView.content)
        
        let view = UIView(frame: .zero)
        view.addSubview(supportedLogosView)
        
        XCTAssertEqual(supportedLogosView.subviews.count, 1)
        XCTAssertTrue(supportedLogosView.subviews.first === supportedLogosView.content)
        
        let logoViews = try XCTUnwrap(supportedLogosView.content?.subviews.compactMap { $0 as? UIImageView })
        XCTAssertEqual(logoViews.count, 1)
        
        let trailingLabel = try XCTUnwrap(supportedLogosView.content?.subviews.last as? UILabel)
        XCTAssertEqual(trailingLabel.text, trailingText)
    }
}
