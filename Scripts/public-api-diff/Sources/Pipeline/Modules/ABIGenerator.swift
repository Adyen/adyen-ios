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
    
    func generate(for projectDirectory: URL) throws -> [ABIGeneratorOutput] {
        
        print("📋 Generating ABI files for `\(projectDirectory.lastPathComponent)`")
        
        var output = [ABIGeneratorOutput]()
        
        if fileHandler.fileExists(atPath: PackageFileHelper.packagePath(for: projectDirectory.path())) {
            
            // Try to find the Package.swift file - if it exists, alter it and generate dumps for all modules
            let packageFileHelper = PackageFileHelper(
                packagePath: PackageFileHelper.packagePath(for: projectDirectory.path()),
                fileHandler: fileHandler
            )
            
            try packageFileHelper.availableTargets().forEach { target in
                let abiJsonFileUrl = try generateApiDump(for: target, projectDirectory: projectDirectory)
                output.append(.init(targetName: target, abiJsonFileUrl: abiJsonFileUrl))
            }
        } else {
            // TODO: Implement
            
            // Go into the build folder and try to find the abi.json
            
            // TODO: Allow passing of an xcodproj/xcworkspace
            // Once that's built the abi.json can be found here:
            // .build/Build/Products/Debug-maccatalyst/Adyen3DS2_Swift.framework/
            //      Versions/A/Modules/[NAME_OF_MODULE].swiftmodule/arm64-apple-ios-macabi.abi.json
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
