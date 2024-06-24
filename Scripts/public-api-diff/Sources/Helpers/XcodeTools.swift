//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 21/06/2024.
//

import Foundation

struct XcodeTools {
    
    private enum Constants {
        static let deviceTarget: String = "x86_64-apple-ios17.4-simulator"
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
    ) {
        let command = [
            "cd \(projectDirectoryPath);",
            "xcodebuild -scheme \"\(allTargetsLibraryName)\"",
            "-derivedDataPath \(Constants.derivedDataPath)",
            iOSTarget,
            "-destination \"platform=iOS,name=Any iOS Device\"",
            "-skipPackagePluginValidation"
        ]
        
        shell.execute(command.joined(separator: " "))
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
