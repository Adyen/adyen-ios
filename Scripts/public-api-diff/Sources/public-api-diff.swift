//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import ArgumentParser
import Foundation

// TODO: Add UnitTests

enum Constants {
    static let deviceTarget: String = "x86_64-apple-ios17.4-simulator"
    static let destination: String = "platform=iOS,name=Any iOS Device"
    static let derivedDataPath: String = ".build"
    static let simulatorSdkCommand = "xcrun --sdk iphonesimulator --show-sdk-path"
}

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
        
        // TODO: Move all of this code into a single testable module
        
        let shell = Shell()
        let fileHandler = FileManager.default
        let oldSource = try ProjectSource.from(old, fileHandler: fileHandler)
        let newSource = try ProjectSource.from(new, fileHandler: fileHandler)
        
        print("Comparing `\(newSource.description)` to `\(oldSource.description)`")
        
        let currentDirectory = fileHandler.currentDirectoryPath
        let workingDirectoryPath = currentDirectory.appending("/tmp-public-api-diff")
        
        let projectHelper = ProjectHelper(
            workingDirectoryPath: workingDirectoryPath,
            fileHandler: fileHandler,
            shell: shell
        )
        
        try projectHelper.setup(
            old: oldSource,
            new: newSource
        ) { oldProjectDirectoryPath, newProjectDirectoryPath in
            
            let changesPerTarget = try SDKAnalyzer.analyze(
                old: oldProjectDirectoryPath,
                new: newProjectDirectoryPath,
                fileHandler: fileHandler,
                shell: shell
            )
            
            let allAvailableTargets = try PackageFileHelper.availableTargets(
                oldProjectDirectoryPath: oldProjectDirectoryPath,
                newProjectDirectoryPath: newProjectDirectoryPath,
                fileHandler: fileHandler
            )
            
            let outputGenerator = OutputGenerator(
                changesPerTarget: changesPerTarget,
                allTargetNames: allAvailableTargets,
                oldSource: oldSource,
                newSource: newSource
            )
            
            let diffOutput = outputGenerator.generate()
            
            if let output {
                try fileHandler.write(diffOutput, to: output)
            } else {
                print(diffOutput)
            }
        }
    }
}
