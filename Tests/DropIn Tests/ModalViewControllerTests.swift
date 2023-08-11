//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
@testable import AdyenDropIn
import XCTest

class ModalViewControllerTests: XCTestCase {
    
    lazy var viewController: UIViewController = {
        let view = UIViewController(nibName: nil, bundle: nil)
        view.title = "ModalViewControllerTest"
        return view
    }()

    func testCustomStyle() throws {
        var style = NavigationStyle()
        style.separatorColor = .red
        style.backgroundColor = .brown

        let sut = ModalViewController(
            rootViewController: viewController,
            style: style,
            navBarType: .regular
        )
        
        try setupRootViewController(sut)
        
        XCTAssertEqual(sut.separator.backgroundColor, .red)
        XCTAssertEqual(sut.view.backgroundColor, .brown)
    }
}
