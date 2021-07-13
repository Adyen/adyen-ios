//
//  AffirmComponent.swift
//  AdyenComponents
//
//  Created by Naufal Aros on 7/6/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for Affirm payment.
public final class AffirmComponent: AbstractPersonalInformationComponent {
    
    // MARK: - Initializers
    
    public init(paymentMethod: PaymentMethod,
                apiContext: APIContext,
                style: FormComponentStyle) {
        // TODO: - Init logic
        // 1. Set configuration
        let configuration = Configuration(fields: AffirmComponent.fields)
        
        super.init(paymentMethod: paymentMethod,
                   configuration: configuration,
                   apiContext: apiContext)
    }
    
    public override func submitButtonTitle() -> String {
        "SUBMIT DATA"
    }
    
    // MARK: - Private
    
    private static var fields: [PersonalInformation] {
        let fields: [PersonalInformation] = [.firstName, .lastName, .email]
        return fields
    }
}
