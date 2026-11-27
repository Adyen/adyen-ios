//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

/// A callbacks container for handling card events.
///
/// Include `CardCallbacks` in the additional callbacks block of `CheckoutCallbacks` to:
/// - Observe changes to the card's bank identification number (BIN).
/// - Receive card-brand and issuing-country information from BIN lookup.
///
/// The callbacks run on the main actor.
///
/// For example:
/// ```swift
/// CardCallbacks()
///     .onBinChange { binValue in
///         print(binValue)
///     }
///     .onBinLookup { data in
///         print(data.issuingCountryCode)
///     }
/// ```
public struct CardCallbacks: CheckoutAdditionalCallbacks, AdvancedCheckoutAdditionalCallbacks {

    package private(set) var onBinChange: (@MainActor @Sendable (String) -> Void)?
    package private(set) var onBinLookup: (@MainActor @Sendable (BinLookupData) -> Void)?

    /// The address callbacks, which merchants supply as a separate entry.
    /// The card component factory attaches them.
    internal var addressCallbacks: AddressCallbacks?

    /// Creates a CardCallbacks instance without optional handlers.
    public init() {}

    /// Sets a callback for changes to the card's BIN.
    ///
    /// The callback is invoked whenever the BIN value changes. It fires for each of the first six digits,
    /// then sends the first eight digits once the card number is valid and has at least 16 digits.
    /// If the number is no longer valid, it goes back to six digits. When the field is cleared, it sends an empty string.
    ///
    /// - Parameter handler: The callback invoked when the BIN changes.
    ///   - binValue: The first six digits, or the first eight digits when the card number is valid and has at least 16 digits.
    /// - Returns: A modified copy of the callbacks.
    public func onBinChange(_ handler: @escaping @MainActor @Sendable (_ binValue: String) -> Void) -> Self {
        var callbacks = self
        callbacks.onBinChange = handler
        return callbacks
    }

    /// Sets a callback for card brands detected by BIN lookup.
    ///
    /// - Parameter handler: The callback invoked when BIN lookup returns card information.
    ///   - data: The `BinLookupData` containing the issuing country code and detected card brands.
    /// - Returns: A modified copy of the callbacks.
    public func onBinLookup(_ handler: @escaping @MainActor @Sendable (_ data: BinLookupData) -> Void) -> Self {
        var callbacks = self
        callbacks.onBinLookup = handler
        return callbacks
    }
}
