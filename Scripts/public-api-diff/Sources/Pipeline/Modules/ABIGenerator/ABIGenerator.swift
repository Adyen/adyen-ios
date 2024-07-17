//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 12/07/2024.
//

import Foundation

struct ABIGenerator: ABIGenerating {
    
    private let xcodeTools: XcodeTools
    private let packageFileHelper: PackageFileHelper
    private let fileHandler: FileHandling
    private let logger: Logging?
    
    init(
        xcodeTools: XcodeTools = XcodeTools(),
        packageFileHelper: PackageFileHelper = .init(fileHandler: FileManager.default, xcodeTools: XcodeTools()),
        fileHandler: FileHandling = FileManager.default,
        logger: Logging?
    ) {
        self.xcodeTools = xcodeTools
        self.packageFileHelper = packageFileHelper
        self.fileHandler = fileHandler
        self.logger = logger
    }
    
    func generate(
        for projectDirectory: URL,
        scheme: String?
    ) throws -> [ABIGeneratorOutput] {
        
        let generator: ABIGenerating
        
        if scheme != nil {
            generator = ProjectABIProvider(
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
            scheme: scheme
        )
    }
}
