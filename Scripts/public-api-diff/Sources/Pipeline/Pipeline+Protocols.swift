//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 12/07/2024.
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
    func generate(for projectDirectory: URL, scheme: String?) throws -> [ABIGeneratorOutput]
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
    /// Analyzes whether or not the libraries/products changed between the old and new version
    func analyze(
        oldProjectUrl: URL,
        newProjectUrl: URL
    ) throws -> [Change]
}
