//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
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
        if #available(iOS 13.0, *) {
            return postIOS13TimeString()
        } else {
            return preIOS13TimeString()
        }
    }
    
    /// :nodoc:
    private func preIOS13TimeString() -> String {
        let intValue = Int(base)
        let seconds = intValue % 60
        let minutes = (intValue / 60) % 60
        let hours = intValue / 60 / 60
        let format = "%02d"
        
        return [hours > 0 ? hours : nil, minutes, seconds]
            .compactMap { $0 }
            .map { String(format: format, $0) }
            .joined(separator: ":")
    }
    
    /// :nodoc
    private func postIOS13TimeString() -> String? {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = [.dropLeading, .pad]
        formatter.allowedUnits = [.hour, .minute, .second]
        return formatter.string(from: base)
    }
    
}
