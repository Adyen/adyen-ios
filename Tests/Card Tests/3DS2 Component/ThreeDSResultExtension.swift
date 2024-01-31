//
//  ThreeDSResultExtension.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 22/12/2022.
//  Copyright © 2022 Adyen. All rights reserved.
//

@_documentation(visibility: internal) @testable import AdyenActions
import Foundation

extension ThreeDSResult: Equatable {
    public static func == (lhs: ThreeDSResult, rhs: ThreeDSResult) -> Bool {
        lhs.payload == rhs.payload
    }
}
