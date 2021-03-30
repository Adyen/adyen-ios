//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Fall back to local regex-based detector if API not available or BIN too short.
/// :nodoc:
internal final class FallbackCardBrandProvider: AnyCardBrandProvider {

    /// :nodoc:
    internal func provide(for parameters: CardBrandProviderParameters, completion: @escaping (BinLookupResponse) -> Void) {
        let result: [CardBrand] = parameters.supportedTypes.adyen.types(forCardNumber: parameters.bin).map { brand in

            var cvcPolicy: CardBrand.CVCPolicy = .required

            switch brand {
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

            return CardBrand(type: brand,
                             cvcPolicy: cvcPolicy)
        }
        completion(BinLookupResponse(brands: result))
    }
}
