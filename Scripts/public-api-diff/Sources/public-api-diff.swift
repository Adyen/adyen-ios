//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import ArgumentParser
import Foundation

@main
struct PublicApiDiff: AsyncParsableCommand {
    
    @Option(help: "Specify the updated version to compare to")
    public var new: String
    
    @Option(help: "Specify the old version to compare to")
    public var old: String
    
    @Option(help: "Where to output the result (File path)")
    public var output: String?
    
    @Option(help: "Which scheme to build")
    public var scheme: String?
    
    public func run() async throws {
        
        let fileHandler: FileHandling = FileManager.default
        let oldSource = try ProjectSource.from(old, fileHandler: fileHandler)
        let newSource = try ProjectSource.from(new, fileHandler: fileHandler)
        let logger: any Logging = PipelineLogger(logLevel: .debug) // LogLevel should be provided by a parameter
        
        logger.log("Comparing `\(newSource.description)` to `\(oldSource.description)`", from: "Main")
        
        let currentDirectory = fileHandler.currentDirectoryPath
        let workingDirectoryPath = currentDirectory.appending("/tmp-public-api-diff")
        
        defer {
            logger.debug("Cleaning up", from: "Main")
            try? fileHandler.removeItem(atPath: workingDirectoryPath)
        }
        
        let pipelineOutput = try await Pipeline(
            newProjectSource: newSource,
            oldProjectSource: oldSource,
            scheme: scheme,
            projectBuilder: ProjectBuilder(baseWorkingDirectoryPath: workingDirectoryPath, logger: logger),
            abiGenerator: ABIGenerator(logger: logger),
            libraryAnalyzer: LibraryAnalyzer(),
            sdkDumpGenerator: SDKDumpGenerator(),
            sdkDumpAnalyzer: SDKDumpAnalyzer(),
            outputGenerator: MarkdownOutputGenerator(),
            logger: logger
        ).run()
        
        if let output {
            try fileHandler.write(pipelineOutput, to: output)
        } else {
            // We're not using a logger here as we always want to have it printed if no output was specified
            print(pipelineOutput)
        }
    }
}
