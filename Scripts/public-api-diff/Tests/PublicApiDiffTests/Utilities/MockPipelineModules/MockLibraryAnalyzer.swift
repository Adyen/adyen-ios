//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 12/07/2024.
//

@testable import public_api_diff
import XCTest

struct MockLibraryAnalyzer: LibraryAnalyzing {
    
    var onAnalyze: (URL, URL) throws -> [Change]
    
    func analyze(oldProjectUrl: URL, newProjectUrl: URL) throws -> [Change] {
        try onAnalyze(oldProjectUrl, newProjectUrl)
    }
}
