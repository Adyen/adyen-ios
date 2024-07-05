//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

protocol FileHandling {
    
    var currentDirectoryPath: String { get }
    
    func loadData(from path: String) throws -> Data
    
    func removeItem(atPath path: String) throws
    
    func contentsOfDirectory(atPath path: String) throws -> [String]
    
    func createDirectory(atPath path: String) throws
    
    func createFile(atPath path: String, contents data: Data) -> Bool
    
    func fileExists(atPath path: String) -> Bool
}
