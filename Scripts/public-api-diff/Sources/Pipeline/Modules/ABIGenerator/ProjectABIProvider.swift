//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 16/07/2024.
//

import Foundation
import OSLog

struct ProjectABIProvider: ABIGenerating {
    
    let fileHandler: FileHandling
    let logger: Logging?
    
    func generate(for projectDirectory: URL, scheme: String?) throws -> [ABIGeneratorOutput] {
    
        guard let scheme else {
            assertionFailure("ProjectABIProvider needs a scheme to be passed to \(#function)")
            return []
        }
        
        logger?.log("📋 Locating ABI file for `\(projectDirectory.lastPathComponent)`", from: String(describing: Self.self))
        
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
        
        logger?.debug("- `\(abiJsonFilePath)`", from: String(describing: Self.self))
        let abiJsonFileUrl = swiftModuleDirectory.appending(path: abiJsonFilePath)
        return [.init(targetName: scheme, abiJsonFileUrl: abiJsonFileUrl)]
    }
}
