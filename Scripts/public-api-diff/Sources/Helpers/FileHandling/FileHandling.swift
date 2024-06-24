//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

protocol FileHandling {
    
    var currentDirectoryPath: String { get }
    
    func load(from filePath: String) throws -> String
    
    func removeItem(atPath path: String) throws
    
    func contentsOfDirectory(atPath path: String) throws -> [String]
    
    func createDirectory(atPath path: String) throws
    
    func createFile(atPath path: String, contents data: Data) -> Bool
    
    func fileExists(atPath path: String) -> Bool
    
    func contents(atPath path: String) -> Data?
}
