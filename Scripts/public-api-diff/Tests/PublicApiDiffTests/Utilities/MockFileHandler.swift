//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

struct MockFileHandler: FileHandling {
    
    var currentDirectoryPath: String = ""
    
    var handleRemoveItem: (String) throws -> Void = { _ in
        XCTFail("Unexpectedly called `\(#function)`")
    }
    
    var handleContentsOfDirectory: (String) throws -> [String] = { _ in
        XCTFail("Unexpectedly called `\(#function)`")
        return []
    }
    
    var handleCreateDirectory: (String) throws -> Void = { _ in
        XCTFail("Unexpectedly called `\(#function)`")
    }
    
    var handleCreateFile: (String, Data) -> Bool = { _, _ in
        XCTFail("Unexpectedly called `\(#function)`")
        return false
    }
    
    var handleFileExists: (String) -> Bool = {
        XCTFail("Unexpectedly called `fileExists(atPath: \($0))`")
        return false
    }
    
    var handleLoadData: (String) throws -> Data = {
        XCTFail("Unexpectedly called `contents(atPath: \($0))`")
        return .init()
    }
    
    func removeItem(atPath path: String) throws {
        try handleRemoveItem(path)
    }
    
    func contentsOfDirectory(atPath path: String) throws -> [String] {
        try handleContentsOfDirectory(path)
    }
    
    func createDirectory(atPath path: String) throws {
        try handleCreateDirectory(path)
    }
    
    func createFile(atPath path: String, contents data: Data) -> Bool {
        handleCreateFile(path, data)
    }
    
    func fileExists(atPath path: String) -> Bool {
        handleFileExists(path)
    }
    
    func loadData(from path: String) throws -> Data {
        try handleLoadData(path)
    }
}
