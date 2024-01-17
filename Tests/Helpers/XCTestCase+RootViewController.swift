//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import XCTest
@_spi(AdyenInternal) @testable import Adyen

extension XCTestCase {
    
    /// Sets the rootViewController on the key window, waits a moment for it to appear and increases the animation speed for faster tests
    ///
    /// - Parameters:
    ///   - viewController: The view controller to set as the rootViewController
    ///
    /// - Throws: If the key window can't be found
    func setupRootViewController(_ viewController: UIViewController) {
        
        let window: UIWindow = {
            if let mainKeyWindow = UIApplication.shared.adyen.mainKeyWindow {
                return mainKeyWindow
            }
            
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.makeKeyAndVisible()
            return window
        }()
        
        window.rootViewController = viewController
        window.layer.speed = TestAnimationSpeed.fast.rawValue
        
        wait(for: .aMoment) // Waiting for a moment to give the viewController time to be presented
    }
    
    /// Presents a view controller on the root and waits for the presentation to complete
    ///
    /// - Parameters:
    ///   - viewController: The view controller to present on the root
    ///   - animated: Whether or not to animate the presentation
    ///   - completion: The optional block to be called after the view controller was presented
    ///
    /// - Throws: If the key window can't be found
    func presentOnRoot(_ viewController: UIViewController, animated: Bool = false, completion: (() -> Void)? = nil) {
        let root = UIViewController()
        root.view.backgroundColor = .white
        setupRootViewController(root)
        let presentationExpectation = XCTestExpectation(description: "Wait for the presentation to complete")
        root.present(viewController, animated: animated) {
            completion?()
            presentationExpectation.fulfill()
        }

        wait(for: [presentationExpectation], timeout: 100)
    }
}

extension DispatchTimeInterval {
    
    /// .milliseconds(30)
    static var aMoment: Self { .milliseconds(30) }
}

extension XCTestCase {

    enum TestAnimationSpeed: Float {
        case system = 1
        case fast = 100
    }

    /// Executes a block with a specified animation speed
    ///
    /// After the block the animation speed gets reset to the previous speed
    func withAnimation(_ speed: TestAnimationSpeed, block: () throws -> Void) throws {
        let previousLayerSpeed = UIApplication.shared.adyen.mainKeyWindow?.layer.speed ?? 1
        
        UIApplication.shared.adyen.mainKeyWindow?.layer.speed = speed.rawValue
        try block()
        UIApplication.shared.adyen.mainKeyWindow?.layer.speed = previousLayerSpeed
    }
    
    /// Executes a block with a specified animation speed
    ///
    /// After the block the animation speed gets reset to the previous speed
    func withoutAnimation(block: () throws -> Void) throws {
        let wereAnimationsEnabled = UIView.areAnimationsEnabled
        
        UIView.setAnimationsEnabled(false)
        try block()
        UIView.setAnimationsEnabled(wereAnimationsEnabled)
    }
}
