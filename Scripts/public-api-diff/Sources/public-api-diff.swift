import ArgumentParser
import Foundation

@main
struct PublicApiDiff: ParsableCommand {
    
    private enum Constants {
        static let deviceTarget: String = "x86_64-apple-ios17.4-simulator"
        static let destination: String = "platform=iOS,name=Any iOS Device"
        static let derivedDataPath: String = ".build"
        static let allTargetsLibraryName = "AdyenAllTargets"
        static let simulatorSdkCommand = "xcrun --sdk iphonesimulator --show-sdk-path"
    }
    
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

    private var comparisonVersionDirectoryName: String {
        "tmp_comparison_version_\(branch)"
    }
    
    public func run() throws {
        
        let comparisonVersionDirectoryPath = try setupComparisonRepository()
        try buildProject(at: comparisonVersionDirectoryPath)
        
        try buildProject(at: updatedSdkPath)
        
        let comparisonTargets = try availableTargets(at: comparisonVersionDirectoryPath)
        let updatedTargets = try availableTargets(at: updatedSdkPath)

        // Maybe check if the targets changed
        
        let allTargets = Set(comparisonTargets + updatedTargets).sorted()
        
        var changesPerTarget = [String: [SdkDumpAnalyzer.Change]]() // [ModuleName: [SdkDumpAnalyzer.Change]]
        
        try allTargets.forEach { targetName in
            let sdkDumpFilePath = try generateSdkDump(for: targetName, at: updatedSdkPath)
            let comparisonSdkDumpFilePath = try generateSdkDump(for: targetName, at: comparisonVersionDirectoryPath)
            
            print("🧐 [\(targetName)]\n-\(sdkDumpFilePath)\n-\(comparisonSdkDumpFilePath)")
            changesPerTarget[targetName] = try SdkDumpAnalyzer.diff(updated: sdkDumpFilePath, to: comparisonSdkDumpFilePath)
        }
        
        let diffOutput = generateOutput(from: changesPerTarget, allTargetNames: allTargets)
        try persistDiff(diffOutput, projectDirectoryPath: updatedSdkPath)
    }
}

private extension PublicApiDiff {
    
    func persistDiff(_ output: String, projectDirectoryPath: String) throws {
        
        guard let data = output.data(using: String.Encoding.utf8) else { return }
        
        let outputFilePath = projectDirectoryPath.appending("/api_comparison.md")
        let outputFileUrl = URL(filePath: outputFilePath)
        
        if FileManager.default.fileExists(atPath: outputFilePath) {
            try FileManager.default.removeItem(atPath: outputFilePath)
        }
        
        try data.write(to: outputFileUrl, options: .atomicWrite)
    }
    
    func generateOutput(from changesPerTarget: [String: [SdkDumpAnalyzer.Change]], allTargetNames: [String]) -> String {
        
        let footer: String = "**Analyzed modules:** \(allTargetNames.joined(separator: ", "))"
        
        if changesPerTarget.keys.isEmpty {
            return [
                "# ✅ No changes detected",
                footer
            ].joined(separator: "\n")
        }
        
        var lines = ["# 💔 Breaking changes detected"]
        
        changesPerTarget.keys.sorted().forEach { key in
            guard let changes = changesPerTarget[key], !changes.isEmpty else { return }
            
            if !key.isEmpty {
                lines.append("## `\(key)`")
            }
            
            var groupedChanges = [String: [SdkDumpAnalyzer.Change]]()

            changes.forEach {
                groupedChanges[$0.parentName] = (groupedChanges[$0.parentName] ?? []) + [$0]
            }
            
            groupedChanges.keys.sorted().forEach { parent in
                if let changes = groupedChanges[parent], !changes.isEmpty {
                    if !parent.isEmpty {
                        lines.append("### `\(parent)`")
                    }
                    groupedChanges[parent]?.forEach {
                        lines.append("- \($0.changeType.icon) \($0.changeDescription)")
                    }
                }
            }
        }
        
        lines.append("---")
        lines.append(footer)
        
        return lines.joined(separator: "\n")
    }
    
    func setupComparisonRepository() throws -> String {
        
        let currentDirectory = FileManager.default.currentDirectoryPath
        let comparisonVersionDirectoryPath = currentDirectory.appending("/\(comparisonVersionDirectoryName)")
        
        if FileManager.default.fileExists(atPath: comparisonVersionDirectoryPath) {
            try FileManager.default.removeItem(atPath: comparisonVersionDirectoryPath)
        }
        
        print("🐱 Cloning \(repository) @ \(branch) into \(comparisonVersionDirectoryPath)")
        Shell.execute("git clone -b \(branch) \(repository) \(comparisonVersionDirectoryName)")
        
        return comparisonVersionDirectoryPath
    }
    
    func buildProject(at path: String) throws {
        
        let packagePath = path.appending("/Package.swift")
        
        let packageFileHelper = PackageFileHelper(packagePath: packagePath)
        let xcodeProjectHelper = XcodeProjectHelper(projectDirectoryPath: path)
        
        try xcodeProjectHelper.prepare()
        try packageFileHelper.preparePackageWithConsolidatedLibrary(named: Constants.allTargetsLibraryName)
        
        let buildCommand = "cd \(path); xcodebuild -scheme \(Constants.allTargetsLibraryName) -sdk `\(Constants.simulatorSdkCommand)` -derivedDataPath \(Constants.derivedDataPath) -destination \"\(Constants.destination)\" -target \(Constants.deviceTarget) -skipPackagePluginValidation"
        
        print("🛠️ Building project at `\(path)`")
        Shell.execute(buildCommand)
        
        // Reverting all tmp changes
        try packageFileHelper.revertPackageChanges()
        try xcodeProjectHelper.revert()
    }
    
    func availableTargets(at projectDirectoryPath: String) throws -> [String] {
        
        let packagePath = projectDirectoryPath.appending("/Package.swift")
        let packageFileHelper = PackageFileHelper(packagePath: packagePath)
        return try packageFileHelper.availableTargets()
    }
    
    func generateSdkDump(for module: String, at projectDirectoryPath: String) throws -> String {
        
        let sdkDumpInputPath = projectDirectoryPath
            .appending("/\(Constants.derivedDataPath)")
            .appending("/Build/Products/Debug-iphonesimulator")
        
        let outputFilePath = projectDirectoryPath
            .appending("/api_dump.json")
        
        let dumpCommand = "cd \(projectDirectoryPath); xcrun swift-api-digester -dump-sdk -module \(module) -I \(sdkDumpInputPath) -o \(outputFilePath) -sdk `\(Constants.simulatorSdkCommand)` -target \(Constants.deviceTarget)"
        
        Shell.execute(dumpCommand)
        
        return outputFilePath
    }
}
