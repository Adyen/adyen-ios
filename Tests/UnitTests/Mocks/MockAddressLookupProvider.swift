//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

class MockAddressLookupProvider: AddressLookupProvider {
    private var resultProvider: (_ searchTerm: String) -> [AddressLookupResult]
    
    required init(resultProvider: @escaping (String) -> [AddressLookupResult]) {
        self.resultProvider = resultProvider
    }
    
    func lookUp(searchTerm: String, resultHandler: @escaping ([AddressLookupResult]) -> Void) {
        resultHandler(resultProvider(searchTerm))
    }
}

extension MockAddressLookupProvider {
    
    static var alwaysFailing: Self {
        .init { _ in
            XCTFail("Lookup provider should not have been called")
            return []
        }
    }
}
