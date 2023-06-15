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

        if #available(iOS 13.0, *) {
            securedViewController.isModalInPresentation = true
        }
        
        return UINavigationController(rootViewController: securedViewController)
    }()
    
    public var context: Adyen.AdyenContext
    
    public var configuration: PersonalInformationConfiguration // TODO: Replace with more custom configuration
    private let initialCountry: String
    private let supportedCountryCodes: [String]?
    
    public var requiresModalPresentation: Bool = false
    
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
    
    internal lazy var searchResultsViewController: ListViewController = {
        let searchResultsViewController = ListViewController(style: configuration.style) // TODO: Make sure styling works
        searchResultsViewController.delegate = self
        return searchResultsViewController
    }()
    
    internal lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: configuration.style)
        formViewController.localizationParameters = configuration.localizationParameters
        formViewController.title = "Billing Address"
        formViewController.delegate = self
        
        // TODO: Create actual fake searchbar
        let fakeSearchBar = FormSearchButtonItem(
            placeholder: "Search your address"
        ) { [weak self] in
            guard let self else { return }
            
            let searchController = AsyncSearchViewController(
                style: configuration.style,
                searchBarPlaceholder: "Search your address",
                resultProvider: { searchTerm, resultHandler in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        if Bool.random() {
                            resultHandler([])
                        } else {
                            let address = PostalAddress(
                                city: "Amsterdam",
                                country: "NL",
                                houseNumberOrName: "109",
                                postalCode: "1053WR",
                                stateOrProvince: "Noord Holland",
                                street: "Da Costakade (\(searchTerm))",
                                apartment: "2"
                            )
                            
                            resultHandler([.init(
                                title: address.formattedStreet,
                                subtitle: address.formattedLocation,
                                selectionHandler: {
                                    print(address.formatted)
                                },
                                iconMode: .none
                            )])
                        }
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
        formViewController.append(fakeSearchBar)
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
    private func dismissSearchTapped() {
        UIView.transition(with: viewController.view, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
            guard let self else { return }

            (viewController as? UINavigationController)?.popToRootViewController(animated: false)
        }
    }
    
    @objc
    private func doneTapped() {
        if formViewController.validate() {
            // TODO: Implement stuff in a delegate
            viewController.dismiss(animated: true)
        }
    }
    
    @objc
    private func cancelTapped() {
        // TODO: Implement stuff in a delegate
        viewController.dismiss(animated: true)
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
        populateFields()
    }
}
