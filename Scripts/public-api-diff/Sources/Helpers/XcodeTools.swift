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
        static let deviceTarget: String = "x86_64-apple-ios17.4-simulator" // TODO: Match the iOS version to the sdk
        static let derivedDataPath: String = ".build"
        static let simulatorSdkCommand = "xcrun --sdk iphonesimulator --show-sdk-path"
    }
    
    // xcrun swift-ide-test -print-module -source-filename /Users/alexandergu/Library/Developer/Xcode/DerivedData/public-api-diff-egupzhmahwumtceocddrklkoobgs/Build/Products/Debug/tmp-public-api-diff/6AA36F6B-1599-430A-B7D0-2ADB220BCF7E/.build/Build/Products/Debug-iphonesimulator/Alamofire.swiftmodule/arm64-apple-ios-simulator.swiftmodule -sdk `xcrun --sdk iphonesimulator --show-sdk-path` -print-regular-comments -module-print-submodules -module-to-print CoreGraphics
    
    private let shell: ShellHandling
    
    init(shell: ShellHandling = Shell()) {
        self.shell = shell
    }
    
    func loadPackageDescription(
        projectDirectoryPath: String
    ) throws -> String {
        let command = [
            "cd \(projectDirectoryPath);",
            "swift package describe --type json"
        ]
        
        return shell.execute(command.joined(separator: " "))
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
        
        // print("👾 \(command.joined(separator: " "))")
        let result = shell.execute(command.joined(separator: " "))
        
        if result.range(of: "xcodebuild: error:") != nil || result.range(of: "BUILD FAILED") != nil {
            print(result)
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
        
        // print("👾 \(command.joined(separator: " "))")
        shell.execute(command.joined(separator: " "))
    }
    
    func diagnoseSdk(
        oldAbiJsonFilePath: String,
        newAbiJsonFilePath: String,
        module: String
    ) -> String {
        // https://github.com/mapbox/mapbox-navigation-ios/pull/4308/files#diff-53b9c5f29bb5c353edd0bbae0271d3750162c28a170a9ffccfd27e400e771cfbR20
        
        let command = [
            "xcrun --sdk iphoneos swift-api-digester -diagnose-sdk",
            "-module \(module)",
            "-input-paths \(oldAbiJsonFilePath)",
            "-input-paths \(newAbiJsonFilePath)"
        ]
        
        return shell.execute(command.joined(separator: " "))
    }
    
    private var iOSTarget: String {
        "-sdk `\(Constants.simulatorSdkCommand)` -target \(Constants.deviceTarget)"
    }
}
