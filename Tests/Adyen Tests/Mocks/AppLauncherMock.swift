//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import Foundation

final class AppLauncherMock: AnyAppLauncher {
    
    var onOpenCustomSchemeUrl: ((_ url: URL, _ completion: ((Bool) -> Void)?) -> Void)?
    
    func openCustomSchemeUrl(_ url: URL, completion: ((Bool) -> Void)?) {
        onOpenCustomSchemeUrl?(url, completion)
    }
    
    var onOpenUniversalAppUrl: ((_ url: URL, _ completion: ((Bool) -> Void)?) -> Void)?
    
    func openUniversalAppUrl(_ url: URL, completion: ((Bool) -> Void)?) {
        onOpenUniversalAppUrl?(url, completion)
    }
    
}
