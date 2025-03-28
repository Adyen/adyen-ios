//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

////
//// Copyright (c) 2025 Adyen N.V.
////
//// This file is open source and available under the MIT license. See the LICENSE file for more info.
////
//
// import AVFoundation
// import Foundation
// import UIKit
//
// internal protocol CaptureAuthorizationServicing {
//    func requestAuthorization(in viewController: UIViewController) async -> Bool
// }
//
// internal class CaptureAuthorizationService: CaptureAuthorizationServicing {
//
//    internal func requestAuthorization(in viewController: UIViewController) async -> Bool {
//        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
//
//        var isAuthorized = false
//
//        switch authorizationStatus {
//        case .authorized:
//            isAuthorized = true
//        case .notDetermined:
//            isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
//        case .denied, .restricted:
//            isAuthorized = false
//            showCameraAccessDeniedAlert(in: viewController)
//        @unknown default:
//            isAuthorized = false
//            showCameraAccessDeniedAlert(in: viewController)
//        }
//
//        return isAuthorized
//    }
//
//    // MARK: - Private
//
//    private func showCameraAccessDeniedAlert(in viewController: UIViewController) {
//        let alert = UIAlertController(
//            title: "Camera Access Denied",
//            message: "Your app does not have permission to access the camera.",
//            preferredStyle: .alert
//        )
//
//        let settingsAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
//            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(settingsURL)
//            }
//        }
//        alert.addAction(settingsAction)
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
//            viewController.dismiss(animated: true)
//        }
//        alert.addAction(cancelAction)
//
//        viewController.present(alert, animated: true, completion: nil)
//    }
// }
