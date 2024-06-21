//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

enum Git {
    
    /// Clones a repository at a specific branch or tag into the current directory
    ///
    /// - Parameters:
    ///   - repository: The repository to clone
    ///   - branchOrTag: The branch or tag to clone
    ///
    /// - Returns: The local directory path where to find the cloned repository
    static func clone(_ repository: String, at branchOrTag: String) -> String {
        
        let currentDirectory = FileManager.default.currentDirectoryPath
        let targetDirectoryPath = currentDirectory.appending("\(UUID().uuidString)")
        try? FileManager.default.removeItem(atPath: targetDirectoryPath)
        
        print("🐱 Cloning \(repository) @ \(branchOrTag) into \(targetDirectoryPath)")
        Shell.execute("git clone -b \(branchOrTag) \(repository) \(targetDirectoryPath)")
        
        return targetDirectoryPath
    }
}
