//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// So that any `TimeInterval` instance will inherit the `adyen` scope.
/// :nodoc:
extension TimeInterval: AdyenCompatible {}

/// Adds helper functionality to any `TimeInterval` instance through the `adyen` property.
/// :nodoc:
public extension AdyenScope where Base == TimeInterval {
    
    /// Transform `TimeInterval` to a `String` with either "MM:SS" or "HH:MM:SS" depending
    /// on whether number of full hours is bigger than 0
    func timeLeftString() -> String? {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = [.dropLeading, .pad]
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter.string(from: base)
    }
    
}
