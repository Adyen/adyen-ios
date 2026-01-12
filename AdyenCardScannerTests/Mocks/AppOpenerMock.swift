//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCardScanner
import UIKit

class AppOpenerMock: AppOpener {
    var openSettingsAppCallsCount = 0
    var openSettingsAppCalled: Bool {
        openSettingsAppCallsCount > 0
    }

    var openSettingsAppClosure: (() async -> Void)?
    
    func openSettingsApp() async {
        openSettingsAppCallsCount += 1
        await openSettingsAppClosure?()
    }
}
