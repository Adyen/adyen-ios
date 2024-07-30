//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
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
