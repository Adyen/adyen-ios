//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

struct MockLogger: Logging {
    
    let logLevel: LogLevel
    
    init() {
        self.init(logLevel: .debug)
    }
    
    var handleLog: (String, String) -> Void = { _, _ in
        XCTFail("Unexpectedly called `\(#function)`")
    }
    
    var handleDebug: (String, String) -> Void = { _, _ in
        XCTFail("Unexpectedly called `\(#function)`")
    }
    
    init(logLevel: LogLevel) {
        self.logLevel = logLevel
    }
    
    func log(_ message: String, from subsystem: String) {
        handleLog(message, subsystem)
    }
    
    func debug(_ message: String, from subsystem: String) {
        handleDebug(message, subsystem)
    }
}
