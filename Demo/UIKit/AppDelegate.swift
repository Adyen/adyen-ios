//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
#if canImport(PayKit)
    import PayKit
#endif
import UIKit

@main
internal final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    internal var window: UIWindow?
    
    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if !os(visionOS)
            let componentsViewController = ComponentsViewController()
        
            let navigationController = UINavigationController(rootViewController: componentsViewController)
            navigationController.navigationBar.prefersLargeTitles = true
        
            #if DEBUG
                AdyenLogging.isEnabled = true
            #endif
        
            let window = UIWindow(frame: .zero) // UIScreen.main.bounds)
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
            self.window = window
        #endif
        
        return true
    }
    
    internal func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        RedirectComponent.applicationDidOpen(from: url)
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

@available(iOS 13.0, *)
internal class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    internal var window: UIWindow?

    internal func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let sceneWindow = (scene as? UIWindowScene) else { return }

        let componentsViewController = ComponentsViewController()
        
        let navigationController = UINavigationController(rootViewController: componentsViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        
        #if DEBUG
            AdyenLogging.isEnabled = true
        #endif
        
        let window = UIWindow(windowScene: sceneWindow)
        window.rootViewController = navigationController
        #if !os(visionOS)
            window.backgroundColor = .applicationBackground
        #endif
        window.makeKeyAndVisible()
        self.window = window
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        
        RedirectComponent.applicationDidOpen(from: url)
        #if canImport(PayKit)
            NotificationCenter.default.post(
                name: CashAppPay.RedirectNotification,
                object: nil,
                userInfo: [UIApplication.LaunchOptionsKey.url: url]
            )
        #endif
    }
}
