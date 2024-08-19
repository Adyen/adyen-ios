//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

protocol ProjectBuilding {
    func build(source: ProjectSource, scheme: String?) async throws -> URL
}

struct ABIGeneratorOutput: Equatable {
    let targetName: String
    let abiJsonFileUrl: URL
}

protocol ABIGenerating {
    func generate(for projectDirectory: URL, scheme: String?, description: String) throws -> [ABIGeneratorOutput]
}

protocol SDKDumpGenerating {
    func generate(for abiJsonFileUrl: URL) throws -> SDKDump
}

protocol SDKDumpAnalyzing {
    func analyze(old: SDKDump, new: SDKDump) throws -> [Change]
}

protocol OutputGenerating {
    func generate(
        from changesPerTarget: [String: [Change]],
        allTargets: [String],
        oldSource: ProjectSource,
        newSource: ProjectSource
    ) throws -> String
}

protocol LibraryAnalyzing {
    /// Analyzes whether or not the available libraries changed between the old and new version
    func analyze(
        oldProjectUrl: URL,
        newProjectUrl: URL
    ) throws -> [Change]
}

enum LogLevel {
    case quiet
    case `default`
    case debug
}

protocol Logging {
    
    init(logLevel: LogLevel)
    func log(_ message: String, from subsystem: String)
    func debug(_ message: String, from subsystem: String)
}
