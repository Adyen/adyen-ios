//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import public_api_diff
import XCTest

class XcodeToolsTests: XCTestCase {
    
    func test_dumpSdk() throws {
        let projectDirectoryPath = UUID().uuidString
        let module = UUID().uuidString
        let outputFilePath = UUID().uuidString
        
        let mockShell = MockShell { command in
            let expectedCommand = "cd \(projectDirectoryPath); xcrun swift-api-digester -dump-sdk -module \(module) -I .build/Build/Products/Debug-iphonesimulator -o \(outputFilePath) -sdk `xcrun --sdk iphonesimulator --show-sdk-path` -target x86_64-apple-ios17.4-simulator -abort-on-module-fail"
            
            XCTAssertEqual(command, expectedCommand)
            
            return ""
        }
        
        let xcodeTools = XcodeTools(shell: mockShell)
        xcodeTools.dumpSdk(projectDirectoryPath: projectDirectoryPath, module: module, outputFilePath: outputFilePath)
    }
    
    func test_build() throws {
        let projectDirectoryPath = UUID().uuidString
        let allTargetsLibraryName = UUID().uuidString
        
        let mockShell = MockShell { command in
            print(command)
            
            let expectedCommand = "cd \(projectDirectoryPath); xcodebuild -scheme \"\(allTargetsLibraryName)\" -derivedDataPath .build -sdk `xcrun --sdk iphonesimulator --show-sdk-path` -target x86_64-apple-ios17.4-simulator -destination \"platform=iOS,name=Any iOS Device\" -skipPackagePluginValidation"
            
            XCTAssertEqual(command, expectedCommand)
            
            return ""
        }
        
        let xcodeTools = XcodeTools(shell: mockShell)
        xcodeTools.build(projectDirectoryPath: projectDirectoryPath, allTargetsLibraryName: allTargetsLibraryName)
    }
}
