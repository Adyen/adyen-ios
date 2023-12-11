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
#if canImport(TwintSDK)
    import AdyenTwint
    import TwintSDK
#endif
import UIKit

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
        var urlHandled = false
        
        #if canImport(TwintSDK)
            urlHandled = Twint.handleOpen(url) { error in
                
                var userInfo = [String: Codable]()
                
                // TODO: This is not that nice - maybe better let the TwintComponent generate the UserDefaults?
                
                if let error {
                    userInfo[TwintComponent.RedirectNotificationErrorKey] = error.localizedDescription
                }
                
                NotificationCenter.default.post(
                    name: TwintComponent.RedirectNotification,
                    object: nil,
                    userInfo: userInfo
                )
            }
        #endif
        
        if !urlHandled {
            RedirectComponent.applicationDidOpen(from: url)
        }
        
        #if canImport(PayKit)
            NotificationCenter.default.post(
                name: CashAppPay.RedirectNotification,
                object: nil,
                userInfo: [UIApplication.LaunchOptionsKey.url: url]
            )
        #endif
        
        return true
    }
}
