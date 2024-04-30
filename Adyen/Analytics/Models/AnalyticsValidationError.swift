//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Protocol created specially for analytics related validation errors.
@_spi(AdyenInternal)
public protocol AnalyticsValidationError: ValidationError {
    
    /// Code of the error for analytics.
    var analyticsErrorCode: Int { get }
    
    /// Message describing the error for analytics. Not meant for end users.
    var analyticsErrorMessage: String { get }
}
