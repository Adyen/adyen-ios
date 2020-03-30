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
    
    func testDefaultStyle() {
        let style = NavigationStyle()
        
        loadAndRunTests(for: style) {
            if #available(iOS 13.0, *) {} else {
                XCTAssertEqual(self.sut.cancelButton.tintColor, UIColor.AdyenCore.defaultBlue)
            }
            
            XCTAssertEqual(self.sut.titleLabel.textColor, UIColor.AdyenCore.componentLabel)
            XCTAssertEqual(self.sut.titleLabel.font, .systemFont(ofSize: 20, weight: .semibold))
            XCTAssertEqual(self.sut.titleLabel.textAlignment, .left)
            XCTAssertEqual(self.sut.view.tintColor, UIColor.AdyenCore.defaultBlue)
            XCTAssertEqual(self.sut.view.backgroundColor, UIColor.AdyenCore.componentBackground)
        }
    }
    
    func testCustomStyle() {
        var style = NavigationStyle()
        style.barBackgroundColor = .green
        style.barTitle.color = .red
        style.barTintColor = .white
        style.tintColor = .red
        style.backgroundColor = .brown
        style.barTitle = .init(font: .italicSystemFont(ofSize: 17), color: .yellow, textAlignment: .right)
        
        loadAndRunTests(for: style) {
            if #available(iOS 13.0, *) {} else {
                XCTAssertEqual(self.sut.cancelButton.tintColor, UIColor.AdyenCore.componentBackground)
            }
            
            XCTAssertEqual(self.sut.titleLabel.textColor, .yellow)
            XCTAssertEqual(self.sut.titleLabel.font, .italicSystemFont(ofSize: 17))
            XCTAssertEqual(self.sut.titleLabel.textAlignment, .left)
            XCTAssertEqual(self.sut.view.tintColor, .red)
            XCTAssertEqual(self.sut.view.backgroundColor, .brown)
        }
    }
    
    fileprivate func loadAndRunTests(for style: NavigationStyle, test: @escaping () -> Void) {
        sut = ModalViewController(rootViewController: viewController, style: style, cancelButtonHandler: nil)
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
