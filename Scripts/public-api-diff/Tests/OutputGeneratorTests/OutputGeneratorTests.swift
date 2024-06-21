//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

class OutputGeneratorTests: XCTestCase {
    
    func test_emptyLocalSingleModule() {
        
        let expectedOutput = """
        # ✅ No changes detected
        _Comparing `new_source` to `old_source`_

        ---
        **Analyzed modules:** Target_1
        """
        
        let outputGenerator = OutputGenerator(
            changesPerTarget: [:],
            allTargetNames: ["Target_1"],
            oldSource: .local(path: "old_source"),
            newSource: .local(path: "new_source")
        )
        
        let output = outputGenerator.generate()
        XCTAssertEqual(output, expectedOutput)
    }
    
    func test_oneChangeLocalSingleModule() {
        
        let expectedOutput = """
        # 👀 1 public change detected
        _Comparing `new_source` to `old_source`_

        ---
        ## `Target_1`
        - ❇️  Some Addition

        ---
        **Analyzed modules:** Target_1
        """
        
        let outputGenerator = OutputGenerator(
            changesPerTarget: ["Target_1": [.init(changeType: .addition, parentName: "", changeDescription: "Some Addition")]],
            allTargetNames: ["Target_1"],
            oldSource: .local(path: "old_source"),
            newSource: .local(path: "new_source")
        )
        
        let output = outputGenerator.generate()
        XCTAssertEqual(output, expectedOutput)
    }
    
    func test_multipleChanges_local_multipleModules() {
        
        let expectedOutput = """
        # 👀 7 public changes detected
        _Comparing `new_source` to `old_source`_

        ---
        ## `Target_1`
        - ❇️  Some Addition
        - 🔀 Some Change
        - 😶‍🌫️ Some Removal
        ## `Target_2`
        - ❇️  Another Addition
        - 🔀 Another Change
        - 😶‍🌫️ Another Removal
        ### `Parent_In_Target_2`
        - 🔀 Another Change

        ---
        **Analyzed modules:** Target_1, Target_2
        """

        let outputGenerator = OutputGenerator(
            changesPerTarget: [
                "Target_1": [
                    .init(changeType: .addition, parentName: "", changeDescription: "Some Addition"),
                    .init(changeType: .removal, parentName: "", changeDescription: "Some Removal"),
                    .init(changeType: .change, parentName: "", changeDescription: "Some Change")
                ],
                "Target_2": [
                    .init(changeType: .addition, parentName: "", changeDescription: "Another Addition"),
                    .init(changeType: .removal, parentName: "", changeDescription: "Another Removal"),
                    .init(changeType: .change, parentName: "", changeDescription: "Another Change"),
                    .init(changeType: .change, parentName: "Parent_In_Target_2", changeDescription: "Another Change")
                ]
            ],
            allTargetNames: ["Target_1", "Target_2"],
            oldSource: .local(path: "old_source"),
            newSource: .local(path: "new_source")
        )
        
        let output = outputGenerator.generate()
        XCTAssertEqual(output, expectedOutput)
    }
}
