//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains the result of a BIN lookup, provided to merchants via the `onBinLookup` callback.
public struct BinLookupData: Decodable, Equatable {

    /// The issuing country code detected from the BIN, or `nil` if not available.
    public let issuingCountryCode: String?

    /// The card brands detected from the BIN. Empty when no brands are detected.
    public let brands: [BinLookupBrand]
}

/// Describes a single card brand entry in a BIN lookup result.
public struct BinLookupBrand: Decodable, Equatable {

    /// The brand identifier, e.g. `"visa"`, `"mc"`.
    public let brand: String

    /// Indicates whether the brand is supported by the merchant.
    public let supported: Bool

    /// The payment method variant, if provided by the backend.
    public let paymentMethodVariant: String?
}
