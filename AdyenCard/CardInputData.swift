//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

struct CardInputData {
    let encryptedCard: CardEncryptor.EncryptedCard
    let holderName: String
    let storeDetails: Bool
    let installments: String?
    
    init(encryptedCard: CardEncryptor.EncryptedCard, holderName: String?, storeDetails: Bool, installments: String?) {
        self.storeDetails = storeDetails
        self.installments = installments
        self.encryptedCard = encryptedCard
        
        if let holderName = holderName, holderName.isEmpty == false {
            self.holderName = holderName
        } else {
            self.holderName = "Checkout Shopper Placeholder"
        }
    }
}
