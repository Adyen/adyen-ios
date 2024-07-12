//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 12/07/2024.
//

@testable import public_api_diff
import XCTest

struct MockABIGenerator: ABIGenerating {
    
    var onGenerate: (URL, String?) throws -> [ABIGeneratorOutput]
    
    func generate(for projectDirectory: URL, scheme: String?) throws -> [ABIGeneratorOutput] {
        try onGenerate(projectDirectory, scheme)
    }
}
