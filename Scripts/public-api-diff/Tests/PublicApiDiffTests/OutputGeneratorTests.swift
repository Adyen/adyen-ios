//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

class OutputGeneratorTests: XCTestCase {
    
    func test_noChanges_singleModule() {
        
        let expectedOutput = """
        # ✅ No changes detected
        _Comparing `new_source` to `old_source`_

        ---
        **Analyzed targets:** Target_1
        """
        
        let outputGenerator = MarkdownOutputGenerator()
        let output = outputGenerator.generate(
            from: [:],
            allTargets: ["Target_1"],
            oldSource: .local(path: "old_source"),
            newSource: .local(path: "new_source")
        )
        XCTAssertEqual(output, expectedOutput)
    }
    
    func test_oneChange_singleModule() {
        
        let expectedOutput = """
        # 👀 1 public change detected
        _Comparing `new_source` to `old_source`_

        ---
        ## `Target_1`
        - ❇️  Some Addition

        ---
        **Analyzed targets:** Target_1
        """
        
        let outputGenerator = MarkdownOutputGenerator()
        
        let output = outputGenerator.generate(
            from: ["Target_1": [.init(changeType: .addition, parentName: "", changeDescription: "Some Addition")]],
            allTargets: ["Target_1"],
            oldSource: .local(path: "old_source"),
            newSource: .local(path: "new_source")
        )
        XCTAssertEqual(output, expectedOutput)
    }
    
    func test_multipleChanges_multipleModules() {
        
        let expectedOutput = """
        # 👀 4 public changes detected
        _Comparing `new_source` to `old_repository @ old_branch`_

        ---
        ## `Target_1`
        - ❇️  Some Addition
        - 😶‍🌫️ Some Removal
        ## `Target_2`
        - ❇️  Another Addition
        - 😶‍🌫️ Another Removal

        ---
        **Analyzed targets:** Target_1, Target_2
        """

        let outputGenerator = MarkdownOutputGenerator()
        
        let output = outputGenerator.generate(
            from: [
                "Target_1": [
                    .init(changeType: .addition, parentName: "", changeDescription: "Some Addition"),
                    .init(changeType: .removal, parentName: "", changeDescription: "Some Removal")
                ],
                "Target_2": [
                    .init(changeType: .addition, parentName: "", changeDescription: "Another Addition"),
                    .init(changeType: .removal, parentName: "", changeDescription: "Another Removal")
                ]
            ],
            allTargets: ["Target_1", "Target_2"],
            oldSource: .remote(branch: "old_branch", repository: "old_repository"),
            newSource: .local(path: "new_source")
        )
        XCTAssertEqual(output, expectedOutput)
    }
}
