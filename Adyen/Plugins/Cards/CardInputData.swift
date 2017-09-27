//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

struct CardInputData {
    let holderName: String
    let number: String
    let expiryMonth: String
    let expiryYear: String
    let cvc: String
    let storeDetails: Bool
    let installments: String?
    
    init(number: String, expiryDate: String, cvc: String, storeDetails: Bool, installments: String?) {
        let dateComponents = expiryDate.replacingOccurrences(of: " ", with: "").components(separatedBy: "/")
        let month = dateComponents[0]
        let year = "20" + dateComponents[1]
        
        self.number = number
        self.expiryMonth = month
        self.expiryYear = year
        self.cvc = cvc
        self.storeDetails = storeDetails
        self.holderName = "Checkout Shopper Placeholder"
        self.installments = installments
    }
}
