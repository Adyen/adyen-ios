//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct Pipeline {
    
    let newProjectSource: ProjectSource
    let oldProjectSource: ProjectSource
    let scheme: String?
    
    let projectBuilder: any ProjectBuilding
    let abiGenerator: any ABIGenerating
    let libraryAnalyzer: any LibraryAnalyzing
    let sdkDumpGenerator: any SDKDumpGenerating
    let sdkDumpAnalyzer: any SDKDumpAnalyzing
    let outputGenerator: any OutputGenerating
    let logger: (any Logging)?
    
    init(
        newProjectSource: ProjectSource,
        oldProjectSource: ProjectSource,
        scheme: String?,
        projectBuilder: any ProjectBuilding,
        abiGenerator: any ABIGenerating,
        libraryAnalyzer: any LibraryAnalyzing,
        sdkDumpGenerator: any SDKDumpGenerating,
        sdkDumpAnalyzer: any SDKDumpAnalyzing,
        outputGenerator: any OutputGenerating,
        logger: (any Logging)?
    ) {
        self.newProjectSource = newProjectSource
        self.oldProjectSource = oldProjectSource
        self.scheme = scheme
        self.projectBuilder = projectBuilder
        self.abiGenerator = abiGenerator
        self.libraryAnalyzer = libraryAnalyzer
        self.sdkDumpGenerator = sdkDumpGenerator
        self.sdkDumpAnalyzer = sdkDumpAnalyzer
        self.outputGenerator = outputGenerator
        self.logger = logger
    }
    
    func run() async throws -> String {
        
        let (oldProjectUrl, newProjectUrl) = try await buildProjects(
            oldSource: oldProjectSource,
            newSource: newProjectSource,
            scheme: scheme
        )
        
        var changes = [String: [Change]]()
        
        try analyzeLibraryChanges(
            oldProjectUrl: oldProjectUrl,
            newProjectUrl: newProjectUrl,
            changes: &changes
        )
        
        let allTargets = try analyzeApiChanges(
            oldProjectUrl: oldProjectUrl,
            newProjectUrl: newProjectUrl,
            changes: &changes
        )
        
        return try outputGenerator.generate(
            from: changes,
            allTargets: allTargets.sorted(),
            oldSource: oldProjectSource,
            newSource: newProjectSource
        )
    }
}

// MARK: - Convenience Methods

private extension Pipeline {
    
    func buildProjects(oldSource: ProjectSource, newSource: ProjectSource, scheme: String?) async throws -> (URL, URL) {
        async let oldBuildResult = try projectBuilder.build(
            source: oldProjectSource,
            scheme: scheme
        )
        
        async let newBuildResult = try projectBuilder.build(
            source: newProjectSource,
            scheme: scheme
        )
        
        // Awaiting the result of the async builds
        let oldProjectUrl = try await oldBuildResult
        let newProjectUrl = try await newBuildResult
        
        return (oldProjectUrl, newProjectUrl)
    }
    
    func generateAbiFiles(
        oldProjectUrl: URL,
        newProjectUrl: URL,
        scheme: String?
    ) throws -> ([ABIGeneratorOutput], [ABIGeneratorOutput]) {
        
        let oldAbiFiles = try abiGenerator.generate(
            for: oldProjectUrl,
            scheme: scheme,
            description: oldProjectSource.description
        )
        
        let newAbiFiles = try abiGenerator.generate(
            for: newProjectUrl,
            scheme: scheme,
            description: newProjectSource.description
        )
        
        return (oldAbiFiles, newAbiFiles)
    }
    
    func allTargetNames(from lhs: [ABIGeneratorOutput], and rhs: [ABIGeneratorOutput]) throws -> [String] {
        let allTargets = Set(lhs.map(\.targetName)).union(Set(rhs.map(\.targetName)))
        if allTargets.isEmpty { throw PipelineError.noTargetFound }
        return allTargets.sorted()
    }
    
    func analyzeLibraryChanges(oldProjectUrl: URL, newProjectUrl: URL, changes: inout [String: [Change]]) throws {
        // Analyzing if there are any changes in available libraries between the project versions
        let libraryChanges = try libraryAnalyzer.analyze(
            oldProjectUrl: oldProjectUrl,
            newProjectUrl: newProjectUrl
        )
        
        if !libraryChanges.isEmpty {
            changes[""] = libraryChanges
        }
    }
    
    func analyzeApiChanges(oldProjectUrl: URL, newProjectUrl: URL, changes: inout [String: [Change]]) throws -> [String] {
        
        let (oldAbiFiles, newAbiFiles) = try generateAbiFiles(
            oldProjectUrl: oldProjectUrl,
            newProjectUrl: newProjectUrl,
            scheme: scheme
        )
        
        let allTargets = try allTargetNames(
            from: oldAbiFiles,
            and: newAbiFiles
        )
        
        // Goes through all the available abi files and compares them
        try allTargets.forEach { target in
            guard let oldAbiJson = oldAbiFiles.abiJsonFileUrl(for: target) else {
                return changes[target] = [.removedTarget]
            }
            
            guard let newAbiJson = newAbiFiles.abiJsonFileUrl(for: target) else {
                return changes[target] = [.addedTarget]
            }
            
            /*
             // Using `xcrun --sdk iphoneos swift-api-digester -diagnose-sdk` instead of the custom parser
             let diagnose = XcodeTools().diagnoseSdk(
                 oldAbiJsonFilePath: oldAbiJson.path(),
                 newAbiJsonFilePath: newAbiJson.path(),
                 module: target
             )
            
             print(diagnose)
             */
            
            // Generate SDKDump objects
            let oldSDKDump = try sdkDumpGenerator.generate(for: oldAbiJson)
            let newSDKDump = try sdkDumpGenerator.generate(for: newAbiJson)
            
            // Compare SDKDump objects
            let targetChanges = try sdkDumpAnalyzer.analyze(
                old: oldSDKDump,
                new: newSDKDump
            )
            
            if !targetChanges.isEmpty {
                changes[target] = targetChanges
            }
        }
        
        return allTargets
    }
}

// MARK: - Convenience

private extension Change {
    
    static var removedTarget: Self {
        .init(changeType: .removal(description: "Target was removed"), parentName: "")
    }

    static var addedTarget: Self {
        .init(changeType: .addition(description: "Target was added"), parentName: "")
    }
}

private extension [String: [Change]] {
    
    mutating func append(change: Change, to moduleName: String) {
        self[moduleName] = (self[moduleName] ?? []) + [change]
    }
}

private extension [ABIGeneratorOutput] {
    
    func abiJsonFileUrl(for targetName: String) -> URL? {
        first { $0.targetName == targetName }?.abiJsonFileUrl
    }
}
