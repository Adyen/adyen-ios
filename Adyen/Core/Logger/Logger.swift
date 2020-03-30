//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A printing to the console is done through this logger to be able to turn it off in production.
private var logger = Logger()

/// A printing to the console is done through this logger to be able to turn it off in production.
private class Logger: TextOutputStream {
    
    /// Writes a string to the stream.
    ///
    /// - Parameter string: A string to write into the stream.
    internal func write(_ string: String) {
        guard AdyenLogging.isEnabled else { return }
        let stdOut = FileHandle.standardOutput
        guard let data = string.data(using: .utf8) else { return }
        stdOut.write(data)
    }
    
}

public enum AdyenLogging {
    /// Indicates whether to enable printing to the console.
    public static var isEnabled: Bool = false
}

/// Copies the interface of `Swift.print()`, and `Swift.print()` is called inside with a custom `TextOutputStream`.
/// :nodoc:
public func adyenPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    Swift.print(items, separator: separator, terminator: terminator, to: &logger)
}
