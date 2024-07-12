//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct SDKDumpGenerator: SDKDumpGenerating {
    
    /// The path to the project directory that contains the Package.swift
    let fileHandler: FileHandling
    let xcodeTools: XcodeTools
    
    init(
        fileHandler: FileHandling = FileManager.default,
        xcodeTools: XcodeTools = XcodeTools()
    ) {
        self.fileHandler = fileHandler
        self.xcodeTools = xcodeTools
    }
    
    /// Generates an sdk dump object from a file
    ///
    /// - Parameters:
    ///   - abiJsonFileUrl: The file path pointing to the sdk dump json
    ///
    /// - Returns: An optional `SDKDump` (Can be nil if no dump can be found at the specific file path)
    func generate(for abiJsonFileUrl: URL) throws -> SDKDump {

        let data = try fileHandler.loadData(from: abiJsonFileUrl.path())
        
        return try JSONDecoder().decode(
            SDKDump.self,
            from: data
        )
    }
}
