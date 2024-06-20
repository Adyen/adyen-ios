//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 20/06/2024.
//

import XCTest
@testable import public_api_diff

class public_api_diffTests: XCTestCase {
    
    func test_emptyLocalSingleModule() {
        let expectedOutput = """
# ✅ No changes detected
_Comparing `new_source` to `old_source`_

---
**Analyzed modules:** SomeModule
"""
        
        let emptyOutput = OutputGenerator.generate(
            from: [:],
            allTargetNames: ["SomeModule"],
            oldSource: .local(path: "old_source"),
            newSource: .local(path: "new_source")
        )
        
        XCTAssertEqual(emptyOutput, expectedOutput)
    }
}
