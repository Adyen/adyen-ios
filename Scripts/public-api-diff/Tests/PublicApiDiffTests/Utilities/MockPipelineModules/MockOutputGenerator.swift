//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 12/07/2024.
//

@testable import public_api_diff
import XCTest

struct MockOutputGenerator: OutputGenerating {
    
    var onGenerate: ([String : [Change]], [String], ProjectSource, ProjectSource) throws -> String
    
    func generate(from changesPerTarget: [String : [Change]], allTargets: [String], oldSource: ProjectSource, newSource: ProjectSource) throws -> String {
        try onGenerate(changesPerTarget, allTargets, oldSource, newSource)
    }
}
