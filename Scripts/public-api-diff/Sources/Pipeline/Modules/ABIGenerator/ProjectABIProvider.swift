//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import OSLog

struct ProjectABIProvider: ABIGenerating {
    
    let shell: ShellHandling
    let fileHandler: FileHandling
    let logger: Logging?
    
    func generate(
        for projectDirectory: URL,
        scheme: String?,
        description: String
    ) throws -> [ABIGeneratorOutput] {
        
        guard let scheme else {
            assertionFailure("ProjectABIProvider needs a scheme to be passed to \(#function)")
            return []
        }
        
        logger?.log("📋 Locating ABI file for `\(description)`", from: String(describing: Self.self))
        
        let swiftModulePaths = shell.execute("cd '\(projectDirectory)'; find . -type d -name '\(scheme).swiftmodule'")
            .components(separatedBy: .newlines)
            .map { URL(filePath: $0) }

        guard let swiftModuleDirectory = swiftModulePaths.first else {
            throw FileHandlerError.pathDoesNotExist(path: "find . -type d -name '\(scheme).swiftmodule'")
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
