//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AVFoundation
import Foundation
import UIKit

internal protocol CaptureAuthorizationServicing {
    //    var isAuthorized: Bool { get }
    func requestAuthorization() async -> Bool
}

internal class CaptureAuthorizationService: CaptureAuthorizationServicing {

    func requestAuthorization() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        var isAuthorized = false

        switch status {
        case .notDetermined:
            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        case .restricted:
            isAuthorized = false
        case .denied:
            isAuthorized = false
            // Redirect to the settings app.
            redirectToSettingsApp()
        case .authorized:
            isAuthorized = true
        @unknown default:
            isAuthorized = false
        }

        return isAuthorized
    }

    // MARK: - Private

    func redirectToSettingsApp() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL) { success in
                print("Settings opened: \(success)")
            }
        }
    }

}
