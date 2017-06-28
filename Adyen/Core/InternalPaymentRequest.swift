//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains payment data.
class InternalPaymentRequest {
    
    let paymentRequestData: Data
    let amount: Int
    let currency: String
    let country: String
    let merchantReference: String
    let shopperLocale: String?
    let generationTime: String
    let logoBaseURL: String
    let initiationURL: URL
    let deletePreferredURL: URL?
    
    var shopperReference: String?
    var oneClick = true
    var paymentMethod: PaymentMethod?
    var publicKey: String?
    var paymentData: String
    
    init?(data: Data) {
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let requestInfo = json as? [String: Any],
            let paymentInfo = requestInfo["payment"] as? [String: Any],
            let paymentAmountInfo = paymentInfo["amount"] as? [String: Any],
            let amount = paymentAmountInfo["value"] as? Int,
            let currency = paymentAmountInfo["currency"] as? String,
            let country = paymentInfo["countryCode"] as? String,
            let merchantReference = paymentInfo["reference"] as? String,
            let paymentData = requestInfo["paymentData"] as? String,
            let generationTime = requestInfo["generationtime"] as? String,
            let logoBaseURL = requestInfo["logoBaseUrl"] as? String,
            let initiationUrlString = requestInfo["initiationUrl"] as? String,
            let initiationURL = URL(string: initiationUrlString)
        else {
            return nil
        }
        
        self.logoBaseURL = logoBaseURL
        self.initiationURL = initiationURL
        self.amount = amount
        self.currency = currency
        self.country = country
        self.merchantReference = merchantReference
        self.paymentData = paymentData
        self.generationTime = generationTime
        
        oneClick = (shopperReference != nil)
        paymentRequestData = data
        shopperReference = paymentInfo["shopperReference"] as? String
        publicKey = requestInfo["publicKey"] as? String
        shopperLocale = requestInfo["shopperLocale"] as? String
        
        let deleteURLString = requestInfo["disableRecurringDetailUrl"] as? String
        deletePreferredURL = URL(string: deleteURLString ?? "")
    }
}
