//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct SDKDumpGenerator {
    
    /// The path to the project directory that contains the Package.swift
    let projectDirectoryPath: String
    
    init(projectDirectoryPath: String) {
        self.projectDirectoryPath = projectDirectoryPath
    }
    
    /// Generates an sdk dump for a specific module
    func generate(for module: String) -> String {
        
        let sdkDumpInputPath = projectDirectoryPath
            .appending("/\(Constants.derivedDataPath)")
            .appending("/Build/Products/Debug-iphonesimulator")
        
        let outputFilePath = projectDirectoryPath
            .appending("/api_dump.json")
        
        let dumpCommand = "cd \(projectDirectoryPath); xcrun swift-api-digester -dump-sdk -module \(module) -I \(sdkDumpInputPath) -o \(outputFilePath) -sdk `\(Constants.simulatorSdkCommand)` -target \(Constants.deviceTarget) -abort-on-module-fail"
        
        Shell.execute(dumpCommand)
        
        return outputFilePath
    }
}
