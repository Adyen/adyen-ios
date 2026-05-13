//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// Namespace for checkout flow types.
public enum CheckoutFlow {
    /// Marker type representing the Session checkout flow.
    public enum Session {}

    /// Marker type representing the Advanced checkout flow.
    public enum Advanced {}

    /// Marker type representing the action-only checkout flow.
    public enum ActionOnly {}
}
