//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A plugin that provides an input form for Open Invoice payments.
internal final class OpenInvoicePlugin: PaymentDetailsPlugin {
    
    internal let paymentSession: PaymentSession
    internal let paymentMethod: PaymentMethod
    
    internal init(paymentSession: PaymentSession, paymentMethod: PaymentMethod) {
        self.paymentSession = paymentSession
        self.paymentMethod = paymentMethod
    }
    
    // MARK: - Plugin
    
    internal func present(_ details: [PaymentDetail], using navigationController: UINavigationController, appearance: Appearance, completion: @escaping Completion<[PaymentDetail]>) {
        let paymentAmount = paymentSession.payment.amount
        var details = details
        
        let formViewController = OpenInvoiceFormViewController(appearance: appearance)
        formViewController.paymentMethod = paymentMethod
        formViewController.paymentSession = paymentSession
        formViewController.title = paymentMethod.name
        formViewController.payActionTitle = appearance.checkoutButtonAttributes.title(forAmount: paymentAmount.value, currencyCode: paymentAmount.currencyCode)
        
        var billingAddress: [PaymentDetail] = []
        if case let .address(details)? = details.billingAddress?.inputType {
            billingAddress = details
            formViewController.billingAddress = address(from: details)
        }
        
        var deliveryAddress: [PaymentDetail] = []
        if case let .address(details)? = details.deliveryAddress?.inputType {
            deliveryAddress = details
            formViewController.deliveryAddress = address(from: details)
        }
        
        var personalDataDetails: [PaymentDetail] = []
        if case let .fieldSet(details)? = details.personalDetails?.inputType {
            personalDataDetails = details
            formViewController.personalDetails = personalDetails(from: details)
        }
        
        formViewController.completion = { input in
            personalDataDetails.firstName?.value = input.personalDetails?.firstName
            personalDataDetails.lastName?.value = input.personalDetails?.lastName
            personalDataDetails.dateOfBirth?.value = input.personalDetails?.dateOfBirth
            personalDataDetails.gender?.value = input.personalDetails?.gender
            personalDataDetails.telephoneNumber?.value = input.personalDetails?.telephoneNumber
            personalDataDetails.socialSecurityNumber?.value = input.personalDetails?.socialSecurityNumber
            personalDataDetails.shopperEmail?.value = input.personalDetails?.shopperEmail
            
            billingAddress.street?.value = input.billingAddress?.street
            billingAddress.houseNumberOrName?.value = input.billingAddress?.houseNumber
            billingAddress.city?.value = input.billingAddress?.city
            billingAddress.postalCode?.value = input.billingAddress?.postalCode
            billingAddress.country?.value = input.billingAddress?.country
            
            deliveryAddress.street?.value = input.deliveryAddress?.street
            deliveryAddress.houseNumberOrName?.value = input.deliveryAddress?.houseNumber
            deliveryAddress.city?.value = input.deliveryAddress?.city
            deliveryAddress.postalCode?.value = input.deliveryAddress?.postalCode
            deliveryAddress.country?.value = input.deliveryAddress?.country
            
            details.personalDetails?.inputType = .fieldSet(personalDataDetails)
            details.billingAddress?.inputType = .address(billingAddress)
            details.deliveryAddress?.inputType = .address(deliveryAddress)
            details.separateDeliveryAddress?.value = input.separateDeliveryAddress?.stringValue()
            
            details.consent?.value = true.stringValue()
            
            completion(details)
        }
        
        navigationController.pushViewController(formViewController, animated: true)
        
    }
    
    // MARK: - Private
    
    private func personalDetails(from paymentDetails: [PaymentDetail]) -> OpenInvoicePersonalDetails {
        return OpenInvoicePersonalDetails(firstName: paymentDetails.firstName?.value,
                                          lastName: paymentDetails.lastName?.value,
                                          dateOfBirth: paymentDetails.dateOfBirth?.value,
                                          gender: paymentDetails.gender?.value,
                                          telephoneNumber: paymentDetails.telephoneNumber?.value,
                                          socialSecurityNumber: paymentDetails.socialSecurityNumber?.value,
                                          shopperEmail: paymentDetails.shopperEmail?.value)
    }
    
    private func address(from paymentDetails: [PaymentDetail]) -> OpenInvoiceAddress {
        return OpenInvoiceAddress(street: paymentDetails.street?.value,
                                  houseNumber: paymentDetails.houseNumberOrName?.value,
                                  city: paymentDetails.city?.value,
                                  postalCode: paymentDetails.postalCode?.value,
                                  country: paymentDetails.country?.value)
    }
}
