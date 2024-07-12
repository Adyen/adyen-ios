//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct XcodeToolsError: LocalizedError, CustomDebugStringConvertible {
    var errorDescription: String
    var underlyingError: String
    
    var debugDescription: String { errorDescription }
}

struct XcodeTools {
    
    private enum Constants {
        static let deviceTarget: String = "x86_64-apple-ios17.4-simulator"
        static let derivedDataPath: String = ".build"
        static let simulatorSdkCommand = "xcrun --sdk iphonesimulator --show-sdk-path"
    }
    
    private let shell: ShellHandling
    
    init(shell: ShellHandling = Shell()) {
        self.shell = shell
    }
    
    func build(
        projectDirectoryPath: String,
        scheme: String,
        isPackage: Bool
    ) throws {
        var command = [
            "cd \(projectDirectoryPath);",
            "xcodebuild -scheme \"\(scheme)\"",
            "-derivedDataPath \(Constants.derivedDataPath)",
            iOSTarget,
            "-destination \"platform=iOS,name=Any iOS Device\"",
        ]
        
        if isPackage {
            command += [
                "-skipPackagePluginValidation"
            ]
        }
        
        let result = shell.execute(command.joined(separator: " "))
        if result.range(of: "xcodebuild: error:") != nil || result.range(of: "BUILD FAILED") != nil {
            throw XcodeToolsError(
                errorDescription: "💥 Building project failed",
                underlyingError: result
            )
        }
    }
    
    func dumpSdk(
        projectDirectoryPath: String,
        module: String,
        outputFilePath: String
    ) {
        let sdkDumpInputPath = "\(Constants.derivedDataPath)/Build/Products/Debug-iphonesimulator"
        
        let command = [
            "cd \(projectDirectoryPath);",
            "xcrun swift-api-digester -dump-sdk",
            "-module \(module)",
            "-I \(sdkDumpInputPath)",
            "-o \(outputFilePath)",
            iOSTarget,
            "-abort-on-module-fail"
        ]
        
        shell.execute(command.joined(separator: " "))
    }
    
    private var iOSTarget: String {
        "-sdk `\(Constants.simulatorSdkCommand)` -target \(Constants.deviceTarget)"
    }
}
