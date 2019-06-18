//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class CoderTests: XCTestCase {
    
    func testDecodeWithString() {
        let sampleObject = try! Coder.decode(sampleObjectRawString) as SampleObject
        
        XCTAssertEqual(sampleObject.string, "someString")
        XCTAssertEqual(sampleObject.integer, 99)
        XCTAssertEqual(sampleObject.date.description, "2015-02-28 21:30:00 +0000")
        XCTAssertEqual(sampleObject.nestedObject.nestedValue, "value")
    }
    
    func testDecodeWithData() {
        let data = sampleObjectRawString.data(using: .utf8)!
        let sampleObject = try! Coder.decode(data) as SampleObject
        
        XCTAssertEqual(sampleObject.string, "someString")
        XCTAssertEqual(sampleObject.integer, 99)
        XCTAssertEqual(sampleObject.date.description, "2015-02-28 21:30:00 +0000")
        XCTAssertEqual(sampleObject.nestedObject.nestedValue, "value")
    }
    
    func testEncodeToString() {
        let encodedString = try! Coder.encode(sampleObject) as String
        
        XCTAssertEqual(encodedString, sampleObjectRawString)
    }
    
    func testEncodeToData() {
        let encodedData = try! Coder.encode(sampleObject) as Data
        let expectedData = sampleObjectRawString.data(using: .utf8)
        
        XCTAssertEqual(encodedData, expectedData)
    }
    
    // MARK: - Private
    
    private let sampleObjectRawString = "{\"nested\":{\"nestedValue\":\"value\"},\"string\":\"someString\",\"some_integer\":99,\"date\":\"2015-02-28T21:30:00Z\"}"
    
    private lazy var sampleObject: SampleObject = {
        let nestedObject = NestedObject(nestedValue: "value")
        let date = Date(timeIntervalSince1970: 1425159000)
        return SampleObject(string: "someString", integer: 99, date: date, nestedObject: nestedObject)
    }()
    
    private struct SampleObject: Decodable, Encodable {
        var string: String
        var integer: Int
        var date: Date
        var nestedObject: NestedObject
        
        enum CodingKeys: String, CodingKey {
            case string
            case integer = "some_integer"
            case date
            case nestedObject = "nested"
        }
    }
    
    private struct NestedObject: Decodable, Encodable {
        var nestedValue: String
        
        enum CodingKeys: String, CodingKey {
            case nestedValue
        }
    }
}
