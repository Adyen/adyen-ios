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
    /// - Returns: An optional `SDKDump` (Can be nil if no dump for a specific module can be created e.g. the module does not exist in one version)
    func generate(for module: String) -> SDKDump? {
        
        let outputFilePath = projectDirectoryPath.appending("/api_dump.json")
        
        xcodeTools.dumpSdk(
            projectDirectoryPath: projectDirectoryPath,
            module: module,
            outputFilePath: outputFilePath
        )
        
        return load(from: outputFilePath)
    }
}

private extension SDKDumpGenerator {
    
    func load(from sdkDumpFilePath: String) -> SDKDump? {
        
        guard let data = fileHandler.contents(atPath: sdkDumpFilePath) else {
            return nil
        }
        
        return try? JSONDecoder().decode(
            SDKDump.self,
            from: data
        )
    }
}
