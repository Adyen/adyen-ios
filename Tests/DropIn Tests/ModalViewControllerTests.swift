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
    
    var sut: ModalViewController!
    lazy var viewController: UIViewController = {
        let view = UIViewController(nibName: nil, bundle: nil)
        view.title = "ModalViewControllerTest"
        return view
    }()
    
    override func tearDown() {
        sut = nil
    }

    func testCustomStyle() {
        var style = NavigationStyle()
        style.separatorColor = .red
        style.backgroundColor = .brown

        loadAndRunTests(for: style) {
            XCTAssertEqual(self.sut.separator.backgroundColor, .red)
            XCTAssertEqual(self.sut.view.backgroundColor, .brown)
        }
    }
    
    fileprivate func loadAndRunTests(for style: NavigationStyle, test: @escaping () -> Void) {
        sut = ModalViewController(
            rootViewController: viewController,
            style: style,
            navBarType: .regular
        )
        UIApplication.shared.keyWindow?.rootViewController = sut
        sut.loadView()
        sut.viewDidLoad()
        
        wait(for: .milliseconds(300))
        
        test()
    }
}
