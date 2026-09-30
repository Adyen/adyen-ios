//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import RemoteLoggerClient
import UIKit

@main
internal final class AppDelegate: UIResponder, UIApplicationDelegate {

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
            AdyenLogging.isEnabled = true
            Task {
                try? await remoteLogger?.log("INFO AdyenUIHost launched")
                try? await remoteLogger?.log("DEBUG Launch options present: \(launchOptions != nil)")
            }
        #endif

        return true
    }

    internal func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
