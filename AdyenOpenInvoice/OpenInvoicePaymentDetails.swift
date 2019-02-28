//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension Array where Element == PaymentDetail {
    
    /// The payment detail for personal details section
    var personalDetails: PaymentDetail? {
        get {
            return self[openInvoicePersonalDetails]
        }
        
        set {
            self[openInvoicePersonalDetails] = newValue
        }
    }
    
    /// The payment detail for billing address section
    var billingAddress: PaymentDetail? {
        get {
            return self[openInvoiceBillingAddress]
        }
        
        set {
            self[openInvoiceBillingAddress] = newValue
        }
    }
    
    /// The payment detail for delivery address section
    var deliveryAddress: PaymentDetail? {
        get {
            return self[openInvoiceDeliveryAddress]
        }
        
        set {
            self[openInvoiceDeliveryAddress] = newValue
        }
    }
    
    /// The payment detail for separate delivery address flag
    var separateDeliveryAddress: PaymentDetail? {
        get {
            return self[openInvoiceSeparateDeliveryAddress]
        }
        
        set {
            self[openInvoiceSeparateDeliveryAddress] = newValue
        }
    }
    
    /// The payment detail for first name
    var firstName: PaymentDetail? {
        get {
            return self[openInvoiceFirstName]
        }
        
        set {
            self[openInvoiceFirstName] = newValue
        }
    }
    
    /// The payment detail for last name
    var lastName: PaymentDetail? {
        get {
            return self[openInvoiceLastName]
        }
        
        set {
            self[openInvoiceLastName] = newValue
        }
    }
    
    /// The payment detail for gender
    var gender: PaymentDetail? {
        get {
            return self[openInvoiceGender]
        }
        
        set {
            self[openInvoiceGender] = newValue
        }
    }
    
    /// The payment detail for date of birth
    var dateOfBirth: PaymentDetail? {
        get {
            return self[openInvoiceDateOfBirth]
        }
        
        set {
            self[openInvoiceDateOfBirth] = newValue
        }
    }
    
    /// The payment detail for telephone number
    var telephoneNumber: PaymentDetail? {
        get {
            return self[openInvoiceTelephoneNumber]
        }
        
        set {
            self[openInvoiceTelephoneNumber] = newValue
        }
    }
    
    /// The payment detail for shopper email
    var shopperEmail: PaymentDetail? {
        get {
            return self[openInvoiceShopperEmail]
        }
        
        set {
            self[openInvoiceShopperEmail] = newValue
        }
    }
    
    /// The payment detail for social security number
    var socialSecurityNumber: PaymentDetail? {
        get {
            return self[klarnaSocialSecurityNumber]
        }
        
        set {
            self[klarnaSocialSecurityNumber] = newValue
        }
    }
    
    /// The payment detail for street
    var street: PaymentDetail? {
        get {
            return self[openInvoiceStreet]
        }
        
        set {
            self[openInvoiceStreet] = newValue
        }
    }
    
    /// The payment detail for house number
    var houseNumberOrName: PaymentDetail? {
        get {
            return self[openInvoiceHouseNumberOrName]
        }
        
        set {
            self[openInvoiceHouseNumberOrName] = newValue
        }
    }
    
    /// The payment detail for city
    var city: PaymentDetail? {
        get {
            return self[openInvoiceCity]
        }
        
        set {
            self[openInvoiceCity] = newValue
        }
    }
    
    /// The payment detail for postal code
    var postalCode: PaymentDetail? {
        get {
            return self[openInvoicePostalCode]
        }
        
        set {
            self[openInvoicePostalCode] = newValue
        }
    }
    
    /// The payment detail for country
    var country: PaymentDetail? {
        get {
            return self[openInvoiceCountry]
        }
        
        set {
            self[openInvoiceCountry] = newValue
        }
    }
    
    /// The payment detail for consent
    var consent: PaymentDetail? {
        get {
            return self[openInvoiceConsent]
        }
        
        set {
            self[openInvoiceConsent] = newValue
        }
    }
    
}

private let openInvoicePersonalDetails = "personalDetails"
private let openInvoiceBillingAddress = "billingAddress"
private let openInvoiceDeliveryAddress = "deliveryAddress"
private let openInvoiceSeparateDeliveryAddress = "separateDeliveryAddress"

private let openInvoiceFirstName = "firstName"
private let openInvoiceLastName = "lastName"
private let openInvoiceGender = "gender"
private let openInvoiceDateOfBirth = "dateOfBirth"
private let openInvoiceTelephoneNumber = "telephoneNumber"
private let openInvoiceShopperEmail = "shopperEmail"

private let openInvoiceStreet = "street"
private let openInvoiceHouseNumberOrName = "houseNumberOrName"
private let openInvoiceCity = "city"
private let openInvoicePostalCode = "postalCode"
private let openInvoiceCountry = "country"

private let openInvoiceConsent = "consentCheckbox"

private let klarnaSocialSecurityNumber = "socialSecurityNumber"
