//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 12/07/2024.
//

@testable import public_api_diff
import XCTest

struct MockABIGenerator: ABIGenerating {
    
    var onGenerate: (URL) throws -> [ABIGeneratorOutput]
    
    func generate(for projectDirectory: URL) throws -> [ABIGeneratorOutput] {
        try onGenerate(projectDirectory)
    }
}
