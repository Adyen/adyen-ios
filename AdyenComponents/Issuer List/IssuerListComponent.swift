//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A generic component for "issuer-based" payment methods, such as iDEAL and MOLPay.
/// This component will provide a list in which the user can select their issuer.
public final class IssuerListComponent: PaymentComponent, PresentableComponent, LoadingComponent {
    
    /// :nodoc:
    public let apiContext: APIContext
    
    /// The issuer list payment method.
    public var paymentMethod: PaymentMethod {
        issuerListPaymentMethod
    }
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// Describes the component's UI style.
    public let style: ListComponentStyle
    
    /// Initializes the issuer list component.
    ///
    /// - Parameter paymentMethod: The issuer list payment method.
    /// - Parameter style: The Component's UI style..
    public init(paymentMethod: IssuerListPaymentMethod,
                apiContext: APIContext,
                style: ListComponentStyle = ListComponentStyle()) {
        self.issuerListPaymentMethod = paymentMethod
        self.apiContext = apiContext
        self.style = style
    }
    
    private let issuerListPaymentMethod: IssuerListPaymentMethod
    
    // MARK: - Presentable Component Protocol
    
    public var viewController: UIViewController {
        listViewController
    }
    
    public func stopLoading() {
        listViewController.stopLoading()
    }
    
    /// :nodoc:
    public var requiresModalPresentation: Bool = true
    
    // MARK: - Private
    
    private lazy var listViewController: ListViewController = {
        let listViewController = ListViewController(style: style)
        listViewController.delegate = self
        let issuers = issuerListPaymentMethod.issuers
        let items = issuers.map { issuer -> ListItem in
            var listItem = ListItem(title: issuer.name, style: style.listItem)
            listItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: listItem.title)
            listItem.imageURL = LogoURLProvider.logoURL(for: issuer,
                                                        paymentMethod: issuerListPaymentMethod,
                                                        environment: apiContext.environment)
            listItem.selectionHandler = { [weak self] in
                guard let self = self else { return }
                
                let details = IssuerListDetails(paymentMethod: self.issuerListPaymentMethod,
                                                issuer: issuer.identifier)
                self.submit(data: PaymentComponentData(paymentMethodDetails: details, amount: self.payment?.amount, order: self.order))
                listViewController.startLoading(for: listItem)
            }
            
            return listItem
        }
        
        listViewController.title = paymentMethod.name
        listViewController.reload(newSections: [ListSection(items: items)])
        
        return listViewController
    }()
}

/// Provides an issuer selection list for iDEAL payments.
public typealias IdealComponent = IssuerListComponent

/// Provides an issuer selection list for MOLPay payments.
public typealias MOLPayComponent = IssuerListComponent

/// Provides an issuer selection list for Dotpay payments.
public typealias DotpayComponent = IssuerListComponent

/// Provides an issuer selection list for EPS payments.
public typealias EPSComponent = IssuerListComponent

/// Provides an issuer selection list for Entercash payments.
public typealias EntercashComponent = IssuerListComponent

/// Provides an issuer selection list for OpenBanking payments.
public typealias OpenBankingComponent = IssuerListComponent

extension IssuerListComponent: TrackableComponent {}
