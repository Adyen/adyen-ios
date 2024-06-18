//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import ArgumentParser
import Foundation

enum Constants {
    static let deviceTarget: String = "x86_64-apple-ios17.4-simulator"
    static let destination: String = "platform=iOS,name=Any iOS Device"
    static let derivedDataPath: String = ".build"
    static let simulatorSdkCommand = "xcrun --sdk iphonesimulator --show-sdk-path"
}

@main
struct PublicApiDiff: ParsableCommand {
    
    /*
      // TODO: Use a source to specify both projects
     enum Source {
         case local(path: String)
         case remote(branch: String, url: String)
     }
      */
    
    @Option(help: "Path to the local version to compare")
    public var updatedSdkPath: String
    
    @Option(help: "Specify the branch you want compare")
    public var branch: String
    
    @Option(help: "Specify the url where the repository is available")
    public var repository: String
    
    
    public func run() throws {
        let workingDirectoryPath = updatedSdkPath.appending("/tmp-public-api-diff")
        
        do {
            try Self.createCleanDirectory(at: workingDirectoryPath)
            
            print("🏗️ Setting up working directory for current version")
            let currentVersionWorkingDirectoryPath = try Self.setupCurrentVersion(
                currentVersionDirectoryPath: updatedSdkPath,
                workingDirectoryPath: workingDirectoryPath
            )
            
            print("🏗️ Setting up working directory for comparison version")
            let comparisonVersionWorkingDirectoryPath = try Self.setupComparisonVersion(
                for: branch,
                of: repository,
                workingDirectoryPath: workingDirectoryPath
            )
            
            print("🔍 Scanning for products changes")
            let comparisonProducts = try availableProducts(at: comparisonVersionWorkingDirectoryPath)
            let currentProducts = try availableProducts(at: currentVersionWorkingDirectoryPath)
            
            var libraryChanges = [SdkDumpAnalyzer.Change]()
            
            let removedLibaries = comparisonProducts.subtracting(currentProducts)
            libraryChanges += removedLibaries.map {
                .init(
                    changeType: .removal,
                    parentName: "",
                    changeDescription: "`.library(name: \"\($0)\", ...)` was removed"
                )
            }
            
            let addedLibraries = currentProducts.subtracting(comparisonProducts)
            libraryChanges += addedLibraries.map {
                .init(
                    changeType: .addition,
                    parentName: "",
                    changeDescription: "`.library(name: \"\($0)\", ...)` was added"
                )
            }
            
            print("🔍 Scanning for breaking API changes")
            let comparisonTargets = try availableTargets(at: comparisonVersionWorkingDirectoryPath)
            let currentTargets = try availableTargets(at: currentVersionWorkingDirectoryPath)
            
            let allTargets = comparisonTargets.union(currentTargets).sorted()
            
            let updatedSdkDumper = SDKDumper(projectDirectoryPath: currentVersionWorkingDirectoryPath)
            let comparisonSdkDumper = SDKDumper(projectDirectoryPath: comparisonVersionWorkingDirectoryPath)
            
            var changesPerTarget = try Self.diffModules(
                for: allTargets,
                currentSdkDumper: updatedSdkDumper,
                comparisonSdkDumper: comparisonSdkDumper
            )
            
            changesPerTarget["Package.swift"] = (changesPerTarget["Package.swift"] ?? []) + libraryChanges
            
            let diffOutput = OutputGenerator.generate(
                from: changesPerTarget,
                allTargetNames: allTargets,
                branch: branch,
                repository: repository
            )
            
            try persistDiff(
                diffOutput,
                projectDirectoryPath: updatedSdkPath
            )
            
            // Delete working directory once we're done
            Shell.execute("rm -rf \(workingDirectoryPath)")
        } catch {
            // Delete working directory once we're done
            Shell.execute("rm -rf \(workingDirectoryPath)")
            throw error
        }
    }
}

private extension PublicApiDiff {
    
    static func diffModules(
        for allTargets: [String],
        currentSdkDumper: SDKDumper,
        comparisonSdkDumper: SDKDumper
    ) throws -> [String: [SdkDumpAnalyzer.Change]] {
        
        var changesPerTarget = [String: [SdkDumpAnalyzer.Change]]() // [ModuleName: [SdkDumpAnalyzer.Change]]
        
        try allTargets.forEach { targetName in
            let currentSdkDumpFilePath = currentSdkDumper.generate(for: targetName)
            let comparisonSdkDumpFilePath = comparisonSdkDumper.generate(for: targetName)
            
            let diff = try SdkDumpAnalyzer.diff(updated: currentSdkDumpFilePath, to: comparisonSdkDumpFilePath)
            if !diff.isEmpty { changesPerTarget[targetName] = diff }
        }
        
        return changesPerTarget
    }
    
