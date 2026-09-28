//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes the action the SDK is about to present.
public struct ActionData {

    /// The type of the action, as returned in the `/payments` response.
    public let type: ActionType

    package init(type: ActionType) {
        self.type = type
    }
}
