//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct SDKDumpGenerator {
    
    /// The path to the project directory that contains the Package.swift
    let projectDirectoryPath: String
    let fileHandler: FileHandling
    let xcodeTools: XcodeTools
    
    init(
        projectDirectoryPath: String,
        fileHandler: FileHandling,
        xcodeTools: XcodeTools
    ) {
        self.projectDirectoryPath = projectDirectoryPath
        self.fileHandler = fileHandler
        self.xcodeTools = xcodeTools
    }
    
    /// Generates an sdk dump for a specific module
    ///
    /// - Parameters:
    ///   - module: The module name to generate the dump for
    ///
    /// - Returns: An optional `SDKDump` (Can be nil if no dump for a specific module can be created e.g. the module does not exist in one version)
    func generate(for module: String) throws -> SDKDump {
        
        let outputFilePath = projectDirectoryPath.appending("/api_dump_\(module).json")
        
        xcodeTools.dumpSdk(
            projectDirectoryPath: projectDirectoryPath,
            module: module,
            outputFilePath: outputFilePath
        )
        
        if !fileHandler.fileExists(atPath: outputFilePath) {
            throw FileHandlerError.pathDoesNotExist(path: outputFilePath)
        }
        
        return try generate(from: outputFilePath)
    }
    
    /// Generates an sdk dump object from a file
    ///
    /// - Parameters:
    ///   - sdkDumpFilePath: The file path pointing to the sdk dump json
    ///
    /// - Returns: An optional `SDKDump` (Can be nil if no dump can be found at the specific file path)
    func generate(from sdkDumpFilePath: String) throws -> SDKDump {

        let data = try fileHandler.loadData(from: sdkDumpFilePath)
        
        return try JSONDecoder().decode(
            SDKDump.self,
            from: data
        )
    }
}