    static func setupCurrentVersion(currentVersionDirectoryPath: String, workingDirectoryPath: String) throws -> String {
        
        let currentVersionWorkingDirectoryPath = workingDirectoryPath.appending("/current")

        try setupIndividualWorkingDirectory(
            at: currentVersionWorkingDirectoryPath,
            sourceDirectoryPath: currentVersionDirectoryPath,
            baseWorkingDirectoryPath: workingDirectoryPath
        )
        
        try buildProject(at: currentVersionWorkingDirectoryPath)
        
        return currentVersionWorkingDirectoryPath
    }
    
    static func setupComparisonVersion(for branch: String, of repository: String, workingDirectoryPath: String) throws -> String {
        
        let comparisonVersionDirectoryPath = fetchComparisonRepository(for: branch, of: repository)
        
        let comparisonVersionWorkingDirectoryPath = workingDirectoryPath.appending("/comparison")
        
        try setupIndividualWorkingDirectory(
            at: comparisonVersionWorkingDirectoryPath,
            sourceDirectoryPath: comparisonVersionDirectoryPath,
            baseWorkingDirectoryPath: workingDirectoryPath
        )
        
        try buildProject(at: comparisonVersionWorkingDirectoryPath)
        
        return comparisonVersionWorkingDirectoryPath
    }
    
    static func setupIndividualWorkingDirectory(
        at destinationDirectoryPath: String,
        sourceDirectoryPath: String,
        baseWorkingDirectoryPath: String
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
            "Cartfile",
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
            
            if sourceFilePath == baseWorkingDirectoryPath { return }
            
            Shell.execute("cp -a \(sourceFilePath) \(destinationFilePath)")
        }
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
    
    func persistDiff(_ output: String, projectDirectoryPath: String) throws {
        
        guard let data = output.data(using: String.Encoding.utf8) else { return }
        
        let outputFilePath = projectDirectoryPath.appending("/api_comparison.md")
        let outputFileUrl = URL(filePath: outputFilePath)
        
        if FileManager.default.fileExists(atPath: outputFilePath) {
            try FileManager.default.removeItem(atPath: outputFilePath)
        }
        
        try data.write(to: outputFileUrl, options: .atomicWrite)
    }
    
    /// Returns the Package.swift file path if available
    static func fetchComparisonRepository(for branch: String, of repository: String) -> String {
        
        let currentDirectory = FileManager.default.currentDirectoryPath
        let targetDirectoryPath = currentDirectory.appending(UUID().uuidString)
        
        try? FileManager.default.removeItem(atPath: targetDirectoryPath)
        
        clone(branch, of: repository, into: targetDirectoryPath)
        
        return targetDirectoryPath
    }
    
    static func clone(_ branch: String, of repository: String, into targetDirectoryPath: String) {
        
        print("🐱 Cloning \(repository) @ \(branch) into \(targetDirectoryPath)")
        Shell.execute("git clone -b \(branch) \(repository) \(targetDirectoryPath)")
    }
    
    static func buildProject(at path: String) throws {
        
        let allTargetsLibraryName = "AdyenAllTargets"
        let packagePath = path.appending("/Package.swift")
        
        let packageFileHelper = PackageFileHelper(packagePath: packagePath)
        try packageFileHelper.preparePackageWithConsolidatedLibrary(named: allTargetsLibraryName)
        
        let buildCommand = "cd \(path); xcodebuild -scheme \(allTargetsLibraryName) -sdk `\(Constants.simulatorSdkCommand)` -derivedDataPath \(Constants.derivedDataPath) -destination \"\(Constants.destination)\" -target \(Constants.deviceTarget) -skipPackagePluginValidation"
        
        print("🛠️ Building project at `\(path)`")
        Shell.execute(buildCommand)
    }
    
    func availableTargets(at projectDirectoryPath: String) throws -> Set<String> {
        
        let packagePath = projectDirectoryPath.appending("/Package.swift")
        let packageFileHelper = PackageFileHelper(packagePath: packagePath)
        return try packageFileHelper.availableTargets()
    }
    
    func availableProducts(at projectDirectoryPath: String) throws -> Set<String> {
        
        let packagePath = projectDirectoryPath.appending("/Package.swift")
        let packageFileHelper = PackageFileHelper(packagePath: packagePath)
        return try packageFileHelper.availableProducts()
    }
}
