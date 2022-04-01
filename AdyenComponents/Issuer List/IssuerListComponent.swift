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

    /// The Adyen context.
    public let adyenContext: AdyenContext
    
    /// The issuer list payment method.
    public var paymentMethod: PaymentMethod {
        issuerListPaymentMethod
    }
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// Component's configuration.
    public var configuration: Configuration
    
    /// Initializes the issuer list component.
    ///
    /// - Parameter paymentMethod: The issuer list payment method.
    /// - Parameter apiContext: The API context.
    /// - Parameter adyenContext: The Adyen context.
    /// - Parameter configuration: The configuration for the component.
    public init(paymentMethod: IssuerListPaymentMethod,
                apiContext: APIContext,
                adyenContext: AdyenContext,
                configuration: Configuration = .init()) {
        self.issuerListPaymentMethod = paymentMethod
        self.apiContext = apiContext
        self.adyenContext = adyenContext
        self.configuration = configuration
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
        let listViewController = ListViewController(style: configuration.style)
        listViewController.delegate = self
        let issuers = issuerListPaymentMethod.issuers
        let items = issuers.map { issuer -> ListItem in
            var listItem = ListItem(title: issuer.name, style: configuration.style.listItem)
            listItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: listItem.title)
            listItem.imageURL = LogoURLProvider.logoURL(for: issuer,
                                                        paymentMethod: issuerListPaymentMethod,
                                                        environment: apiContext.environment)
            listItem.selectionHandler = { [weak self] in
                guard let self = self else { return }
                
                let details = IssuerListDetails(paymentMethod: self.issuerListPaymentMethod,
                                                issuer: issuer.identifier)
                self.submit(data: PaymentComponentData(paymentMethodDetails: details, amount: self.amountToPay, order: self.order))
                listViewController.startLoading(for: listItem)
            }
            
            return listItem
        }
        
        listViewController.title = paymentMethod.name
        listViewController.reload(newSections: [ListSection(items: items)])
        
        return listViewController
    }()
}

extension IssuerListComponent: ViewControllerDelegate {

    /// :nodoc:
    public func viewWillAppear(viewController: UIViewController) {
        sendTelemetryEvent()
    }
}

extension IssuerListComponent: TrackableComponent {}

extension IssuerListComponent {
    
    /// Configuration for Issuer List type components.
    public struct Configuration {
        
        /// The UI style of the component.
        public var style: ListComponentStyle
        
        /// :nodoc:
        public var localizationParameters: LocalizationParameters?
        
        /// Initializes the configuration for Issuer list type components.
        /// - Parameters:
        ///   - style: The UI style of the component.
        ///   - localizationParameters: Localization parameters.
        public init(style: ListComponentStyle = .init(),
                    localizationParameters: LocalizationParameters? = nil) {
            self.style = style
            self.localizationParameters = localizationParameters
        }
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
