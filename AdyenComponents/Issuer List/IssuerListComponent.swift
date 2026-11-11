//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey
import AdyenUI
@_spi(AdyenInternal) import class AdyenUI.SearchViewController
import Foundation
import UIKit

/// A generic component for "issuer-based" payment methods, such as MOLPay.
/// This component will provide a list in which the user can select their issuer.
@MainActor
package final class IssuerListComponent: PaymentComponent, LoadingComponent {

    private enum Constants {
        static let searchDelay: TimeInterval = 1
        /// The search bar is shown only when there are more issuers than this.
        static let searchBarIssuerThreshold = 10
    }

    private enum Layout {
        static let resultsHorizontalInset: CGFloat = 16
        static let listItemSpacing: CGFloat = 12
        static let listItemHorizontalInset: CGFloat = 14
    }
    
    /// The context object for this component.
    package let context: AdyenContext

    /// The issuer list payment method.
    package var paymentMethod: PaymentMethod {
        issuerListPaymentMethod
    }
    
    /// The delegate of the component.
    package weak var delegate: PaymentComponentDelegate?
    
    package let type: PaymentComponentType = .regular
    package let requiresUserInteraction: Bool = true
    
    /// Component's configuration.
    package var configuration: IssuerListConfiguration

    /// The title of the view controller
    private let title: String
    
    private let searchThrottler = Throttler(minimumDelay: Constants.searchDelay)

    /// The index of the selected issuer in the payment method's issuers.
    private var selectedIssuerIndex: Int?

    /// The search text of the last results, used to send search events only when it changes.
    private var lastSearchText = ""
    
    /// Initializes the issuer list component.
    ///
    /// - Parameter paymentMethod: The issuer list payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The configuration for the component.
    package init(
        paymentMethod: IssuerListPaymentMethod,
        context: AdyenContext,
        configuration: IssuerListConfiguration = .init()
    ) {
        self.issuerListPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
        self.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
    }

    package func performSubmit() {
        guard let selectedIssuerIndex else {
            headerView.showsError = true
            return
        }

        headerView.showsError = false
        submitButton.showsActivityIndicator = true
        searchViewController.view.isUserInteractionEnabled = false

        let details = IssuerListDetails(
            paymentMethod: issuerListPaymentMethod,
            issuer: issuerListPaymentMethod.issuers[selectedIssuerIndex].identifier
        )
        submit(data: PaymentComponentData(paymentMethodDetails: details, order: order))
    }

    private let issuerListPaymentMethod: IssuerListPaymentMethod

    // MARK: - Presentable Component Protocol
    
    package var viewController: UIViewController {
        searchViewController
    }

    private lazy var searchViewController: SearchViewController = {
        
        let viewModel = SearchViewController.ViewModel(
            localizationParameters: configuration.localizationParameters,
            style: configuration.style,
            theme: configuration.theme,
            shouldShowSearchBar: issuerListPaymentMethod.issuers.count > Constants.searchBarIssuerThreshold
        ) { [weak self] searchText, handler in
            guard let self else { return }
            handler(self.listItems(for: searchText))
        }
        
        let searchViewController = SearchViewController(
            viewModel: viewModel,
            emptyView: IssuerListEmptyView(
                localizationParameters: configuration.localizationParameters
            ),
            headerView: headerView,
            footerView: configuration.showsSubmitButton ? submitButton : nil,
            resultsHorizontalInset: Layout.resultsHorizontalInset
        )
        searchViewController.separatesResultsIntoSections = true
        searchViewController.resultsListViewController.sectionSpacing = Layout.listItemSpacing
        searchViewController.delegate = self
        
        return searchViewController
    }()

    private lazy var headerView = IssuerListHeaderView(
        title: title,
        description: localizedString(.issuerListDescription, configuration.localizationParameters),
        errorMessage: localizedString(.issuerListErrorNoSelection, configuration.localizationParameters),
        theme: configuration.theme,
        identifierScope: String(describing: self)
    )

    private lazy var submitButton: FormButton = {
        let button = FormButton(theme: configuration.theme)
        button.title = localizedString(.continueTitle, configuration.localizationParameters)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "submitButton")
        button.addAction(UIAction { [weak self] _ in self?.performSubmit() }, for: .touchUpInside)
        return button
    }()

    package func stopLoading() {
        submitButton.showsActivityIndicator = false
        searchViewController.view.isUserInteractionEnabled = true
    }

    // MARK: - Private

    private func listItems(for searchText: String) -> [ListItem] {
        if searchText != lastSearchText {
            lastSearchText = searchText
            searchThrottler.throttle { [weak self] in
                self?.sendSearchIssuerEvent()
            }
        }
        return listItems(from: filteredIssuers(for: searchText))
    }

    private func filteredIssuers(for searchText: String) -> [(index: Int, issuer: Issuer)] {
        let issuers = issuerListPaymentMethod.issuers.enumerated().map { (index: $0.offset, issuer: $0.element) }
        if searchText.isEmpty {
            return issuers
        }
        
        return issuers.filter {
            $0.issuer.name.range(of: searchText, options: .caseInsensitive) != nil
        }
    }
    
    private func listItems(from issuers: [(index: Int, issuer: Issuer)]) -> [ListItem] {
        issuers.map { index, issuer -> ListItem in

            let logoUrl = LogoURLProvider.logoURL(
                for: issuer,
                localizedParameters: configuration.localizationParameters,
                paymentMethod: issuerListPaymentMethod,
                environment: context.apiContext.environment
            )
            let listItem = ListItem(
                title: issuer.name,
                icon: .init(url: logoUrl),
                titleEmphasis: .primary,
                horizontalContentInset: Layout.listItemHorizontalInset,
                isSelected: index == selectedIssuerIndex,
                selectionHandler: { [weak self] in
                    self?.selectIssuer(at: index)
                }
            )
            listItem.identifier = ViewIdentifierBuilder.build(
                scopeInstance: self,
                postfix: listItem.title
            )
            return listItem
        }
    }

    private func selectIssuer(at index: Int) {
        searchViewController.view.endEditing(true)
        selectedIssuerIndex = index
        headerView.showsError = false
        sendIssuerSelectedEvent(issuerListPaymentMethod.issuers[index])
        searchViewController.reloadResults()
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
