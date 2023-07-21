//
//  LoadingViewTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 6/16/21.
//  Copyright © 2021 Adyen. All rights reserved.
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

        viewController = UIViewController()
        viewController.view.addSubview(sut)
        viewController.view.backgroundColor = .white
        sut.adyen.anchor(inside: viewController.view)
    }

    func testShowingSpinnerDelay() throws {
        UIApplication.shared.keyWindow?.rootViewController = viewController
        
        wait(for: .milliseconds(300))
        
        sut.showsActivityIndicator = true
        XCTAssertEqual(sut.showsActivityIndicator, false)
        
        wait(for: .milliseconds(1100))
        XCTAssertEqual(sut.showsActivityIndicator, true)
    }
    
    func testHiddingSpinner() throws {
        UIApplication.shared.keyWindow?.rootViewController = viewController
        
        wait(for: .milliseconds(300))
        
        sut.showsActivityIndicator = true
        
        wait(for: .milliseconds(300))
        
        sut.showsActivityIndicator = false
        XCTAssertEqual(sut.showsActivityIndicator, false)
        XCTAssertNil(sut.workItem)
    }

}
