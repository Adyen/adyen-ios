//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import ArgumentParser
import Foundation

@main
struct PublicApiDiff: AsyncParsableCommand {
    
    // TODO: Do more documentation
    @Option(help: "Specify the updated version to compare to")
    public var new: String
    
    // TODO: Do more documentation
    @Option(help: "Specify the old version to compare to")
    public var old: String
    
    @Option(help: "Where to output the result (File path)")
    public var output: String?
    
    @Option(help: "Which scheme to build")
    public var scheme: String?
    
    public func run() async throws {
        
        let fileHandler = FileManager.default
        let oldSource = try ProjectSource.from(old, fileHandler: fileHandler)
        let newSource = try ProjectSource.from(new, fileHandler: fileHandler)
        
        print("Comparing `\(newSource.description)` to `\(oldSource.description)`")
        
        let currentDirectory = fileHandler.currentDirectoryPath
        let workingDirectoryPath = currentDirectory.appending("/tmp-public-api-diff")
        
        let pipelineOutput = try await Pipeline(
            newProjectSource: newSource,
            oldProjectSource: oldSource,
            scheme: scheme,
            projectBuilder: ProjectBuilder(baseWorkingDirectoryPath: workingDirectoryPath),
            abiGenerator: ABIGenerator(),
            libraryAnalyzer: LibraryAnalyzer(),
            sdkDumpGenerator: SDKDumpGenerator(),
            sdkDumpAnalyzer: SDKDumpAnalyzer(),
            outputGenerator: MarkdownOutputGenerator()
        ).run()
        
        if let output {
            try fileHandler.write(pipelineOutput, to: output)
        } else {
            print(pipelineOutput)
        }
    }
}
