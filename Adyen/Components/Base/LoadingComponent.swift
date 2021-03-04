//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Any `Component` that shows a loading state of some kind when initiating another `PaymentComponent`.
/// :nodoc:
public protocol ComponentLoader: LoadingComponent {
    /// :nodoc:
    func startLoading(for component: PaymentComponent)
}

/// Any `Component` that show a loading state of some kind
/// :nodoc:
public protocol LoadingComponent {
    /// Stops any processing animation that the view controller is running.
    ///
    /// - Parameters:
    ///   - completion: Completion block to be called when animations are finished.
    func stopLoading(completion: (() -> Void)?)
}
