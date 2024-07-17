//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 16/07/2024.
//

@testable import public_api_diff
import XCTest

class ProjectBuilderTests: XCTestCase {
    
    func test_buildPackage() throws {
        
        let baseWorkingDirectoryPath = "baseWorkingDirectoryPath"
        let randomString = "RANDOM_STRING"
        let localPath = "local/path"
        
        let dummyPackageContent = "products: []"
        let expectedConsolidatedPackageContent = "products: [\n        .library(\n            name: \"_AllTargets\",\n            targets: []\n        ),]"
        
        let removeItemExpectation = expectation(description: "FileHandler.removeItem is called once")
        
        var fileHandler = MockFileHandler()
        fileHandler.handleCreateDirectory = { path in
            XCTAssertEqual(path, "\(baseWorkingDirectoryPath)/\(randomString)")
        }
        fileHandler.handleContentsOfDirectory = { path in
            XCTAssertEqual(path, localPath)
            return []
        }
        fileHandler.handleLoadData = { path in
            XCTAssertEqual(path, "\(baseWorkingDirectoryPath)/\(randomString)/Package.swift")
            return try XCTUnwrap(dummyPackageContent.data(using: .utf8))
        }
        fileHandler.handleRemoveItem = { path in
            XCTAssertEqual(path, "\(baseWorkingDirectoryPath)/\(randomString)/Package.swift")
            removeItemExpectation.fulfill()
        }
        fileHandler.handleCreateFile = { path, data in
            XCTAssertEqual(String(data: data, encoding: .utf8), expectedConsolidatedPackageContent)
            XCTAssertEqual(path, "\(baseWorkingDirectoryPath)/\(randomString)/Package.swift")
            return true
        }
        var shell = MockShell()
        shell.handleExecute = { command in
            if command == "cd \(baseWorkingDirectoryPath)/\(randomString); swift package describe --type json" {
                let packageDescription = SwiftPackageDescription(
                    defaultLocalization: "en-en",
                    products: [],
                    targets: [],
                    toolsVersion: "1.0"
                )
                let encodedPackageDescription = try! JSONEncoder().encode(packageDescription)
                return String(data: encodedPackageDescription, encoding: .utf8)!
            } else if command == "cd baseWorkingDirectoryPath/RANDOM_STRING; xcodebuild -scheme \"_AllTargets\" -derivedDataPath .build -sdk `xcrun --sdk iphonesimulator --show-sdk-path` -target x86_64-apple-ios17.4-simulator -destination \"platform=iOS,name=Any iOS Device\" -skipPackagePluginValidation" {
                return ""
            } else {
                XCTFail("MockShell called with unhandled command \(command)")
                return ""
            }
        }
        var logger = MockLogger()
        logger.handleLog = { message, subsystem in
            XCTAssertEqual(message, "🛠️ Building project at `\(baseWorkingDirectoryPath)/\(randomString)`")
            XCTAssertEqual(subsystem, "ProjectBuilder")
        }
        
        var randomStringGenerator = MockRandomStringGenerator()
        randomStringGenerator.onGenerateRandomString = { randomString }
        
        let projectBuilder = ProjectBuilder(
            baseWorkingDirectoryPath: baseWorkingDirectoryPath,
            fileHandler: fileHandler,
            shell: shell,
            randomStringGenerator: randomStringGenerator,
            logger: logger
        )
        
        let projectWorkingDirectoryUrl = try projectBuilder.build(source: .local(path: "local/path"), scheme: nil)
        XCTAssertEqual(projectWorkingDirectoryUrl, URL(filePath: "\(baseWorkingDirectoryPath)/\(randomString)"))
        
        wait(for: [removeItemExpectation], timeout: 1)
    }
}

private extension String.SubSequence {
    
    var toString: String {
        String(self)
    }
}
