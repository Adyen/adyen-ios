//
//  AppDelegate.swift
//  AdyenSPMUIHost
//
//  Created by Mohamed Eldoheiri on 10/28/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

import UIKit
import Adyen

@UIApplicationMain
internal final class AppDelegate: UIResponder, UIApplicationDelegate {

    internal var window: UIWindow?

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let componentsViewController = ComponentsViewController()

        let navigationController = UINavigationController(rootViewController: componentsViewController)
        if #available(iOS 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
        }

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
        RedirectComponent.applicationDidOpen(from: url)

        return true
    }
}
