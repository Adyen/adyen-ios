//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

class PaymentMethodCardPluginTests: XCTestCase {
    
    func testCVCOptional() {
        let paymentMethodWithOptionalCVC = newPaymentMethod(isCVCOptional: true)
        XCTAssertTrue(paymentMethodWithOptionalCVC.isCVCOptional)
        
        let paymentMethodWithoutOptionalCVC = newPaymentMethod(isCVCOptional: false)
        XCTAssertFalse(paymentMethodWithoutOptionalCVC.isCVCOptional)
    }
    
    func testCVCRequested() {
        let paymentMethodWithoutCVC = newPaymentMethod(configuration: ["noCVC": "true"])
        XCTAssertFalse(paymentMethodWithoutCVC.isCVCRequested)
        
        let paymentMethodWithCVC = newPaymentMethod(configuration: nil)
        XCTAssertTrue(paymentMethodWithCVC.isCVCRequested)
    }
    
    func newPaymentMethod(isCVCOptional: Bool = false, configuration: [String: Any]? = nil) -> PaymentMethod {
        let inputDetail = InputDetail(type: .cardToken(cvcOptional: isCVCOptional),
                                      key: "cardToken",
                                      value: nil,
                                      optional: false,
                                      items: nil,
                                      inputDetails: nil,
                                      configuration: configuration)
        
        let paymentMethod = PaymentMethod(name: "Test",
                                          type: "card",
                                          isOneClick: false,
                                          oneClickInfo: nil,
                                          logoURL: nil,
                                          inputDetails: [inputDetail],
                                          members: nil,
                                          group: nil,
                                          paymentMethodData: "")
        
        return paymentMethod
    }
    
}
