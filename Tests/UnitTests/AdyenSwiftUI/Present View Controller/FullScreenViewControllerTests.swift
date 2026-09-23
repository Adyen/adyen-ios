//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenSwiftUI
import SwiftUI
import XCTest

final class FullScreenViewControllerTests: XCTestCase {
    
    func testViewControllerIsPresented() {
        let viewModel = TestPresentingViewModel()
        let testVC = UIViewController()
        
        let view = TestPresentingView(viewModel: viewModel)
        let host = UIHostingController(rootView: view)
        
        let window: UIWindow
        if #available(iOS 13.0, *), let windowScene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene {
            window = UIWindow(windowScene: windowScene)
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        window.rootViewController = host
        window.makeKeyAndVisible()
        
        DispatchQueue.main.async {
            viewModel.viewController = testVC
        }
        
        let predicate = NSPredicate { _, _ in host.presentedViewController === testVC }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: host)
        wait(for: [expectation], timeout: 2.0)
    }
}
