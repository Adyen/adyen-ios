//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class KeyedDecodingContainerExtensions: XCTestCase {
    
    func testDecodeIntStringWithValidValue() {
        let data = "{ \"someInt\": \"5\" }".data(using: .utf8)!
        
        let testObject = try? JSONDecoder().decode(TestObject.self, from: data)
        
        XCTAssertEqual(testObject?.someInt, 5)
    }
    
    func testDecodeIntStringWithInvalidValue() {
        let data = "{ \"someInt\": \"notAnInteger\" }".data(using: .utf8)!
        
        XCTAssertThrowsError(try JSONDecoder().decode(TestObject.self, from: data))
    }
}

private struct TestObject: Decodable {
    let someInt: Int
    
    /// :nodoc:
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.someInt = try container.decodeIntString(forKey: .someInt)
    }
    
    private enum CodingKeys: String, CodingKey {
        case someInt
    }
}
