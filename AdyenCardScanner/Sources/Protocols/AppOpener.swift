//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

internal protocol AppOpener {
    @available(iOS 13.0, *)
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
