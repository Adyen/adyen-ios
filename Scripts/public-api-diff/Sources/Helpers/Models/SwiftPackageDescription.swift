//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 17/07/2024.
//

import Foundation

struct SwiftPackageDescription: Codable {
    
    let defaultLocalization: String
    let products: [Product]
    let targets: [Target]
    let toolsVersion: String
    
    var warnings = [String]()
    
    enum CodingKeys: String, CodingKey {
        case defaultLocalization = "default_localization"
        case products
        case targets
        case toolsVersion = "tools_version"
    }
}

extension SwiftPackageDescription {
    
    struct Product: Codable {
        
        let name: String
        let targets: [String]
    }
}

extension SwiftPackageDescription {
    
    struct Target: Codable {
        
        enum ModuleType: String, Codable {
            case swiftTarget = "SwiftTarget"
            case binaryTarget = "BinaryTarget"
        }
        
        let name: String
        let type: String // library, binary, ...
        let path: String
        let moduleType: ModuleType
        
        let productDependencies: [String]?
        let productMemberships: [String]
        let sources: [String]
        let targetDependencies: [String]?
        
        let resources: [Resource]?
        
        enum CodingKeys: String, CodingKey {
            case moduleType = "module_type"
            case name
            case productDependencies = "product_dependencies"
            case productMemberships = "product_memberships"
            case sources
            case targetDependencies = "target_dependencies"
            case type
            case path
            case resources
        }
    }
}

extension SwiftPackageDescription.Target {
    
    struct Resource: Codable {
        
        let path: String
    }
}
