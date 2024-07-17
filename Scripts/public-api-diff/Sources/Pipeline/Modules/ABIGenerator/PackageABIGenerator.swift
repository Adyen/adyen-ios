//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 16/07/2024.
//

import Foundation

struct PackageABIGenerator: ABIGenerating {
    
    let fileHandler: FileHandling
    let xcodeTools: XcodeTools
    let logger: Logging?
    
    func generate(
        for projectDirectory: URL,
        scheme: String?
    ) throws -> [ABIGeneratorOutput] {
        
        logger?.log("📋 Generating ABI files for `\(projectDirectory.lastPathComponent)`", from: String(describing: Self.self))
        
        let packageFileHelper = PackageFileHelper(
            packagePath: PackageFileHelper.packagePath(for: projectDirectory.path()),
            fileHandler: fileHandler
        )
        
        return try packageFileHelper.availableTargets().map { target in
            
            let abiJsonFileUrl = try generateApiDump(
                for: target,
                projectDirectory: projectDirectory
            )
            
            return .init(
                targetName: target,
                abiJsonFileUrl: abiJsonFileUrl
            )
        }
    }
}

private extension PackageABIGenerator {
    
    func generateApiDump(
        for module: String,
        projectDirectory: URL
    ) throws -> URL {
        
        let abiJsonFileUrl = projectDirectory.appending(component: "\(module).abi.json")
        logger?.debug("- `\(module).abi.json`", from: String(describing: Self.self))
        
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
