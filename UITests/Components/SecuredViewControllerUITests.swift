//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

import XCTest
@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@testable import AdyenComponents

class SecuredViewControllerUITests: XCTestCase {
    
    func testBlur() throws {
        struct DummyStyle: ViewStyle {
            var backgroundColor: UIColor
        }
        
        let cardComponent = CardComponent(
            paymentMethod: CardPaymentMethod(
                type: .scheme,
                name: "scheme",
                fundingSource: .credit,
                brands: [.bcmc]
            ),
            context: Dummy.context
        )
        
        let sut = try XCTUnwrap(cardComponent.viewController as? SecuredViewController<CardViewController>)
        setupRootViewController(sut)
        
        try withoutAnimation {
            NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil)
            wait { sut.view.subviews.contains(where: { $0 is UIVisualEffectView }) }
            verifyViewControllerImage(
                matching: sut,
                named: "secured-view-controller-blurred",
                drawHierarchyInKeyWindow: true // Allows capturing the blur
            )
            
            NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
            wait { !sut.view.subviews.contains(where: { $0 is UIVisualEffectView }) }
            verifyViewControllerImage(
                matching: sut,
                named: "secured-view-controller-unblurred",
                drawHierarchyInKeyWindow: true // Allows capturing the blur
            )
        }
    }
}
