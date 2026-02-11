//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public struct CardScannerError: LocalizedError {

    public enum Kind {
        case cameraSetup
        case photoProcessing
        case authorizationDenied
        case capture
    }

    // MARK: - Properties

    public var kind: Kind
    public var underlyingError: Error?
    public var errorDescription: String? {
        (underlyingError as? LocalizedError)?.errorDescription
    }
}
