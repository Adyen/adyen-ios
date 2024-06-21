//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 21/06/2024.
//

import Foundation

enum FileHandlingError: LocalizedError {
    /// Could not encode the output string into data
    case cannotEncodeOutput
    /// Could not persist output at the specified `outputFilePath`
    case cannotCreateFile(outputFilePath: String)
    
    var errorDescription: String? {
        switch self {
        case .cannotEncodeOutput:
            "Could not encode the output string into data"
        case .cannotCreateFile(let outputFilePath):
            "Could not persist output at the specified `\(outputFilePath)`"
        }
    }
}

protocol FileHandling {
    
    var currentDirectoryPath: String { get }
    
    func load(from filePath: String) throws -> String
    func write(_ output: String, to outputFilePath: String) throws
    func removeItem(atPath path: String) throws
    func contentsOfDirectory(atPath path: String) throws -> [String]
    func createDirectory(atPath path: String) throws
    func fileExists(atPath path: String) -> Bool
}

extension FileHandling {
    
    func createCleanDirectory(
        atPath cleanDirectoryPath: String
    ) throws {
        // Remove existing directory if it exists
        try? removeItem(atPath: cleanDirectoryPath)
        try createDirectory(atPath: cleanDirectoryPath)
    }
}

// MARK: - Implementation

struct FileHandler: FileHandling {
    
    private let fileManager = FileManager.default
    
    func load(from filePath: String) throws -> String {
        try String(contentsOfFile: filePath)
    }
    
    /// Persists an output string to a file
    ///
    /// - Parameters:
    ///   - output: The output string to persist
    ///   - outputFilePath: The file path to persist the output to
    func write(_ output: String, to outputFilePath: String) throws {
        
        guard let data = output.data(using: String.Encoding.utf8) else {
            throw FileHandlingError.cannotEncodeOutput
        }
        
        // Remove existing file if it exists (Fail gracefully)
        try? fileManager.removeItem(atPath: outputFilePath)
        
        if !fileManager.createFile(atPath: outputFilePath, contents: data) {
            throw FileHandlingError.cannotCreateFile(outputFilePath: outputFilePath)
        }
    }
    
    func removeItem(atPath path: String) throws {
        try fileManager.removeItem(atPath: path)
    }
    
    func contentsOfDirectory(atPath path: String) throws -> [String] {
        try fileManager.contentsOfDirectory(atPath: path)
    }
    
    func createDirectory(atPath path: String) throws {
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
    }
    
    func fileExists(atPath path: String) -> Bool {
        fileManager.fileExists(atPath: path)
    }
    
    var currentDirectoryPath: String {
        fileManager.currentDirectoryPath
    }
}
