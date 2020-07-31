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
            if !ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0)) {
                XCTAssertEqual(self.sut.cancelButton.tintColor.cgColor, UIColor.AdyenCore.defaultBlue.cgColor)
            }
            XCTAssertEqual(self.sut.titleLabel.textColor, UIColor.AdyenCore.componentLabel)
            XCTAssertEqual(self.sut.titleLabel.font, UIFont.AdyenCore.barTitle)
            XCTAssertEqual(self.sut.titleLabel.textAlignment, .left)
            if !ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0)) {
                XCTAssertEqual(self.sut.view.tintColor.cgColor, UIColor.AdyenCore.defaultBlue.cgColor)
            }
            XCTAssertEqual(self.sut.view.backgroundColor, UIColor.AdyenCore.componentBackground)
        }
    }
    
    func testCustomStyle() {
        var style = NavigationStyle()
        style.tintColor = .white
        style.backgroundColor = .brown
        style.separatorColor = .red
        style.barTitle = .init(font: .italicSystemFont(ofSize: 17), color: .yellow, textAlignment: .right)
        
        loadAndRunTests(for: style) {
            XCTAssertEqual(self.sut.cancelButton.tintColor, .white)
            XCTAssertEqual(self.sut.titleLabel.textColor, .yellow)
            XCTAssertEqual(self.sut.titleLabel.font, .italicSystemFont(ofSize: 17))
            XCTAssertEqual(self.sut.titleLabel.textAlignment, .left)
            XCTAssertEqual(self.sut.view.backgroundColor, .brown)
            XCTAssertEqual(self.sut.separator.backgroundColor, .red)
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
