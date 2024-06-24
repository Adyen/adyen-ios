//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

enum ProjectSourceError: LocalizedError, Equatable {
    case invalidSourceValue(value: String)
    
    var errorDescription: String? {
        switch self {
        case let .invalidSourceValue(value):
            "Invalid source parameter `\(value)`. It needs to either be a local file path or a repository in the format `[BRANCH_OR_TAG]\(ProjectSource.gitSourceSeparator)[REPOSITORY_URL]"
        }
    }
}

enum ProjectSource: Equatable {
    
    /// The separator used to join branch & repository
    static var gitSourceSeparator: String { "~" }
    
    case local(path: String)
    case remote(branch: String, repository: String)
 
    static func from(_ rawValue: String, fileHandler: FileHandling) throws -> ProjectSource {
        if fileHandler.fileExists(atPath: rawValue) {
            return .local(path: rawValue)
        }
        
        let remoteComponents = rawValue.components(separatedBy: gitSourceSeparator)
        if remoteComponents.count == 2, let branch = remoteComponents.first, let repository = remoteComponents.last, URL(string: repository) != nil {
            return .remote(branch: branch, repository: repository)
        }
        
        throw ProjectSourceError.invalidSourceValue(value: rawValue)
    }
    
    var description: String {
        switch self {
        case let .local(path):
            return path
        case let .remote(branch, repository):
            return "\(repository) @ \(branch)"
        }
    }
}
