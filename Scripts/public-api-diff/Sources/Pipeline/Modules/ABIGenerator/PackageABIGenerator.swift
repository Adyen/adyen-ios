//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct PackageABIGenerator: ABIGenerating {
    
    let fileHandler: FileHandling
    let xcodeTools: XcodeTools
    let packageFileHelper: PackageFileHelper
    let logger: Logging?
    
    func generate(
        for projectDirectory: URL,
        scheme: String?,
        description: String
    ) throws -> [ABIGeneratorOutput] {
        
        logger?.log("📋 Generating ABI files for `\(description)`", from: String(describing: Self.self))
        
        return try packageFileHelper.availableTargets(
            at: projectDirectory.path(),
            moduleType: .swiftTarget,
            targetType: .library
        ).map { target in
            
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
