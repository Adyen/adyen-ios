//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

@_spi(AdyenInternal)
public final class AddressLookupComponent: NSObject, PresentableComponent {
    
    public lazy var viewController: UIViewController = {
        let securedViewController = SecuredViewController(
            child: formViewController,
            style: style
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

        if #available(iOS 13.0, *) {
            securedViewController.isModalInPresentation = true
        }
        
        return UINavigationController(rootViewController: securedViewController)
    }()
    
    public var context: Adyen.AdyenContext
    
    // TODO: Replace with configuration
    private let style: FormComponentStyle
    private let localizationParameters: LocalizationParameters?
    private var address: PostalAddress?
    private let supportedCountryCodes: [String]?
    private let lookupProvider: (_ searchTerm: String, _ resultProvider: @escaping ([PostalAddress]) -> Void) -> Void
    private let completionHandler: (PostalAddress) -> Void
    
    public var requiresModalPresentation: Bool = false
    
    /// Initializes the component.
    /// - Parameters:
    ///   - paymentMethod: The payment method.
    ///   - context: The context object for this component.
    ///   - configuration: The component's configuration.
    public init(
        context: AdyenContext,
        style: FormComponentStyle,
        initialAddress: PostalAddress?,
        supportedCountryCodes: [String]?,
        localizationParameters: LocalizationParameters? = nil,
        lookupProvider: @escaping (_ searchTerm: String, _ resultProvider: @escaping ([PostalAddress]) -> Void) -> Void,
        completionHandler: @escaping (PostalAddress) -> Void
    ) {
        self.context = context
        self.style = style
        self.address = initialAddress
        self.supportedCountryCodes = supportedCountryCodes
        self.lookupProvider = lookupProvider
        self.completionHandler = completionHandler
        self.localizationParameters = localizationParameters
    }
    
    internal lazy var searchResultsViewController: ListViewController = {
        let searchResultsViewController = ListViewController(style: style) // TODO: Make sure styling works
        searchResultsViewController.delegate = self
        return searchResultsViewController
    }()
    
    internal lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: style)
        formViewController.localizationParameters = localizationParameters
        formViewController.title = "Billing Address"
        formViewController.delegate = self
        
        formViewController.append(searchButtonItem)
        formViewController.append(billingAddressItem)

        return formViewController
    }()
    
    internal lazy var searchButtonItem: FormSearchButtonItem = {
        
        FormSearchButtonItem(
            placeholder: "Search your address"
        ) { [weak self] in
            guard let self else { return }
            showAddressSearch()
        }
    }()
    
    private func showAddressSearch() {
        let searchController = AsyncSearchViewController(
            style: style,
            searchBarPlaceholder: "Search your address",
            resultProvider: { [weak self] searchTerm, resultHandler in
                self?.lookupProvider(searchTerm) { [weak self] results in
                    guard let self else { return }
                    resultHandler(results.map(listItem(for:)))
                }
            }
        )
        
        searchController.title = formViewController.title
        searchController.navigationItem.hidesBackButton = true
        searchController.navigationItem.rightBarButtonItem = .init(
            barButtonSystemItem: .cancel, // TODO: Localization
            target: self,
            action: #selector(dismissSearchTapped)
        )
        
        UIView.transition(with: viewController.view, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
            guard let self else { return }

            (viewController as? UINavigationController)?.pushViewController(searchController, animated: false)
        }
    }
    
    private func listItem(for address: PostalAddress) -> ListItem {
        .init(
            title: address.formattedStreet,
            subtitle: address.formattedLocation,
            selectionHandler: { [weak self] in
                guard let self else { return }
                self.address = address
                billingAddressItem.value = address
                dismissSearchTapped()
            },
            iconMode: .none
        )
    }
    
    internal lazy var billingAddressItem: FormAddressItem = {
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "billingAddress")
        
        let item = FormAddressItem(initialCountry: address?.country ?? "NL", // TODO: Provide better initialCountry
                                   style: style.addressStyle,
                                   localizationParameters: localizationParameters,
                                   identifier: identifier,
                                   supportedCountryCodes: supportedCountryCodes,
                                   addressViewModelBuilder: DefaultAddressViewModelBuilder()) // TODO: Make this injectable?
        address.map { item.value = $0 }
        item.style.backgroundColor = UIColor.Adyen.lightGray
        item.title = nil
        return item
    }()
    
    @objc
    private func dismissSearchTapped() {
        UIView.transition(with: viewController.view, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
            guard let self else { return }

            (viewController as? UINavigationController)?.popToRootViewController(animated: false)
        }
    }
    
    @objc
    private func doneTapped() {
        if formViewController.validate() {
            guard let address else { return }
            completionHandler(address)
        }
    }
    
    @objc
    private func cancelTapped() {
        // TODO: Implement stuff in a delegate
        viewController.dismiss(animated: true)
    }
    
    deinit {
        print("☠️ \(String(describing: self))")
    }
}

@_spi(AdyenInternal)
extension AddressLookupComponent: ViewControllerDelegate {
    // MARK: - ViewControllerDelegate

    public func viewWillAppear(viewController: UIViewController) {
//        sendTelemetryEvent() // TODO: Implement
//        populateFields()
    }
}
