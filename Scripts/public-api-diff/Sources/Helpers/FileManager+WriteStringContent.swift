//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension FileManager {
    
    enum WriteError: Error {
        /// Could not encode the output string into data
        case cannotEncodeOutput
    }
    
    /// Persists an output string to a file
    ///
    /// - Parameters:
    ///   - output: The output string to persist
    ///   - outputFilePath: The file path to persist the output to
    func write(_ output: String, to outputFilePath: String) throws {
        
        guard let data = output.data(using: String.Encoding.utf8) else {
            throw WriteError.cannotEncodeOutput
        }
        
        let outputFileUrl = URL(filePath: outputFilePath)
        
        if FileManager.default.fileExists(atPath: outputFilePath) {
            try FileManager.default.removeItem(atPath: outputFilePath)
        }
        
        try data.write(to: outputFileUrl, options: .atomicWrite)
    }
}
