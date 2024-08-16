//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct ABIGenerator: ABIGenerating {
    
    private let shell: ShellHandling
    private let xcodeTools: XcodeTools
    private let packageFileHelper: PackageFileHelper
    private let fileHandler: FileHandling
    private let logger: Logging?
    
    init(
        shell: ShellHandling = Shell(),
        fileHandler: FileHandling = FileManager.default,
        logger: Logging?
    ) {
        self.shell = shell
        self.xcodeTools = XcodeTools(shell: shell)
        self.packageFileHelper = .init(fileHandler: fileHandler, xcodeTools: xcodeTools)
        self.fileHandler = fileHandler
        self.logger = logger
    }
    
    func generate(
        for projectDirectory: URL,
        scheme: String?,
        description: String
    ) throws -> [ABIGeneratorOutput] {
        
        let generator: ABIGenerating
        
        if scheme != nil {
            generator = ProjectABIProvider(
                shell: shell,
                fileHandler: fileHandler,
                logger: logger
            )
        } else {
            generator = PackageABIGenerator(
                fileHandler: fileHandler,
                xcodeTools: xcodeTools,
                packageFileHelper: packageFileHelper,
                logger: logger
            )
        }
        
        return try generator.generate(
            for: projectDirectory,
            scheme: scheme,
            description: description
        )
    }
}
