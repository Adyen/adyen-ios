//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

// TODO: Refactor this

@_spi(AdyenInternal)
public final class AddressLookupComponent: NSObject, PresentableComponent {
    
    public var viewController: UIViewController { navigationController }
    
    public var context: Adyen.AdyenContext
    public var requiresModalPresentation: Bool = false
    
    // TODO: Replace with configuration
    private let style: FormComponentStyle
    private let localizationParameters: LocalizationParameters?
    private var prefillAddress: PostalAddress?
    private let supportedCountryCodes: [String]?
    private let lookupProvider: (_ searchTerm: String, _ resultProvider: @escaping ([PostalAddress]) -> Void) -> Void
    
    private let completionHandler: (PostalAddress) -> Void
    private var initialCountry: String
    
    /// Flag to indicate if the address lookup should be dismissed when search is cancelled
    ///
    /// Context: We show the search immediately when no address to prefill is provided
    /// and cancelling from this state should dismiss the whole flow.
    private var shouldDismissOnSearchDismissal: Bool
    
    /// Initializes the component.
    /// - Parameters:
    ///   - paymentMethod: The payment method.
    ///   - context: The context object for this component.
    ///   - configuration: The component's configuration.
    public init(
        context: AdyenContext,
        style: FormComponentStyle,
        initialCountry: String,
        prefillAddress: PostalAddress?,
        supportedCountryCodes: [String]?,
        localizationParameters: LocalizationParameters? = nil,
        lookupProvider: @escaping (_ searchTerm: String, _ resultProvider: @escaping ([PostalAddress]) -> Void) -> Void,
        completionHandler: @escaping (PostalAddress) -> Void
    ) {
        self.initialCountry = initialCountry
        self.context = context
        self.style = style
        self.prefillAddress = prefillAddress
        self.supportedCountryCodes = supportedCountryCodes
        self.lookupProvider = lookupProvider
        self.completionHandler = completionHandler
        self.localizationParameters = localizationParameters
        self.shouldDismissOnSearchDismissal = prefillAddress == nil
    }
    
    // MARK: ViewControllers
    
    private lazy var navigationController: UINavigationController = {
        UINavigationController(
            rootViewController: prefillAddress == nil ? searchController : securedViewController
        )
    }()
    
    private var securedViewController: SecuredViewController {
        let securedViewController = SecuredViewController(
            child: formViewController,
            style: style
        )
        securedViewController.navigationItem.leftBarButtonItem = .init(
            barButtonSystemItem: .cancel, // TODO: Localization & Styling
            target: self,
            action: #selector(cancelTapped)
        )
        securedViewController.navigationItem.rightBarButtonItem = .init(
            barButtonSystemItem: .done, // TODO: Localization & Styling
            target: self,
            action: #selector(doneTapped)
        )
        if #available(iOS 13.0, *) {
            securedViewController.isModalInPresentation = true
        }
        return securedViewController
    }
    
    private var searchController: SearchViewController {
        
        let emptyView = AddressLookupSearchEmptyView(
            localizationParameters: localizationParameters
        ) { [weak self] in
            guard let self else { return }
            showForm(with: prefillAddress)
        }
        
        let searchController = SearchViewController(
            style: style,
            searchBarPlaceholder: "Search your address",
            emptyView: emptyView,
            localizationParameters: localizationParameters
        ) { [weak self] searchTerm, resultHandler in
            self?.lookupProvider(searchTerm) { [weak self] results in
                guard let self else { return }
                resultHandler(results.compactMap(listItem(for:)))
            }
        }
        
        if #available(iOS 13.0, *) {
            searchController.isModalInPresentation = true
        }
        
        searchController.title = "Billing Address"
        searchController.navigationItem.rightBarButtonItem = .init(
            barButtonSystemItem: .cancel, // TODO: Localization & Styling
            target: self,
            action: #selector(dismissSearchTapped)
        )
        
        return searchController
    }
    
    private func listItem(for address: PostalAddress) -> ListItem? {
        guard !address.isEmpty else { return nil }
        
        let formattedStreet = address.formattedStreet
        let formattedLocation = address.formattedLocation(using: localizationParameters)
        
        let title = !formattedStreet.isEmpty ? formattedStreet : formattedLocation
        let subtitle = !formattedStreet.isEmpty ? formattedLocation : nil
        
        return .init(
            title: title,
            subtitle: subtitle
        ) { [weak self] in
            self?.showForm(with: address)
        }
    }
    
    internal lazy var formViewController: AddressLookupFormViewController = {
        AddressLookupFormViewController(
            formStyle: style,
            localizationParameters: localizationParameters,
            initialCountry: initialCountry,
            prefillAddress: prefillAddress,
            supportedCountryCodes: supportedCountryCodes
        ) { [weak self] in
            self?.showSearch()
        }
    }()
}

// MARK: - Action Handling

@objc
private extension AddressLookupComponent {
    
    func dismissSearchTapped() {
        if shouldDismissOnSearchDismissal { return cancelTapped() }
        showForm(with: prefillAddress)
    }
    
    func doneTapped() {
        guard formViewController.validate() else { return }
        completionHandler(formViewController.billingAddressItem.value)
    }
    
    func cancelTapped() {
        // TODO: Implement stuff in a delegate
        viewController.dismiss(animated: true)
    }
}

// MARK: - Navigation

private extension AddressLookupComponent {

    private func showForm(with address: PostalAddress?) {
        address.map { formViewController.billingAddressItem.value = $0 }
        show(viewController: securedViewController)
        shouldDismissOnSearchDismissal = false
    }
    
    private func showSearch() {
        prefillAddress = formViewController.billingAddressItem.value // Storing the value as the form resets when it disappears
        show(viewController: searchController)
    }
    
    private func show(viewController: UIViewController) {
        UIView.transition(
            with: navigationController.view,
            duration: 0.2,
            options: .transitionCrossDissolve
        ) {
            self.navigationController.viewControllers = [viewController]
        }
    }
}

// MARK: - ViewControllerDelegate

@_spi(AdyenInternal)
extension AddressLookupComponent: ViewControllerDelegate {
    // MARK: - ViewControllerDelegate

    public func viewWillAppear(viewController: UIViewController) {
//        sendTelemetryEvent() // TODO: Implement
//        populateFields()
    }
}
