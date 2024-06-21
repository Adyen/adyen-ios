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

enum ProjectSource: RawRepresentable {
    typealias RawValue = String
    
    case local(path: String)
    case remote(branch: String, repository: String)
 
    init?(rawValue: String) {
        if FileManager.default.fileExists(atPath: rawValue) {
            self = .local(path: rawValue)
            return
        }
        
        let remoteComponents = rawValue.components(separatedBy: ";")
        if remoteComponents.count == 2, let branch = remoteComponents.first, let repository = remoteComponents.last {
            self = .remote(branch: branch, repository: repository)
            return
        }
        
        return nil
    }
    
    var rawValue: String {
        switch self {
        case let .local(path):
            return path
        case let .remote(branch, repository):
            return "\(branch);\(repository)"
        }
    }
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
    
    private var newSource: ProjectSource { .init(rawValue: new)! }
    private var oldSource: ProjectSource { .init(rawValue: old)! }
    
    public func run() throws {
        
        print("Comparing `\(newSource.rawValue)` to `\(oldSource.rawValue)`")
        
        let currentDirectory = FileManager.default.currentDirectoryPath
        let workingDirectoryPath = currentDirectory.appending("/tmp-public-api-diff")
        
        try ProjectHelper(
            workingDirectoryPath: workingDirectoryPath
        ).setup(
            old: oldSource,
            new: newSource
        ) {
            oldProjectDirectoryPath,
                newProjectDirectoryPath in
            
            let changesPerTarget = try SDKAnalyzer.analyze(
                old: oldProjectDirectoryPath,
                new: newProjectDirectoryPath
            )
            
            let allAvailableTargets = try PackageFileHelper.availableTargets(
                oldProjectDirectoryPath: oldProjectDirectoryPath,
                newProjectDirectoryPath: newProjectDirectoryPath
            )
            
            let outputGenerator = OutputGenerator(
                changesPerTarget: changesPerTarget,
                allTargetNames: allAvailableTargets,
                oldSource: oldSource,
                newSource: newSource
            )
            
            let diffOutput = outputGenerator.generate()
            
            if let output {
                try FileManager.default.write(diffOutput, to: output)
            } else {
                print(diffOutput)
            }
        }
    }
}
