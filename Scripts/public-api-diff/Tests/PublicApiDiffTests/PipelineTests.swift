//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

class PipelineTests: XCTestCase {
    
    func test_pipeline() async throws {
        
        let projectBuilderExpectation = expectation(description: "ProjectBuilder is called twice")
        projectBuilderExpectation.expectedFulfillmentCount = 2
        
        let abiGeneratorExpectation = expectation(description: "ABIGenerator is called twice")
        abiGeneratorExpectation.expectedFulfillmentCount = 2
        
        let libraryAnalyzerExpectation = expectation(description: "LibraryAnalyzer is called once")
        
        let dumpGeneratorExpectation = expectation(description: "SDKDumpGenerator is called twice")
        dumpGeneratorExpectation.expectedFulfillmentCount = 2
        
        let dumpAnalyzerExpectation = expectation(description: "SDKDumpAnalyzer is called once")
        
        let oldProjectSource = ProjectSource.local(path: "old")
        let newProjectSource = ProjectSource.local(path: "new")
        
        var expectedSteps: [Any] = [
            URL(filePath: oldProjectSource.description),
            "old",
            
            URL(filePath: newProjectSource.description),
            "new",
            
            URL(filePath: oldProjectSource.description),
            URL(filePath: newProjectSource.description),
            
            URL(filePath: oldProjectSource.description),
            URL(filePath: newProjectSource.description),
            
            SDKDump(root: .init(kind: .var, name: "Name", printedName: URL(filePath: oldProjectSource.description).absoluteString)),
            SDKDump(root: .init(kind: .var, name: "Name", printedName: URL(filePath: newProjectSource.description).absoluteString)),
            
            [
                "": [Change(changeType: .addition(description: "A Library was added"), parentName: "Parent")],
                "Target": [Change(changeType: .addition(description: "Something was added"), parentName: "Parent")]
            ],
            ["Target"],
            oldProjectSource,
            newProjectSource,
            
            "Output"
        ]
        
        let pipeline = Pipeline(
            newProjectSource: newProjectSource,
            oldProjectSource: oldProjectSource,
            scheme: nil,
            projectBuilder: MockProjectBuilder(onBuild: { source, scheme in
                projectBuilderExpectation.fulfill()
                
                XCTAssertNil(scheme)
                
                return URL(filePath: source.description)
            }),
            abiGenerator: MockABIGenerator(onGenerate: { url, scheme, description in
                XCTAssertEqual(url, expectedSteps.first as? URL)
                expectedSteps.removeFirst()
                XCTAssertNil(scheme)
                
                XCTAssertEqual(description, expectedSteps.first as? String)
                expectedSteps.removeFirst()
                
                abiGeneratorExpectation.fulfill()
                
                return [.init(targetName: "Target", abiJsonFileUrl: url)]
            }),
            libraryAnalyzer: MockLibraryAnalyzer(onAnalyze: { old, new in
                XCTAssertEqual(old, expectedSteps.first as? URL)
                expectedSteps.removeFirst()
                XCTAssertEqual(new, expectedSteps.first as? URL)
                expectedSteps.removeFirst()
                libraryAnalyzerExpectation.fulfill()
                
                return [.init(changeType: .addition(description: "A Library was added"), parentName: "Parent")]
            }),
            sdkDumpGenerator: MockSDKDumpGenerator(onGenerate: { url in
                XCTAssertEqual(url, expectedSteps.first as? URL)
                expectedSteps.removeFirst()
                dumpGeneratorExpectation.fulfill()
                
                return .init(root: .init(kind: .var, name: "Name", printedName: url.absoluteString))
            }),
            sdkDumpAnalyzer: MockSDKDumpAnalyzer(onAnalyze: { old, new in
                XCTAssertEqual(old, expectedSteps.first as? SDKDump)
                expectedSteps.removeFirst()
                XCTAssertEqual(new, expectedSteps.first as? SDKDump)
                expectedSteps.removeFirst()
                dumpAnalyzerExpectation.fulfill()
                
                return [.init(changeType: .addition(description: "Something was added"), parentName: "Parent")]
            }),
            outputGenerator: MockOutputGenerator(onGenerate: { changes, allTargets, old, new in
                XCTAssertEqual(changes, expectedSteps.first as? [String: [Change]])
                expectedSteps.removeFirst()
                XCTAssertEqual(allTargets, expectedSteps.first as? [String])
                expectedSteps.removeFirst()
                XCTAssertEqual(old, expectedSteps.first as? ProjectSource)
                expectedSteps.removeFirst()
                XCTAssertEqual(new, expectedSteps.first as? ProjectSource)
                expectedSteps.removeFirst()
                
                return "Output"
            }),
            logger: MockLogger(logLevel: .debug)
        )
        
        let pipelineOutput = try await pipeline.run()
        
        await fulfillment(of: [
            projectBuilderExpectation,
            abiGeneratorExpectation,
            libraryAnalyzerExpectation,
            dumpGeneratorExpectation,
            dumpAnalyzerExpectation
        ])
        
        XCTAssertEqual(pipelineOutput, expectedSteps.first as? String)
        expectedSteps.removeFirst()
        
        XCTAssertEqual(expectedSteps.count, 0)
    }
}
