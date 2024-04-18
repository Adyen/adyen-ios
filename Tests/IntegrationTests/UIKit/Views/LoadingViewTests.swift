//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class LoadingViewTests: XCTestCase {
    
    var sut: LoadingView!
    var viewController: UIViewController!
    
    override func setUp() {
        super.setUp()
        let contentView = UIView()
        sut = LoadingView(contentView: contentView)
        sut.spinnerAppearanceDelay = .milliseconds(1)

        viewController = UIViewController()
        viewController.view.addSubview(sut)
        viewController.view.backgroundColor = .white
        sut.adyen.anchor(inside: viewController.view)
    }

    func testShowingSpinnerDelay() throws {
        setupRootViewController(viewController)
        
        sut.showsActivityIndicator = true
        XCTAssertEqual(sut.showsActivityIndicator, false)
        
        wait(until: sut, at: \.showsActivityIndicator, is: true)
    }
    
    func testHidingSpinner() throws {
        setupRootViewController(viewController)
        
        sut.showsActivityIndicator = true
        wait(for: .milliseconds(2))
        sut.showsActivityIndicator = false
        XCTAssertEqual(sut.showsActivityIndicator, false)
        XCTAssertNil(sut.workItem)
    }

}
