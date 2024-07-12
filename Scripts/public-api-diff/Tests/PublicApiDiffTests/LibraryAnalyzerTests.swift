//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 12/07/2024.
//

@testable import public_api_diff
import XCTest

class LibraryAnalyzerTests: XCTestCase {
    
    func test_noPackageLibraryDifferences_causeNoChanges() throws {
        
        let handleFileExpectation = expectation(description: "handleFileExists is called twice")
        handleFileExpectation.expectedFulfillmentCount = 2
        let handleLoadDataExpectation = expectation(description: "handleFileExists is called twice")
        handleLoadDataExpectation.expectedFulfillmentCount = 2
        
        var fileHandler = MockFileHandler()
        fileHandler.handleFileExists = { _ in
            handleFileExpectation.fulfill()
            return true
        }
        fileHandler.handleLoadData = { path in
            handleLoadDataExpectation.fulfill()
            let packageName = path.components(separatedBy: "/").first
            let resourcePath = try XCTUnwrap(Bundle.module.path(forResource: packageName, ofType: "txt"))
            return try XCTUnwrap(FileManager.default.contents(atPath: resourcePath))
        }
        let libraryAnalyzer = LibraryAnalyzer(fileHandler: fileHandler)
        
        let changes = try libraryAnalyzer.analyze(
            oldProjectUrl: URL(filePath: "NewPackage"),
            newProjectUrl: URL(filePath: "NewPackage")
        )
        
        let expectedChanges: [Change] = []
        XCTAssertEqual(changes, expectedChanges)
        
        waitForExpectations(timeout: 1)
    }
    
    func test_packageLibraryDifferences_causeChanges() throws {
        
        let handleFileExpectation = expectation(description: "handleFileExists is called twice")
        handleFileExpectation.expectedFulfillmentCount = 2
        let handleLoadDataExpectation = expectation(description: "handleFileExists is called twice")
        handleLoadDataExpectation.expectedFulfillmentCount = 2
        
        var fileHandler = MockFileHandler()
        fileHandler.handleFileExists = { _ in
            handleFileExpectation.fulfill()
            return true
        }
        fileHandler.handleLoadData = { path in
            handleLoadDataExpectation.fulfill()
            let packageName = path.components(separatedBy: "/").first
            let resourcePath = try XCTUnwrap(Bundle.module.path(forResource: packageName, ofType: "txt"))
            return try XCTUnwrap(FileManager.default.contents(atPath: resourcePath))
        }
        let libraryAnalyzer = LibraryAnalyzer(fileHandler: fileHandler)
        
        let changes = try libraryAnalyzer.analyze(
            oldProjectUrl: URL(filePath: "OldPackage"),
            newProjectUrl: URL(filePath: "NewPackage")
        )
        
        let expectedChanges: [Change] = [
            .init(changeType: .removal, parentName: "", changeDescription: "`.library(name: \"OldLibrary\", ...)` was removed"),
            .init(changeType: .addition, parentName: "", changeDescription: "`.library(name: \"NewLibrary\", ...)` was added")
        ]
        XCTAssertEqual(changes, expectedChanges)
        
        waitForExpectations(timeout: 1)
    }
    
    func test_project_causesNoChanges() throws {
        
        let handleFileExpectation = expectation(description: "handleFileExists is called once")
        
        var fileHandler = MockFileHandler()
        fileHandler.handleFileExists = { _ in
            handleFileExpectation.fulfill()
            return false // Package.swift file does not exist
        }
        let libraryAnalyzer = LibraryAnalyzer(fileHandler: fileHandler)
        
        let changes = try libraryAnalyzer.analyze(
            oldProjectUrl: URL(filePath: "OldProject"),
            newProjectUrl: URL(filePath: "NewProject")
        )
        
        let expectedChanges: [Change] = []
        XCTAssertEqual(changes, expectedChanges)
        
        waitForExpectations(timeout: 1)
    }
}
