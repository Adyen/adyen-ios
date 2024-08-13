//
//  File.swift
//  
//
//  Created by Alexander Guretzki on 12/07/2024.
//

import Foundation

enum PipelineError: LocalizedError {
    case noTargetFound
    
    var errorDescription: String? {
        switch self {
        case .noTargetFound: "No targets found to analyze"
        }
    }
}
