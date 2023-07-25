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

    func testShowingSpinnerDelay() throws {
        
        let loadingView = LoadingView(contentView: UIView())
        loadingView.spinnerAppearanceDelay = .milliseconds(50)
        loadingView.showsActivityIndicator = true
        
        XCTAssertEqual(loadingView.showsActivityIndicator, false)
        
        wait(for: .milliseconds(50))
        
        XCTAssertEqual(loadingView.showsActivityIndicator, true)
    }
    
    func testHidingSpinner() throws {
        
        let loadingView = LoadingView(contentView: UIView())
        
        loadingView.showsActivityIndicator = true
        
        wait(for: .aMoment)
        
        loadingView.showsActivityIndicator = false
        XCTAssertEqual(loadingView.showsActivityIndicator, false)
        XCTAssertNil(loadingView.workItem)
    }

}
