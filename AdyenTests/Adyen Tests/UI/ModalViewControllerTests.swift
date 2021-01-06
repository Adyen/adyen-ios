//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
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
        sut = ModalViewController(rootViewController: viewController, style: style, cancelButtonHandler: { _ in })
        UIApplication.shared.keyWindow?.rootViewController = sut
        sut.loadView()
        sut.viewDidLoad()
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            test()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
}
