//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct Git {
    
    private let shell: ShellHandling
    
    init(shell: ShellHandling) {
        self.shell = shell
    }
    
    /// Clones a repository at a specific branch or tag into the current directory
    ///
    /// - Parameters:
    ///   - repository: The repository to clone
    ///   - branchOrTag: The branch or tag to clone
    ///   - targetDirectoryPath: The directory to clone into
    ///
    /// - Returns: The local directory path where to find the cloned repository
    func clone(_ repository: String, at branchOrTag: String, targetDirectoryPath: String) {
        print("🐱 Cloning \(repository) @ \(branchOrTag) into \(targetDirectoryPath)")
        let command = "git clone -b \(branchOrTag) \(repository) \(targetDirectoryPath)"
        shell.execute(command)
    }
}
