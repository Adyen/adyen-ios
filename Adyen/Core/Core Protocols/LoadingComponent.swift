//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Any `Component` that shows a loading state of some kind when initiating another `PaymentComponent`.
public protocol ComponentLoader: LoadingComponent {
    /// Start loading a sub component.
    ///
    /// - Parameter component: The sub component.
    func startLoading(for component: PaymentComponent)
}

/// Any `Component` that show a loading state of some kind
public protocol LoadingComponent {
    /// Stops any processing animation that the view controller is running.
    ///
    func stopLoading()
}
