//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 12/07/2024.
//

import Foundation

struct ABIGenerator: ABIGenerating {
    
    private let xcodeTools: XcodeTools
    private let fileHandler: any FileHandling
    private let logger: (any Logging)?
    
    init(
        xcodeTools: XcodeTools = XcodeTools(),
        fileHandler: any FileHandling = FileManager.default,
        logger: (any Logging)?
    ) {
        self.xcodeTools = xcodeTools
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
                logger: logger
            )
        }
        
        return try generator.generate(
            for: projectDirectory,
            scheme: scheme
        )
    }
}
