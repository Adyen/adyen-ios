//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

internal protocol AppOpener {
    func openApp(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any]
    ) async
}

extension UIApplication: AppOpener {
    
    func openApp(
        _ url: URL,
        options: [OpenExternalURLOptionsKey: Any]
    ) async {
        await open(url, options: options)
    }
}
