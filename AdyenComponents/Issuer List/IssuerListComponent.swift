//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import protocol Adyen.PresentableComponent

#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import class AdyenUI.SearchViewController
#endif
import Foundation
import UIKit

/// A generic component for "issuer-based" payment methods, such as MOLPay.
/// This component will provide a list in which the user can select their issuer.
@MainActor
package final class IssuerListComponent: PaymentComponent, PresentableComponent, LoadingComponent {

    private enum Constants {
        static let searchDelay: TimeInterval = 1
    }
    
    /// The context object for this component.
    package let context: AdyenContext

    /// The issuer list payment method.
    package var paymentMethod: PaymentMethod {
        issuerListPaymentMethod
    }
    
    /// The delegate of the component.
    package weak var delegate: PaymentComponentDelegate?
    
    /// Component's configuration.
    package var configuration: Configuration

    /// The title of the view controller
    private let title: String
    
    private let searchThrottler = Throttler(minimumDelay: Constants.searchDelay)
    
    /// Initializes the issuer list component.
    ///
    /// - Parameter paymentMethod: The issuer list payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The configuration for the component.
    package init(
        paymentMethod: IssuerListPaymentMethod,
        context: AdyenContext,
        configuration: Configuration = .init()
    ) {
        self.issuerListPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
        self.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
    }

    package func submit() {
        // TODO: - COSDK-1262: Implementation will be done once the IssuerListComponent is redesigned to have a button.
    }

    private let issuerListPaymentMethod: IssuerListPaymentMethod

    // MARK: - Presentable Component Protocol
    
    package var viewController: UIViewController {
        let viewController = searchViewController
        viewController.title = title
        return viewController
    }

    private lazy var searchViewController: SearchViewController = {
        
        let viewModel = SearchViewController.ViewModel(
            localizationParameters: configuration.localizationParameters,
            style: configuration.style
        ) { [weak self] searchText, handler in
            guard let self else { return }
            handler(self.listItems(for: searchText))
        }
        
        let searchViewController = SearchViewController(
            viewModel: viewModel,
            emptyView: IssuerListEmptyView(
                localizationParameters: configuration.localizationParameters
            )
        )
        searchViewController.delegate = self
        
        return searchViewController
    }()

    package func stopLoading() {
        searchViewController.resultsListViewController.stopLoading()
    }

    // MARK: - Private

    private func listItems(for searchText: String) -> [ListItem] {
        let issuers = filteredIssuers(for: searchText)
        searchThrottler.throttle { [weak self] in
            self?.sendSearchIssuerEvent()
        }
        return listItems(from: issuers)
    }

    private func filteredIssuers(for searchText: String) -> [Issuer] {
        if searchText.isEmpty {
            return issuerListPaymentMethod.issuers
        }
        
        return issuerListPaymentMethod.issuers.filter {
            $0.name.range(of: searchText, options: .caseInsensitive) != nil
        }
    }
    
    private func listItems(from issuers: [Issuer]) -> [ListItem] {
        issuers.map { issuer -> ListItem in

            let logoUrl = LogoURLProvider.logoURL(
                for: issuer,
                localizedParameters: configuration.localizationParameters,
                paymentMethod: issuerListPaymentMethod,
                environment: context.apiContext.environment
            )
            let listItem = ListItem(
                title: issuer.name,
                icon: .init(url: logoUrl),
                style: configuration.style.listItem
            )
            listItem.identifier = ViewIdentifierBuilder.build(
                scopeInstance: self,
                postfix: listItem.title
            )
            listItem.selectionHandler = { [weak self, weak listItem] in
                guard let self, let listItem else { return }
                let details = IssuerListDetails(
                    paymentMethod: self.issuerListPaymentMethod,
                    issuer: issuer.identifier
                )
                self.submit(data: PaymentComponentData(
                    paymentMethodDetails: details,
                    amount: self.context.amount,
                    order: self.order
                ))
                
                self.sendIssuerSelectedEvent(issuer)
                
                listItem.startLoading()
            }
            return listItem
        }
    }
    
    private func sendIssuerSelectedEvent(_ issuer: Issuer) {
        var event = AnalyticsEventInfo(component: paymentMethod.type.rawValue, type: .selected)
        event.issuer = issuer.name
        event.target = .issuerList
        context.analyticsProvider?.add(info: event)
    }
    
    private func sendSearchIssuerEvent() {
        var event = AnalyticsEventInfo(component: paymentMethod.type.rawValue, type: .input)
        event.target = .listSearch
        context.analyticsProvider?.add(info: event)
    }
}

extension IssuerListComponent: ViewControllerDelegate {}

extension IssuerListComponent: TrackableComponent {}

extension IssuerListComponent {
    
    /// Configuration for Issuer List type components.
    package struct Configuration {

        /// The UI style of the component.
        package var style: ListComponentStyle

        package var localizationParameters: LocalizationParameters?

        package init(style: ListComponentStyle = .init()) {
            self.init(style: style, localizationParameters: nil)
        }

        package init(
            style: ListComponentStyle = .init(),
            localizationParameters: LocalizationParameters? = nil
        ) {
            self.style = style
            self.localizationParameters = localizationParameters
        }
    }
}

/// Provides an issuer selection list for MOLPay payments.
package typealias MOLPayComponent = IssuerListComponent

/// Provides an issuer selection list for Dotpay payments.
package typealias DotpayComponent = IssuerListComponent

/// Provides an issuer selection list for EPS payments.
package typealias EPSComponent = IssuerListComponent

/// Provides an issuer selection list for Entercash payments.
package typealias EntercashComponent = IssuerListComponent

/// Provides an issuer selection list for OpenBanking payments.
package typealias OpenBankingComponent = IssuerListComponent

/// Provides an issuer selection list for onlineBanking Poland .
package typealias OnlineBankingPolandComponent = IssuerListComponent
