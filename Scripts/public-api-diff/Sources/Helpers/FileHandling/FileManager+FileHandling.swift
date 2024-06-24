//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 21/06/2024.
//

import Foundation

extension FileManager: FileHandling {
    
    /// Creates a directory at the specified path
    func createDirectory(atPath path: String) throws {
        try createDirectory(atPath: path, withIntermediateDirectories: true)
    }
    
    /// Creates a file at the specified path with the provided content
    func createFile(atPath path: String, contents data: Data) -> Bool {
        createFile(atPath: path, contents: data, attributes: nil)
    }
}
