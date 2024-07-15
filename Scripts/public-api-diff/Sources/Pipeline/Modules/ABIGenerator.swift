//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 12/07/2024.
//

import Foundation

struct ABIGenerator: ABIGenerating {
    
    let xcodeTools: XcodeTools
    let fileHandler: any FileHandling
    
    init(
        xcodeTools: XcodeTools = XcodeTools(),
        fileHandler: any FileHandling = FileManager.default
    ) {
        self.xcodeTools = xcodeTools
        self.fileHandler = fileHandler
    }
    
    func generate(for projectDirectory: URL, scheme: String?) throws -> [ABIGeneratorOutput] {
        
        print("📋 Generating ABI files for `\(projectDirectory.lastPathComponent)`")
        
        var output = [ABIGeneratorOutput]()
        
        if let scheme {
            // TODO: Check with other projects - this seems very specific:
            let targetSpecificDirectories = [
                "Debug-maccatalyst",
                "Debug-iphonesimulator"
            ]
            
            let potentialModulePaths = targetSpecificDirectories.map { target in
                projectDirectory.appending(path: ".build/Build/Products/\(target)/\(scheme).framework/Modules/\(scheme).swiftmodule")
            }
            
            let swiftModuleDirectory = potentialModulePaths.first { fileHandler.fileExists(atPath: $0.path()) }

            guard let swiftModuleDirectory else {
                throw FileHandlerError.pathDoesNotExist(path: potentialModulePaths.first!.path())
            }
            
            let swiftModuleDirectoryContent = try fileHandler.contentsOfDirectory(atPath: swiftModuleDirectory.path())
            guard let abiJsonFilePath = swiftModuleDirectoryContent.first(where: {
                $0.hasSuffix("abi.json")
            }) else {
                throw FileHandlerError.pathDoesNotExist(path: swiftModuleDirectory.appending(path: ".abi.json").path())
            }
            
            let abiJsonFileUrl = swiftModuleDirectory.appending(path: abiJsonFilePath)
            return [.init(targetName: scheme, abiJsonFileUrl: abiJsonFileUrl)]
            
        } else {
            
            // Try to find the Package.swift file - if it exists, alter it and generate dumps for all modules
            let packageFileHelper = PackageFileHelper(
                packagePath: PackageFileHelper.packagePath(for: projectDirectory.path()),
                fileHandler: fileHandler
            )
            
            try packageFileHelper.availableTargets().forEach { target in
                let abiJsonFileUrl = try generateApiDump(for: target, projectDirectory: projectDirectory)
                output.append(.init(targetName: target, abiJsonFileUrl: abiJsonFileUrl))
            }
        }
        
        return output
    }
}

private extension ABIGenerator {
    
    func generateApiDump(for module: String, projectDirectory: URL) throws -> URL {
        
        let abiJsonFileUrl = projectDirectory.appending(component: "\(module).abi.json")
        print("- `\(module).abi.json`")
        
        xcodeTools.dumpSdk(
            projectDirectoryPath: projectDirectory.path(),
            module: module,
            outputFilePath: abiJsonFileUrl.path()
        )
        
        if !fileHandler.fileExists(atPath: abiJsonFileUrl.path()) {
            throw FileHandlerError.pathDoesNotExist(path: abiJsonFileUrl.path())
        }
        
        return abiJsonFileUrl
    }
}
