//
//  XCTestCase+Result.swift
//  AdyenSession
//
//  Created by Eren Besel on 3/15/22.
//  Copyright © 2022 Adyen. All rights reserved.
//

import Foundation

extension Result {
    
    var failure: Failure? {
        switch self {
        case .success:
            return nil
        case let .failure(failure):
            return failure
        }
    }
}
