//
//  PersistedTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 27/07/2022.
//  Copyright © 2022 Adyen. All rights reserved.
//

@_spi(AdyenInternal) @testable import AdyenActions
import XCTest

class PersistedTests: XCTestCase {

    func testOptionalObjectWithNilDefault() throws {
        let persisted = Persisted<RedirectAction?>(defaultValue: nil, key: "persistedObject")
        let persistedObject: RedirectAction? = RedirectAction(url: URL(string: "https://google.com")!, paymentData: "paymentData")
        
        persisted.wrappedValue = persistedObject
        
        XCTAssertEqual(persisted.wrappedValue?.url, URL(string: "https://google.com")!)
        XCTAssertEqual(persisted.wrappedValue?.paymentData, "paymentData")
        XCTAssertNotNil(persisted.userDefaults.object(forKey: "persistedObject"))
        
        persisted.wrappedValue = nil
        XCTAssertNil(persisted.wrappedValue)
        XCTAssertNil(persisted.userDefaults.object(forKey: "persistedObject"))
    }
    
    func testOptionalObjectWithNonNilDefault() throws {
        let persisted = Persisted<RedirectAction?>(defaultValue: RedirectAction(url: URL(string: "https://default.google.com")!, paymentData: "defaultpaymentData"), key: "persistedObject")
        XCTAssertEqual(persisted.wrappedValue?.url, URL(string: "https://default.google.com")!)
        XCTAssertEqual(persisted.wrappedValue?.paymentData, "defaultpaymentData")
        
        
        let persistedObject: RedirectAction? = RedirectAction(url: URL(string: "https://google.com")!, paymentData: "paymentData")
        persisted.wrappedValue = persistedObject
        
        XCTAssertEqual(persisted.wrappedValue?.url, URL(string: "https://google.com")!)
        XCTAssertEqual(persisted.wrappedValue?.paymentData, "paymentData")
        XCTAssertNotNil(persisted.userDefaults.object(forKey: "persistedObject"))
        
        persisted.wrappedValue = nil
        XCTAssertEqual(persisted.wrappedValue?.url, URL(string: "https://default.google.com")!)
        XCTAssertEqual(persisted.wrappedValue?.paymentData, "defaultpaymentData")
    }
    
    func testNonOptionalObject() throws {
        let persisted = Persisted<RedirectAction>(defaultValue: RedirectAction(url: URL(string: "https://default.google.com")!, paymentData: "defaultpaymentData"), key: "persistedObject")
        let persistedObject: RedirectAction = RedirectAction(url: URL(string: "https://google.com")!, paymentData: "paymentData")
        
        persisted.wrappedValue = persistedObject
        
        XCTAssertEqual(persisted.wrappedValue.url, URL(string: "https://google.com")!)
        XCTAssertEqual(persisted.wrappedValue.paymentData, "paymentData")
        XCTAssertNotNil(persisted.userDefaults.object(forKey: "persistedObject"))
        
        persisted.userDefaults.removeObject(forKey: "persistedObject")
        XCTAssertEqual(persisted.wrappedValue.url, URL(string: "https://default.google.com")!)
        XCTAssertEqual(persisted.wrappedValue.paymentData, "defaultpaymentData")
    }

}
