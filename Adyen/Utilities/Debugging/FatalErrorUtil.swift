//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
/// Used for testing code that causes fatalError
public func fatalError(
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
) -> Never {
    FatalErrorUtil.fatalErrorClosure(message(), file, line)
}

/// :nodoc:
internal struct FatalErrorUtil {
    
    internal static var fatalErrorClosure: (String, StaticString, UInt) -> Never = defaultFatalErrorClosure
    
    private static let defaultFatalErrorClosure = { Swift.fatalError($0, file: $1, line: $2) }
    
    internal static func replaceFatalError(closure: @escaping (String, StaticString, UInt) -> Never) {
        fatalErrorClosure = closure
    }
    
    internal static func restoreFatalError() {
        fatalErrorClosure = defaultFatalErrorClosure
    }
    
}
