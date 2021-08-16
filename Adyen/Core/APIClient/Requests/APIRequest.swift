//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// :nodoc:
public protocol APIRequest: Request where ErrorResponseType == APIError {}
