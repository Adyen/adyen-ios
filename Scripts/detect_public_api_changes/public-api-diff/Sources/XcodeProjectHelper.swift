//
//  XcodeProjectHelper.swift
//  
//
//  Created by Alexander Guretzki on 17/06/2024.
//

import Foundation

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
