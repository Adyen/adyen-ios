//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
#if canImport(PayKit)
    import PayKit
#endif
import UIKit
#if canImport(TwintSDK)
    import TwintSDK
#endif

@main
internal final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    internal var window: UIWindow?
    
    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let componentsViewController = ComponentsViewController()
        
        let navigationController = UINavigationController(rootViewController: componentsViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        
        #if DEBUG
            AdyenLogging.isEnabled = true
        #endif
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }
    
    internal func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if RedirectComponent.applicationDidOpen(from: url) {
#if canImport(PayKit)
            NotificationCenter.default.post(
                name: CashAppPay.RedirectNotification,
                object: nil,
                userInfo: [UIApplication.LaunchOptionsKey.url: url]
            )
#endif
        } else {
#if canImport(TwintSDK)
            let handled = Twint.handleOpen(url) { [weak self] error in
                if let error = error as? NSError {
                    if error.code == TWErrorCode.B_SUCCESS.rawValue {
                        self?.handlePaymentSuccessful()

                    } else {
                        self?.handlePaymentFailure(error: error)
                    }
                }
            }
            return handled
#endif
        }
        return true
    }

    private func handlePaymentSuccessful() {
        print("payment successful")
    }

    private func handlePaymentFailure(error: NSError) {
        print("payment Failure")
    }
}
