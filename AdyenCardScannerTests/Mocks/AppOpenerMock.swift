//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCardScanner
import UIKit

class AppOpenerMock: AppOpener {
    var openApplicationCallsCount = 0
    var openApplicationCalled: Bool {
        openApplicationCallsCount > 0
    }

    var openApplicationReceivedURL: URL?
    var openApplicationReceivedOptions: [UIApplication.OpenExternalURLOptionsKey: Any]?
    var openApplicationClosure: ((URL, [UIApplication.OpenExternalURLOptionsKey: Any]) async -> Void)?

    func openApp(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any]
    ) async {
        openApplicationCallsCount += 1
        openApplicationReceivedURL = url
        openApplicationReceivedOptions = options
        await openApplicationClosure?(url, options)
    }
}
