//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 18/06/2024.
//

import Foundation

struct SDKDumper {
    
    let projectDirectoryPath: String
    
    init(projectDirectoryPath: String) {
        self.projectDirectoryPath = projectDirectoryPath
    }
    
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


