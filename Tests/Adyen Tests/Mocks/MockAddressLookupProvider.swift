//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import XCTest

class MockAddressLookupProvider: AddressLookupProvider {
    private var resultProvider: (_ searchTerm: String) -> [LookupAddressModel]
    
    required init(resultProvider: @escaping (String) -> [LookupAddressModel]) {
        self.resultProvider = resultProvider
    }
    
    func lookUp(searchTerm: String, resultHandler: @escaping ([LookupAddressModel]) -> Void) {
        resultHandler(resultProvider(searchTerm))
    }
}

extension MockAddressLookupProvider {
    
    static var alwaysFailing: Self {
        return .init { _ in
            XCTFail("Lookup provider should not have been called")
            return []
        }
    }
}
