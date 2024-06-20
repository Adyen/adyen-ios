//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 20/06/2024.
//

import Foundation

enum Git {
    
    /// Returns the Package.swift file path if available
    static func clone(_ repository: String, at branchOrTag: String) -> String {
        
        let currentDirectory = FileManager.default.currentDirectoryPath
        let targetDirectoryPath = currentDirectory.appending("\(UUID().uuidString)")
        try? FileManager.default.removeItem(atPath: targetDirectoryPath)
        
        print("🐱 Cloning \(repository) @ \(branchOrTag) into \(targetDirectoryPath)")
        Shell.execute("git clone -b \(branchOrTag) \(repository) \(targetDirectoryPath)")
        
        return targetDirectoryPath
    }
}
