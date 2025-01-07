//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal enum ExampleContainer {
    case session(InitialDataFlowProtocol)
    case advanced(InitialDataAdvancedFlowProtocol)
}
