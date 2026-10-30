//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// A callbacks container for looking up and completing shopper addresses.
///
/// Include `AddressCallbacks` in the additional callbacks block of `CheckoutCallbacks` to:
/// - Return addresses matching the shopper's search term.
/// - Optionally fetch complete address details when the shopper selects a result.
///
/// Configure the component's billing address mode as `.lookup()` to use these callbacks.
/// `.lookup()` requires them: without `AddressCallbacks`, `Checkout.setup` throws ``CheckoutError``
/// with the ``CheckoutError/Code/invalidConfiguration`` code.
///
/// For example:
/// ```swift
/// AddressCallbacks(onAddressLookup: { query in
///     await searchAddresses(matching: query)
/// })
/// .onAddressSelected { result in
///     try await fetchAddress(for: result)
/// }
/// ```
public struct AddressCallbacks: CheckoutAdditionalCallbacks, AdvancedCheckoutAdditionalCallbacks {

    package let onAddressLookup: (String) async -> [AddressLookupResult]
    package private(set) var onAddressSelected: ((AddressLookupResult) async throws -> PostalAddress)?

    /// Creates an AddressCallbacks instance.
    ///
    /// - Parameter onAddressLookup: The callback invoked when the shopper enters a search term.
    ///   - query: The search term entered by the shopper.
    ///   - Returns: The matching address results to display.
    public init(onAddressLookup: @escaping (_ query: String) async -> [AddressLookupResult]) {
        self.onAddressLookup = onAddressLookup
    }

    /// Sets a callback to complete a selected address.
    ///
    /// When unset, the selected result's postal address is used as-is.
    ///
    /// - Parameter handler: The callback invoked when the shopper selects an address.
    ///   - result: The selected address lookup result, which may contain a partial address.
    ///   - Returns: The completed postal address.
    ///   - Throws: An error if the address details cannot be retrieved.
    /// - Returns: A modified copy of the callbacks.
    public func onAddressSelected(
        _ handler: @escaping (_ result: AddressLookupResult) async throws -> PostalAddress
    ) -> Self {
        var callbacks = self
        callbacks.onAddressSelected = handler
        return callbacks
    }
}
