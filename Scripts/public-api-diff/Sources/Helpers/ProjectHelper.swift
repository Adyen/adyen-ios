//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct ProjectHelper {
    
    private let workingDirectoryPath: String
    private let fileHandler: FileHandling
    private let shell: ShellHandling
    
    init(
        workingDirectoryPath: String,
        fileHandler: FileHandling,
        shell: ShellHandling
    ) {
        self.workingDirectoryPath = workingDirectoryPath
        self.fileHandler = fileHandler
        self.shell = shell
    }
    
    func setup(
        old oldSource: ProjectSource,
        new newSource: ProjectSource,
        _ body: (_ oldWorkingDirectoryPath: String, _ newWorkingDirectoryPath: String) throws -> Void
    ) throws {
        
        try fileHandler.createCleanDirectory(atPath: workingDirectoryPath)
        defer { cleanup() }
        
        do {
            print("🏗️ Setting up working directory for new version")
            let newWorkingDirectoryPath = try setupProject(from: newSource)
            
            print("🏗️ Setting up working directory for old version")
            let oldWorkingDirectoryPath = try setupProject(from: oldSource)
            
            try body(oldWorkingDirectoryPath, newWorkingDirectoryPath)
        } catch {
            cleanup()
            throw error
        }
    }
}

private extension ProjectHelper {

    func retrieveRemoteProject(branchOrTag: String, repository: String) -> String {
        
        let currentDirectory = fileHandler.currentDirectoryPath
        let targetDirectoryPath = currentDirectory.appending("\(UUID().uuidString)")
        
        try? fileHandler.removeItem(atPath: targetDirectoryPath)
        
        let git = Git(shell: shell)
        git.clone(repository, at: branchOrTag, targetDirectoryPath: targetDirectoryPath)
        return targetDirectoryPath
    }
    
    func setupProject(from source: ProjectSource) throws -> String {
        
        let sourceDirectoryPath: String
        
        switch source {
        case let .local(path):
            sourceDirectoryPath = path
            
        case let .remote(branchOrTag, repository):
            sourceDirectoryPath = retrieveRemoteProject(branchOrTag: branchOrTag, repository: repository)
        }

        let sourceWorkingDirectoryPath = workingDirectoryPath.appending("/\(UUID().uuidString)")
        
        try Self.setupIndividualWorkingDirectory(
            at: sourceWorkingDirectoryPath,
            sourceDirectoryPath: sourceDirectoryPath,
            fileHandler: fileHandler,
            shell: shell
        )
        
        let packagePath = PackageFileHelper.packagePath(for: sourceWorkingDirectoryPath)
        
        try Self.buildProject(
            projectDirectoryPath: sourceWorkingDirectoryPath,
            packageFileHelper: PackageFileHelper(packagePath: packagePath, fileHandler: fileHandler),
            xcodeTools: XcodeTools(shell: shell)
        )
        
        switch source {
        case .local:
            break
        case .remote:
            // Clean up the cloned repo
            try? fileHandler.removeItem(atPath: sourceDirectoryPath)
        }
        
        return sourceWorkingDirectoryPath
    }
    
    static func setupIndividualWorkingDirectory(
        at destinationDirectoryPath: String,
        sourceDirectoryPath: String,
        fileHandler: FileHandling,
        shell: ShellHandling
    ) throws {
        
        try? fileHandler.removeItem(atPath: destinationDirectoryPath)
        try fileHandler.createDirectory(atPath: destinationDirectoryPath)
        
        // TODO: Have 1 list instead and use a regex to filter (Maybe also move this to a file)
        
        let fileNameIgnoreList: Set<String> = [
            ".build",
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
        
        try fileHandler.contentsOfDirectory(atPath: sourceDirectoryPath).forEach { fileName in
            if fileExtensionIgnoreList.contains(where: { fileName.hasSuffix($0) }) { return }
            if fileNameIgnoreList.contains(where: { fileName == $0 }) { return }
            
            let sourceFilePath = sourceDirectoryPath.appending("/\(fileName)")
            let destinationFilePath = destinationDirectoryPath.appending("/\(fileName)")
            
            // Using shell here as it's faster than the FileManager
            shell.execute("cp -a \(sourceFilePath) \(destinationFilePath)")
        }
    }
    
    static func buildProject(
        projectDirectoryPath: String,
        packageFileHelper: PackageFileHelper,
        xcodeTools: XcodeTools
    ) throws {
        
        let allTargetsLibraryName = "_AllTargets"
        try packageFileHelper.preparePackageWithConsolidatedLibrary(named: allTargetsLibraryName)
        
        print("🛠️ Building project at `\(projectDirectoryPath)`")
        
        try xcodeTools.build(
            projectDirectoryPath: projectDirectoryPath,
            allTargetsLibraryName: allTargetsLibraryName
        )
    }
    
    func cleanup() {
        try? fileHandler.removeItem(atPath: workingDirectoryPath)
    }
}
