//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol NavigationProtocol: PresentationDelegate {

    func dismiss(completion: (() -> Void)?)

}
