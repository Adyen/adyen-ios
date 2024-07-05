//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

enum FileHandlerError: LocalizedError, Equatable {
    /// Could not encode the output string into data
    case couldNotEncodeOutput
    /// Could not persist output at the specified `outputFilePath`
    case couldNotCreateFile(outputFilePath: String)
    /// Could not load file at the specified `filePath`
    case couldNotLoadFile(filePath: String)
    
    var errorDescription: String? {
        switch self {
        case .couldNotEncodeOutput:
            "Could not encode the output string into data"
        case let .couldNotCreateFile(outputFilePath):
            "Could not persist output at `\(outputFilePath)`"
        case let .couldNotLoadFile(filePath):
            "Could not load file from `\(filePath)`"
        }
    }
}

// MARK: - Convenience

extension FileHandling {
    
    /// Creates a directory at the specified path and deletes any old directory if existing
    ///
    /// - Parameters:
    ///   - cleanDirectoryPath: The Path where to create the clean directory
    func createCleanDirectory(
        atPath cleanDirectoryPath: String
    ) throws {
        // Remove existing directory if it exists
        try? removeItem(atPath: cleanDirectoryPath)
        try createDirectory(atPath: cleanDirectoryPath)
    }
    
    /// Persists an output string to a file
    ///
    /// - Parameters:
    ///   - output: The output string to persist
    ///   - outputFilePath: The file path to persist the output to
    func write(_ output: String, to outputFilePath: String) throws {
        
        guard let data = output.data(using: String.Encoding.utf8) else {
            throw FileHandlerError.couldNotEncodeOutput
        }
        
        // Remove existing directory if it exists
        try? removeItem(atPath: outputFilePath)
        if !createFile(atPath: outputFilePath, contents: data) {
            throw FileHandlerError.couldNotCreateFile(outputFilePath: outputFilePath)
        }
    }
    
    /// Get the string contents from a file at a specified path
    ///
    /// - Parameters:
    ///   - filePath: The path to load the string content from
    ///
    /// - Returns: The string content of the file
    func load(from filePath: String) throws -> String {
        guard let data = contents(atPath: filePath) else {
            throw FileHandlerError.couldNotLoadFile(filePath: filePath)
        }

        return String(decoding: data, as: UTF8.self)
    }
}
