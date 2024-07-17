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
    private let logger: Logging?
    
    init(
        baseWorkingDirectoryPath: String,
        fileHandler: FileHandling = FileManager.default,
        shell: ShellHandling = Shell(),
        logger: Logging?
    ) {
        self.baseWorkingDirectoryPath = baseWorkingDirectoryPath
        self.fileHandler = fileHandler
        self.shell = shell
        self.logger = logger
    }
    
    func build(source: ProjectSource, scheme: String?) throws -> URL {
        let sourceDirectoryPath: String = try {
            switch source {
            case let .local(path):
                path
                
            case let .remote(branchOrTag, repository):
                try retrieveRemoteProject(branchOrTag: branchOrTag, repository: repository)
            }
        }()
        
        let sourceWorkingDirectoryPath = try buildSource(from: sourceDirectoryPath, scheme: scheme)
        
        switch source {
        case .local:
            break
        case .remote:
            // Clean up the cloned repo
            try fileHandler.removeItem(atPath: sourceDirectoryPath)
        }
        
        return sourceWorkingDirectoryPath
    }
}

private extension ProjectBuilder {
    
    func buildSource(from sourceDirectoryPath: String, scheme: String?) throws -> URL {
        
        let sourceWorkingDirectoryPath = baseWorkingDirectoryPath.appending("/\(UUID().uuidString)")
        
        try Self.setupIndividualWorkingDirectory(
            at: sourceWorkingDirectoryPath,
            sourceDirectoryPath: sourceDirectoryPath,
            fileHandler: fileHandler,
            shell: shell,
            isPackage: scheme == nil,
            logger: logger
        )
        
        let packagePath = PackageFileHelper.packagePath(for: sourceWorkingDirectoryPath)
        
        try Self.buildProject(
            projectDirectoryPath: sourceWorkingDirectoryPath,
            packageFileHelper: PackageFileHelper(packagePath: packagePath, fileHandler: fileHandler),
            xcodeTools: XcodeTools(shell: shell),
            fileHandler: fileHandler,
            scheme: scheme,
            logger: logger
        )
        
        return URL(filePath: sourceWorkingDirectoryPath)
    }
    
    func retrieveRemoteProject(branchOrTag: String, repository: String) throws -> String {
        
        let currentDirectory = fileHandler.currentDirectoryPath
        let targetDirectoryPath = currentDirectory.appending("/\(UUID().uuidString)")
        
        let git = Git(shell: shell, fileHandler: fileHandler, logger: logger)
        try git.clone(repository, at: branchOrTag, targetDirectoryPath: targetDirectoryPath)
        return targetDirectoryPath
    }
    
    static func setupIndividualWorkingDirectory(
        at destinationDirectoryPath: String,
        sourceDirectoryPath: String,
        fileHandler: FileHandling,
        shell: ShellHandling,
        isPackage: Bool,
        logger: Logging?
    ) throws {
        
        try fileHandler.createDirectory(atPath: destinationDirectoryPath)
        
        var fileNameIgnoreList: Set<String> = [".build"]
        var fileExtensionIgnoreList: Set<String> = []
        
        if isPackage {
            fileNameIgnoreList = [
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
            
            fileExtensionIgnoreList = [
                ".yaml",
                ".yml",
                ".png",
                ".docc",
                ".md",
                ".resolved",
                ".podspec",
                // Not copying over xcodeproj/xcworkspace files because otherwise
                // xcodebuild prefers them over the Package.swift file when building
                ".xcodeproj",
                ".xcworkspace"
            ]
        }
        
        try fileHandler.contentsOfDirectory(atPath: sourceDirectoryPath).forEach { fileName in
            if fileExtensionIgnoreList.contains(where: { fileName.hasSuffix($0) }) {
                logger?.debug("Skipping `\(fileName)`", from: String(describing: Self.self))
                return
            }
            if fileNameIgnoreList.contains(where: { fileName == $0 }) {
                logger?.debug("Skipping `\(fileName)`", from: String(describing: Self.self))
                return
            }
            
            let sourceFilePath = sourceDirectoryPath.appending("/\(fileName)")
            let destinationFilePath = destinationDirectoryPath.appending("/\(fileName)")
            
            // Using shell here as it's faster than the FileManager
            shell.execute("cp -a '\(sourceFilePath)' '\(destinationFilePath)'")
        }
    }
    
    static func buildProject(
        projectDirectoryPath: String,
        packageFileHelper: PackageFileHelper,
        xcodeTools: XcodeTools,
        fileHandler: FileHandling,
        scheme: String?,
        logger: Logging?
    ) throws {
        var schemeToBuild: String
        
        if let scheme {
            // If a project scheme was provided we just try to build it
            schemeToBuild = scheme
        } else {
            // Creating an `.library(name: "_allTargets", targets: [ALL_TARGETS])`
            // so we only have to build once and then can generate ABI files for every module from a single build
            schemeToBuild = "_AllTargets"
            try packageFileHelper.preparePackageWithConsolidatedLibrary(named: schemeToBuild)
        }
        
        logger?.log("🛠️ Building project at `\(projectDirectoryPath)`", from: String(describing: Self.self))
        
        try xcodeTools.build(
            projectDirectoryPath: projectDirectoryPath,
            scheme: schemeToBuild,
            isPackage: scheme == nil
        )
    }
}
