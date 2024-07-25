//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 17/07/2024.
//

@testable import public_api_diff
import XCTest

struct MockRandomStringGenerator: RandomStringGenerating {
    
    var onGenerateRandomString: () -> String = {
        XCTFail("Unexpectedly called `\(#function)`")
        return ""
    }
    
    func generateRandomString() -> String {
        onGenerateRandomString()
    }
}
