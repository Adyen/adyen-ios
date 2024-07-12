//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 12/07/2024.
//

import Foundation

struct ProjectBuilder: ProjectBuilding {
    
    private let baseWorkingDirectoryPath: String
    private let fileHandler: FileHandling
    private let shell: ShellHandling
    
    init(
        baseWorkingDirectoryPath: String,
        fileHandler: FileHandling = FileManager.default,
        shell: ShellHandling = Shell()
    ) {
        self.baseWorkingDirectoryPath = baseWorkingDirectoryPath
        self.fileHandler = fileHandler
        self.shell = shell
    }
    
    func build(source: ProjectSource) throws -> URL {
        try setupProject(from: source)
    }
}

private extension ProjectBuilder {
    
    func setupProject(from source: ProjectSource) throws -> URL {
        
        let sourceDirectoryPath: String
        
        switch source {
        case let .local(path):
            sourceDirectoryPath = path
            
        case let .remote(branchOrTag, repository):
            sourceDirectoryPath = try retrieveRemoteProject(branchOrTag: branchOrTag, repository: repository)
        }

        let sourceWorkingDirectoryPath = baseWorkingDirectoryPath.appending("/\(UUID().uuidString)")
        
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
            xcodeTools: XcodeTools(shell: shell),
            fileHandler: fileHandler
        )
        
        switch source {
        case .local:
            break
        case .remote:
            // Clean up the cloned repo
            try fileHandler.removeItem(atPath: sourceDirectoryPath)
        }
        
        return URL(filePath: sourceWorkingDirectoryPath)
    }
    
    func retrieveRemoteProject(branchOrTag: String, repository: String) throws -> String {
        
        let currentDirectory = fileHandler.currentDirectoryPath
        let targetDirectoryPath = currentDirectory.appending("/\(UUID().uuidString)")
        
        let git = Git(shell: shell, fileHandler: fileHandler)
        try git.clone(repository, at: branchOrTag, targetDirectoryPath: targetDirectoryPath)
        return targetDirectoryPath
    }
    
    static func setupIndividualWorkingDirectory(
        at destinationDirectoryPath: String,
        sourceDirectoryPath: String,
        fileHandler: FileHandling,
        shell: ShellHandling
    ) throws {
        
        try fileHandler.createDirectory(atPath: destinationDirectoryPath)
        
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
        
        var fileExtensionIgnoreList: Set<String> = [
            ".yaml",
            ".yml",
            ".png",
            ".docc",
            ".md",
            ".resolved",
            ".podspec"
        ]
        
        if fileHandler.fileExists(atPath: PackageFileHelper.packagePath(for: sourceDirectoryPath)) {
            // Not copying over xcodeproj/xcworkspace files because otherwise
            // xcodebuild prefers them over the Package.swift file when building
            fileExtensionIgnoreList.insert(".xcodeproj")
            fileExtensionIgnoreList.insert(".xcworkspace")
        }
        
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
        xcodeTools: XcodeTools,
        fileHandler: FileHandling
    ) throws {
        
        let isPackage = fileHandler.fileExists(atPath: PackageFileHelper.packagePath(for: projectDirectoryPath))
        var scheme: String
        
        if isPackage {
            // Creating an `.library(name: "_allTargets", targets: [ALL_TARGETS])`
            // so we only have to build once and then can generate ABI files for every module from a single build
            scheme = "_AllTargets"
            try packageFileHelper.preparePackageWithConsolidatedLibrary(named: scheme)
        } else {
            fatalError("🚫 Only Swift Packages are supported for now")
        }
        
        print("🛠️ Building project at `\(projectDirectoryPath)`")
        
        try xcodeTools.build(
            projectDirectoryPath: projectDirectoryPath,
            scheme: scheme,
            isPackage: isPackage
        )
    }
}
