//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public protocol LoadingComponent {
    /// :nodoc:
    func startLoading(for component: PaymentComponent)

    /// Stops any processing animation that the view controller is running.
    ///
    /// - Parameters:
    ///   - success: Boolean indicating the component should go to a success or failure state.
    ///   - completion: Completion block to be called when animations are finished.
    func stopLoading(withSuccess success: Bool, completion: (() -> Void)?)
}

extension LoadingComponent {

    /// Stops any processing animation that the view controller is running.
    public func stopLoading() {
        stopLoading(withSuccess: true, completion: nil)
    }

    /// Stops any processing animation that the view controller is running.
    ///
    /// - Parameters:
    ///   - success: Boolean indicating the component should go to a success or failure state.
    public func stopLoading(withSuccess success: Bool) {
        stopLoading(withSuccess: success, completion: nil)
    }

    /// Stops any processing animation that the view controller is running.
    ///
    /// - Parameters:
    ///   - success: Boolean indicating the component should go to a success or failure state.
    ///   - completion: Completion block to be called when animations are finished.
    public func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        completion?()
    }

    /// :nodoc:
    public func startLoading(for component: PaymentComponent) { /* Empty default implementation */ }
}
