//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import ArgumentParser
import Foundation

@main
struct PublicApiDiff: ParsableCommand {
    
    // TODO: Do more documentation
    @Option(help: "Specify the updated version to compare to")
    public var new: String
    
    // TODO: Do more documentation
    @Option(help: "Specify the old version to compare to")
    public var old: String
    
    @Option(help: "Where to output the result (File path)")
    public var output: String?
    
    public func run() throws {
        
        let fileHandler = FileManager.default
        let oldSource = try ProjectSource.from(old, fileHandler: fileHandler)
        let newSource = try ProjectSource.from(new, fileHandler: fileHandler)
        
        print("Comparing `\(newSource.description)` to `\(oldSource.description)`")
        
        let currentDirectory = fileHandler.currentDirectoryPath
        let workingDirectoryPath = currentDirectory.appending("/tmp-public-api-diff")
        
        let pipelineOutput = try Pipeline(
            newProjectSource: newSource,
            oldProjectSource: oldSource,
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
