//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Represents the observation of an observer to an observable.
@_spi(AdyenInternal)
public struct Observation: Hashable {
    
    /// The UUID of the observation.
    private let uuid = UUID()
    
    /// Alias for the unobserve handler.
    internal typealias UnobserveHandler = () -> Void
    
    /// The handler to invoke to remove the observation.
    internal let unobserveHandler: UnobserveHandler
    
    /// Initializes the observation.
    ///
    /// - Parameter unobserveHandler: The handler to invoke to remove the observation.
    internal init(unobserveHandler: @escaping UnobserveHandler) {
        self.unobserveHandler = unobserveHandler
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: Observation, rhs: Observation) -> Bool {
        lhs.uuid == rhs.uuid
    }
    
    // MARK: - Hashable
    
    public func hash(into hasher: inout Hasher) {
        uuid.hash(into: &hasher)
    }
    
}
