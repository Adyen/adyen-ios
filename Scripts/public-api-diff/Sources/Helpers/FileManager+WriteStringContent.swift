//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 20/06/2024.
//

import Foundation

extension FileManager {
    
    func write(_ output: String, to outputFilePath: String) throws {
        
        guard let data = output.data(using: String.Encoding.utf8) else { return }
        
        let outputFileUrl = URL(filePath: outputFilePath)
        
        if FileManager.default.fileExists(atPath: outputFilePath) {
            try FileManager.default.removeItem(atPath: outputFilePath)
        }
        
        try data.write(to: outputFileUrl, options: .atomicWrite)
    }
}
