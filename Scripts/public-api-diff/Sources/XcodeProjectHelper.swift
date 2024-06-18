//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

// TODO: Remove this file and rather move all operations to a tmp-diff-dir

struct XcodeProjectHelper {
    
    let projectDirectoryPath: String
    
    private func backupFilePath(for path: String) -> String {
        path.appending("_backup")
    }
    
    private func originalFilePath(forBackup backupPath: String) -> String {
        backupPath.replacingOccurrences(of: "_backup", with: "")
    }
    
    init(projectDirectoryPath: String) {
        self.projectDirectoryPath = projectDirectoryPath
    }
    
    /// Obscurs xcodeproj/xcworkspace files to make sure the Package.swift is used for building
    func prepare() throws {
        try FileManager.default.contentsOfDirectory(atPath: projectDirectoryPath).forEach {
            if $0.hasSuffix(".xcodeproj") || $0.hasSuffix(".xcworkspace") {
                let filePath = projectDirectoryPath.appending("/\($0)")
                try FileManager.default.moveItem(atPath: filePath, toPath: backupFilePath(for: filePath))
            }
        }
    }
    
    /// Reverts all changes done to the xcode projects/workspaces
    func revert() throws {
        try FileManager.default.contentsOfDirectory(atPath: projectDirectoryPath).forEach {
            if $0.hasSuffix("_backup") {
                let filePath = projectDirectoryPath.appending("/\($0)")
                try FileManager.default.moveItem(atPath: filePath, toPath: originalFilePath(forBackup: filePath))
            }
        }
    }
}
