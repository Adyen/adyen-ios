//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 12/07/2024.
//

@testable import public_api_diff
import XCTest

struct MockProjectBuilder: ProjectBuilding {
    
    var onBuild: (ProjectSource) throws -> URL
    
    func build(source: ProjectSource) throws -> URL {
        try onBuild(source)
    }
}
