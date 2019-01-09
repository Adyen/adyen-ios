//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenInternal
import Foundation

internal extension Coder {
    internal static func decode<T: Decodable>(resourceNamed name: String) throws -> T {
        let bundle = Bundle(for: PaymentSessionTests.self)
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            fatalError("Can't find resource named \"\(name)\".")
        }
        
        let data = try Data(contentsOf: url)
        
        return try decode(data)
    }
    
}
