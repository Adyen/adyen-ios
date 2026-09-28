//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenActions
#if canImport(PayKit)
    import PayKit
#endif
import UIKit

internal final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    internal var window: UIWindow?

    internal func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let componentsViewController = ComponentsViewController()
        let navigationController = UINavigationController(rootViewController: componentsViewController)
        navigationController.navigationBar.prefersLargeTitles = true

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window

        if let url = connectionOptions.urlContexts.first?.url {
            handle(url)
        }
    }

    internal func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handle(url)
    }

    private func handle(_ url: URL) {
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
