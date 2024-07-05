//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct XcodeToolsError: LocalizedError, CustomDebugStringConvertible {
    var errorDescription: String
    var debugDescription: String { errorDescription }
}

struct XcodeTools {
    
    private enum Constants {
        static let deviceTarget: String = "x86_64-apple-ios17.4-simulator"
        static let destination: String = "platform=iOS,name=Any iOS Device"
        static let derivedDataPath: String = ".build"
        static let simulatorSdkCommand = "xcrun --sdk iphonesimulator --show-sdk-path"
    }
    
    private let shell: ShellHandling
    
    init(shell: ShellHandling) {
        self.shell = shell
    }
    
    func build(
        projectDirectoryPath: String,
        allTargetsLibraryName: String
    ) throws {
        let command = "cd \(projectDirectoryPath); xcodebuild -scheme \(allTargetsLibraryName) -sdk `\(Constants.simulatorSdkCommand)` -derivedDataPath \(Constants.derivedDataPath) -destination \"\(Constants.destination)\" -target \(Constants.deviceTarget) -skipPackagePluginValidation"
        
        let result = shell.execute(command)
        if result.range(of: "xcodebuild: error:") != nil || result.range(of: "BUILD FAILED") != nil {
            throw XcodeToolsError(errorDescription: "💥 Building project failed")
        }
    }
    
    func dumpSdk(
        projectDirectoryPath: String,
        module: String,
        outputFilePath: String
    ) {
        let sdkDumpInputPath = projectDirectoryPath
            .appending("/\(Constants.derivedDataPath)")
            .appending("/Build/Products/Debug-iphonesimulator")
        
        let command = "cd \(projectDirectoryPath); xcrun swift-api-digester -dump-sdk -module \(module) -I \(sdkDumpInputPath) -o \(outputFilePath) -sdk `\(Constants.simulatorSdkCommand)` -target \(Constants.deviceTarget) -abort-on-module-fail"
        shell.execute(command)
    }
}
