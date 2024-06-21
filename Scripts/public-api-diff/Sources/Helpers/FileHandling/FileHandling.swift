//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 21/06/2024.
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
