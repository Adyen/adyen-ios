//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import OSLog

struct PipelineLogger: Logging {
    
    private let logLevel: LogLevel
    
    init(logLevel: LogLevel) {
        self.logLevel = logLevel
    }
    
    func log(
        _ message: String,
        from subsystem: String
    ) {
        switch logLevel {
        case .quiet:
            break
        case .debug, .default:
            logger(for: subsystem).log("\(message)")
        }
    }
    
    func debug(
        _ message: String,
        from subsystem: String
    ) {
        switch logLevel {
        case .quiet, .default:
            break
        case .debug:
            logger(for: subsystem).debug("\(message)")
        }
    }
}

private extension PipelineLogger {
    
    func logger(for subsystem: String) -> Logger {
        Logger(
            subsystem: subsystem,
            category: "" // TODO: Pass the description/tag so it can be differentiated
        )
    }
}
