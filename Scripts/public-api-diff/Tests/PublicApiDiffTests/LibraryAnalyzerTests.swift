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
        
        var fileHandler = MockFileHandler()
        fileHandler.handleFileExists = { _ in
            handleFileExpectation.fulfill()
            return true
        }
        var shell = MockShell()
        shell.handleExecute = { _ in
            let packageDescription = SwiftPackageDescription(
                defaultLocalization: "en-en",
                products: [],
                targets: [],
                toolsVersion: "1.0"
            )
            let encodedPackageDescription = try! JSONEncoder().encode(packageDescription)
            return String(data: encodedPackageDescription, encoding: .utf8)!
        }
        
        let xcodeTools = XcodeTools(shell: shell)
        
        let libraryAnalyzer = LibraryAnalyzer(
            fileHandler: fileHandler,
            xcodeTools: xcodeTools
        )
        
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
        
        var fileHandler = MockFileHandler()
        fileHandler.handleFileExists = { _ in
            handleFileExpectation.fulfill()
            return true
        }
        
        var shell = MockShell()
        shell.handleExecute = { command in
            let packageDescription: SwiftPackageDescription
            
            if command.range(of: "NewPackage") != nil {
                packageDescription = SwiftPackageDescription(
                    defaultLocalization: "en-en",
                    products: [.init(name: "NewLibrary", targets: [])],
                    targets: [],
                    toolsVersion: "1.0"
                )
            } else {
                packageDescription = SwiftPackageDescription(
                    defaultLocalization: "en-en",
                    products: [.init(name: "OldLibrary", targets: [])],
                    targets: [],
                    toolsVersion: "1.0"
                )
            }
            
            let encodedPackageDescription = try! JSONEncoder().encode(packageDescription)
            return String(data: encodedPackageDescription, encoding: .utf8)!
        }
        
        let xcodeTools = XcodeTools(shell: shell)
        
        let libraryAnalyzer = LibraryAnalyzer(fileHandler: fileHandler, xcodeTools: xcodeTools)
        
        let changes = try libraryAnalyzer.analyze(
            oldProjectUrl: URL(filePath: "OldPackage"),
            newProjectUrl: URL(filePath: "NewPackage")
        )
        
        let expectedChanges: [Change] = [
            .init(changeType: .removal(description: ".library(name: \"OldLibrary\", ...)"), parentName: ""),
            .init(changeType: .addition(description: ".library(name: \"NewLibrary\", ...)"), parentName: "")
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
