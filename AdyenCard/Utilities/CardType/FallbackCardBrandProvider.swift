//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Fall back to local regex-based detector if API not available or BIN too short.
/// :nodoc:
internal final class FallbackBinInfoProvider: AnyBinInfoProvider {

    /// :nodoc:
    internal func provide(for bin: String, supportedTypes: [CardType], completion: @escaping (BinLookupResponse) -> Void) {
        // only return result out of the given supported types.
        let result: [CardBrand] = supportedTypes.adyen.types(forCardNumber: bin).map { type in

            let cvcPolicy: CardBrand.RequirementPolicy
            switch type {
            case .laser,
                 .bcmc,
                 .maestro,
                 .uatp,
                 .oasis,
                 .karenMillen,
                 .warehouse:
                cvcPolicy = .optional
            default:
                cvcPolicy = .required
            }

            return CardBrand(type: type, cvcPolicy: cvcPolicy)
        }
        completion(BinLookupResponse(brands: result))
    }
}
