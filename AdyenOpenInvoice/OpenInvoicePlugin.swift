//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
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
    
    internal var preferredPresentationMode: PaymentDetailsPluginPresentationMode {
        return .push
    }
    
    internal func viewController(for details: [PaymentDetail], appearance: Appearance, completion: @escaping Completion<[PaymentDetail]>) -> UIViewController {
        var details = details
        let amount = paymentSession.payment.amount(for: paymentMethod)
        
        let formViewController = OpenInvoiceFormViewController(appearance: appearance)
        formViewController.paymentMethod = paymentMethod
        formViewController.paymentSession = paymentSession
        formViewController.title = paymentMethod.name
        formViewController.payActionTitle = appearance.checkoutButtonAttributes.title(for: amount)
        
        if let surcharge = paymentMethod.surcharge, let amountString = AmountFormatter.formatted(amount: surcharge.total, currencyCode: amount.currencyCode) {
            formViewController.payActionSubtitle = ADYLocalizedString("surcharge.formatted", amountString)
        }
        
        if case let .address(details)? = details.billingAddress?.inputType {
            formViewController.billingAddress = address(from: details)
        }
        
        if case let .address(details)? = details.deliveryAddress?.inputType {
            formViewController.deliveryAddress = address(from: details)
        }
        
        if case let .fieldSet(details)? = details.personalDetails?.inputType {
            formViewController.personalDetails = personalDetails(from: details)
        }
        
        formViewController.completion = { [weak self] input in
            if let fulfilledDetails = self?.fulfilled(details: details, with: input) {
                completion(fulfilledDetails)
            }
        }
        
        return formViewController
    }
    
    // MARK: - Private
    
    private func fulfilled(details: [PaymentDetail], with input: OpenInvoiceFormViewController.Input) -> [PaymentDetail] {
        guard case var .address(billingAddress)? = details.billingAddress?.inputType,
            case var .address(deliveryAddress)? = details.deliveryAddress?.inputType,
            case var .fieldSet(personalDataDetails)? = details.personalDetails?.inputType else {
            return details
        }
        
        var detailsCopy = details
        
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
        
        detailsCopy.personalDetails?.inputType = .fieldSet(personalDataDetails)
        detailsCopy.billingAddress?.inputType = .address(billingAddress)
        detailsCopy.deliveryAddress?.inputType = .address(deliveryAddress)
        detailsCopy.separateDeliveryAddress?.value = input.separateDeliveryAddress?.stringValue()
        
        detailsCopy.consent?.value = true.stringValue()
        
        return detailsCopy
    }
    
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
                                  country: paymentDetails.country?.value ?? paymentSession.payment.countryCode)
    }
}
