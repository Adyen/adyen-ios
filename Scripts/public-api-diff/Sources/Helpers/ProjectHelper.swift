//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct ProjectHelper {
    
    let workingDirectoryPath: String
    
    init(workingDirectoryPath: String) throws {
        self.workingDirectoryPath = workingDirectoryPath
    }
    
    func setup(
        old oldSource: ProjectSource,
        new newSource: ProjectSource,
        _ body: (_ oldWorkingDirectoryPath: String, _ newWorkingDirectoryPath: String) throws -> Void
    ) throws {
        
        try Self.createCleanDirectory(at: workingDirectoryPath)
        defer { cleanup() }
        
        do {
            print("🏗️ Setting up working directory for new version")
            let newWorkingDirectoryPath = try setupProject(from: newSource)
            
            print("🏗️ Setting up working directory for old version")
            let oldWorkingDirectoryPath = try setupProject(from: oldSource)
            
            try body(oldWorkingDirectoryPath, newWorkingDirectoryPath)
        } catch {
            cleanup()
        }
    }
}

private extension ProjectHelper {

    func setupProject(from source: ProjectSource) throws -> String {
        
        let sourceDirectoryPath: String
        
        switch source {
        case let .local(path):
            sourceDirectoryPath = path
        case let .remote(branchOrTag, repository):
            sourceDirectoryPath = Git.clone(repository, at: branchOrTag)
        }

        let sourceWorkingDirectoryPath = workingDirectoryPath.appending("/\(UUID().uuidString)")
        
        try Self.setupIndividualWorkingDirectory(
            at: sourceWorkingDirectoryPath,
            sourceDirectoryPath: sourceDirectoryPath
        )
        
        try Self.buildProject(at: sourceWorkingDirectoryPath)
        
        switch source {
        case .local:
            break
        case .remote:
            // Clean up the cloned repo
            Shell.removeDirectory(at: sourceDirectoryPath)
        }
        
        return sourceWorkingDirectoryPath
    }
    
    static func setupIndividualWorkingDirectory(
        at destinationDirectoryPath: String,
        sourceDirectoryPath: String
    ) throws {
        
        try? FileManager.default.removeItem(atPath: destinationDirectoryPath)
        try FileManager.default.createDirectory(atPath: destinationDirectoryPath, withIntermediateDirectories: true)
        
        let fileNameIgnoreList: Set<String> = [
            Constants.derivedDataPath,
            ".git",
            ".github",
            ".gitmodules",
            ".codebeatignore",
            ".swiftformat",
            ".swiftpm",
            ".DS_Store",
            "Tests",
            "Cartfile"
        ]
        
        let fileExtensionIgnoreList: Set<String> = [
            ".yaml",
            ".yml",
            ".png",
            ".docc",
            ".xcodeproj",
            ".xcworkspace",
            ".md",
            ".resolved",
            ".podspec"
        ]
        
        try FileManager.default.contentsOfDirectory(atPath: sourceDirectoryPath).forEach { fileName in
            if fileExtensionIgnoreList.contains(where: { fileName.hasSuffix($0) }) { return }
            if fileNameIgnoreList.contains(where: { fileName == $0 }) { return }
            
            let sourceFilePath = sourceDirectoryPath.appending("/\(fileName)")
            let destinationFilePath = destinationDirectoryPath.appending("/\(fileName)")
            
            Shell.execute("cp -a \(sourceFilePath) \(destinationFilePath)")
        }
    }
    
    static func buildProject(at path: String) throws {
        
        let allTargetsLibraryName = "_AllTargets"
        let packagePath = PackageFileHelper.packagePath(for: path)
        
        try PackageFileHelper(packagePath: packagePath)
            .preparePackageWithConsolidatedLibrary(named: allTargetsLibraryName)
        
        let buildCommand = "cd \(path); xcodebuild -scheme \(allTargetsLibraryName) -sdk `\(Constants.simulatorSdkCommand)` -derivedDataPath \(Constants.derivedDataPath) -destination \"\(Constants.destination)\" -target \(Constants.deviceTarget) -skipPackagePluginValidation"
        
        print("🛠️ Building project at `\(path)`")
        Shell.execute(buildCommand)
    }
    
    static func createCleanDirectory(at cleanDirectoryPath: String) throws {
        
        if FileManager.default.fileExists(atPath: cleanDirectoryPath) {
            try FileManager.default.removeItem(atPath: cleanDirectoryPath)
        }
        
        try FileManager.default.createDirectory(
            at: URL(filePath: cleanDirectoryPath),
            withIntermediateDirectories: true
        )
    }
    
    func cleanup() {
        Shell.removeDirectory(at: workingDirectoryPath)
    }
}
