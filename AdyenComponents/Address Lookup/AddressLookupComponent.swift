//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

public final class AddressLookupComponent: NSObject, PresentableComponent {
    
    public lazy var viewController: UIViewController = {
        let securedViewController = SecuredViewController(
            child: formViewController,
            style: configuration.style
        )
        securedViewController.navigationItem.leftBarButtonItem = .init(
            barButtonSystemItem: .cancel, // TODO: Localization
            target: self,
            action: #selector(cancelTapped)
        )
        securedViewController.navigationItem.rightBarButtonItem = .init(
            barButtonSystemItem: .done, // TODO: Localization
            target: self,
            action: #selector(doneTapped)
        )
        securedViewController.navigationItem.searchController = searchController
        return securedViewController
    }()
    
    public var context: Adyen.AdyenContext
    
    public var configuration: PersonalInformationConfiguration // TODO: Replace with more custom configuration
    private let initialCountry: String
    private let supportedCountryCodes: [String]?
    
    /// Initializes the component.
    /// - Parameters:
    ///   - paymentMethod: The payment method.
    ///   - context: The context object for this component.
    ///   - configuration: The component's configuration.
    public init(
        context: AdyenContext,
        configuration: PersonalInformationConfiguration,
        initialCountry: String,
        supportedCountryCodes: [String]?
    ) {
        self.context = context
        self.configuration = configuration
        self.initialCountry = initialCountry
        self.supportedCountryCodes = supportedCountryCodes
    }
    
    internal lazy var searchController: UISearchController = {
        
        // TODO: Issue with the UISearchController is that we want to wrap a list inside of a secure viewcontroller and that messes up the scrolling behavior - write a generic AsyncSearchViewController instead with a custom search bar and a 
        
        let searchController = UISearchController(searchResultsController: searchResultsViewController) // TODO: Make sure styling works
        searchController.searchResultsUpdater = self
        return searchController
    }()
    
    internal lazy var searchResultsViewController: ListViewController = {
        let searchResultsViewController = ListViewController(style: configuration.style) // TODO: Make sure styling works
        searchResultsViewController.delegate = self
        return searchResultsViewController
    }()
    
    internal lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: configuration.style)
        formViewController.localizationParameters = configuration.localizationParameters
        formViewController.title = "Address"
        formViewController.delegate = self
        
        formViewController.append(billingAddressItem)

        return formViewController
    }()
    
    internal lazy var billingAddressItem: FormAddressItem = {
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "billingAddress")

        // TODO: Make actually work
        
        let item = FormAddressItem(initialCountry: initialCountry,
                                   style: configuration.style.addressStyle,
                                   localizationParameters: configuration.localizationParameters,
                                   identifier: identifier,
                                   supportedCountryCodes: supportedCountryCodes,
                                   addressViewModelBuilder: DefaultAddressViewModelBuilder()) // TODO: Make this injectable?
        configuration.shopperInformation?.billingAddress.map { item.value = $0 }
        item.style.backgroundColor = UIColor.Adyen.lightGray
        return item
    }()
    
    @objc
    private func doneTapped() {
        if formViewController.validate() {
            // TODO: Implement stuff in a delegate
            viewController.presentingViewController?.dismiss(animated: true)
        }
    }
    
    @objc
    private func cancelTapped() {
        // TODO: Implement stuff in a delegate
        viewController.presentingViewController?.dismiss(animated: true)
    }
    
    internal func populateFields() {
        guard let shopperInformation = configuration.shopperInformation else { return }

        shopperInformation.billingAddress.map { billingAddressItem.value = $0 }
//        shopperInformation.deliveryAddress.map { deliveryAddressItem?.value = $0 }
    }
}

@_spi(AdyenInternal)
extension AddressLookupComponent: ViewControllerDelegate {
    // MARK: - ViewControllerDelegate

    public func viewWillAppear(viewController: UIViewController) {
//        sendTelemetryEvent()
//        populateFields()
    }
}

@_spi(AdyenInternal)
extension AddressLookupComponent: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, searchText.count > 0 else {
            // TODO: Show empty
            return
        }
        
        // TODO: Start loading
        
        // TODO: Call into delegate/provider
        
        print(searchText)
        
        let listSection = ListSection(
            header: .init(title: "Results", style: .init()), // TODO: Styling
            items: searchText.map { .init(title: "\($0)") }
        )
        
        searchResultsViewController.reload(newSections: [listSection], animated: true)
        
        // TODO: Stop loading
    }
    
    public func textDidChange(_ searchBar: UISearchBar, searchText: String) {}
}
