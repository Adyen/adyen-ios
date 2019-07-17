//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A generic component for "issuer-based" payment methods, such as iDEAL and MOLPay.
/// This component will provide a list in which the user can select their issuer.
public final class IssuerListComponent: PaymentComponent, PresentableComponent {
    
    /// The issuer list payment method.
    public let paymentMethod: PaymentMethod
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// Initializes the component.
    ///
    /// - Parameter paymentMethod: The issuer list payment method.
    public init(paymentMethod: IssuerListPaymentMethod) {
        self.paymentMethod = paymentMethod
        self.issuerListPaymentMethod = paymentMethod
    }
    
    private let issuerListPaymentMethod: IssuerListPaymentMethod
    
    // MARK: - Presentable Component Protocol
    
    public lazy var viewController: UIViewController = {
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)
        return ComponentViewController(rootViewController: listViewController, cancelButtonHandler: didSelectCancelButton)
    }()
    
    public func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        listViewController.stopLoading()
    }
    
    // MARK: - Private
    
    private lazy var listViewController: ListViewController = {
        let listViewController = ListViewController()
        
        let issuers = issuerListPaymentMethod.issuers
        let items = issuers.map { issuer -> ListItem in
            var listItem = ListItem(title: issuer.name)
            listItem.imageURL = LogoURLProvider.logoURL(for: issuer,
                                                        paymentMethod: issuerListPaymentMethod,
                                                        environment: environment)
            listItem.showsDisclosureIndicator = false
            listItem.selectionHandler = { [weak self] in
                guard let self = self else { return }
                
                let details = IssuerListDetails(type: self.paymentMethod.type,
                                                issuer: issuer.identifier)
                self.delegate?.didSubmit(PaymentComponentData(paymentMethodDetails: details), from: self)
                listViewController.startLoading(for: listItem)
            }
            
            return listItem
        }
        
        listViewController.navigationItem.title = paymentMethod.name
        listViewController.sections = [ListSection(items: items)]
        
        return listViewController
    }()
    
    private lazy var didSelectCancelButton: (() -> Void) = { [weak self] in
        guard let self = self else { return }
        
        self.delegate?.didFail(with: ComponentError.cancelled, from: self)
    }
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
