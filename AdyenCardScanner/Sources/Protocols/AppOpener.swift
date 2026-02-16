//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

@available(iOS 13.0, *)
internal protocol AppOpener {
    func openSettingsApp() async
}

@available(iOS 13.0, *)
extension UIApplication: AppOpener {

    func openSettingsApp() async {
        guard let settingsAppURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        await open(settingsAppURL, options: [:])
    }
}
