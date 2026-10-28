//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A view controller that allows looking up of addresses via a search term
/// and also allows manual input of an address.
///
/// Content only: it swaps between the search and the form in place,
/// and whoever presents it adds the navigation bar and the close or back button.
package class AddressLookupViewController: UIViewController, AdyenObserver {
    
    private enum Constants {
        static let transitionDuration: TimeInterval = 0.2
    }
    
    internal private(set) var viewModel: ViewModel
    
    /// The screen currently shown: the search or the form.
    internal private(set) var activeViewController: UIViewController?
    
    /// What the presenter put on the leading side of the navigation bar, like a close button when presented modally.
    /// Restored whenever the active screen has nothing of its own to show there.
    private var presenterLeadingItem: UIBarButtonItem?
    
    package init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override package func viewDidLoad() {
        super.viewDidLoad()
        
        presenterLeadingItem = navigationItem.leftBarButtonItem
        updateInterface(for: viewModel.interfaceState)
        observe(viewModel.$interfaceState) { [weak self] interfaceState in
            self?.updateInterface(for: interfaceState)
        }
    }
    
    @available(*, unavailable)
    package required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Controller Factory

private extension AddressLookupViewController {
    
    private func buildSearchViewController() -> SearchViewController {
        
        let searchViewController = AddressLookupSearchViewController(
            viewModel: viewModel.buildAddressSearchViewModel { [weak self] alert in
                // Alerts are always presented modally, they are never secondary screens.
                self?.present(alert, animated: true)
            }
        )
        
        // When the search is the first screen, cancelling it closes the whole address lookup.
        // Closing is the presenter's job (back or close button), so the search only keeps
        // its own "Cancel" when it goes back to the form.
        if viewModel.shouldDismissOnSearchDismissal {
            searchViewController.navigationItem.leftBarButtonItem = nil
        }
        
        return searchViewController
    }
    
    private func buildFormViewController(prefillAddress: PostalAddress?) -> AddressInputFormViewController {
        
        AddressInputFormViewController(
            viewModel: viewModel.buildAddressInputFormViewModel(with: prefillAddress)
        )
    }
}

// MARK: - Navigation

private extension AddressLookupViewController {
    
    func updateInterface(for interfaceState: AddressLookupViewController.InterfaceState) {
        switch interfaceState {
        case let .form(prefillAddress):
            show(viewController: buildFormViewController(prefillAddress: prefillAddress))
            
        case .search:
            show(viewController: buildSearchViewController())
        }
    }
    
    func show(viewController: UIViewController) {
        let previousViewController = activeViewController
        activeViewController = viewController
        
        previousViewController?.willMove(toParent: nil)
        addChild(viewController)
        
        UIView.transition(
            with: view,
            duration: Constants.transitionDuration,
            options: .transitionCrossDissolve
        ) {
            previousViewController?.view.removeFromSuperview()
            self.view.addSubview(viewController.view)
            viewController.view.adyen.anchor(inside: self.view)
        }
        
        previousViewController?.removeFromParent()
        viewController.didMove(toParent: self)
        
        updateNavigationItem(from: viewController)
    }
    
    /// Shows the active screen's title and buttons in the navigation bar of whoever presents this view controller.
    func updateNavigationItem(from viewController: UIViewController) {
        navigationItem.title = viewController.title
        navigationItem.rightBarButtonItem = viewController.navigationItem.rightBarButtonItem
        navigationItem.leftBarButtonItem = viewController.navigationItem.leftBarButtonItem ?? presenterLeadingItem
    }
}

extension AddressLookupViewController.ViewModel {
    
    internal func buildAddressInputFormViewModel(
        with prefillAddress: PostalAddress?
    ) -> AddressInputFormViewController.ViewModel {
        
        .init(
            for: addressType,
            style: style.form,
            theme: theme,
            localizationParameters: localizationParameters,
            initialCountry: initialCountry,
            prefillAddress: prefillAddress,
            supportedCountryCodes: supportedCountryCodes,
            handleShowSearch: handleShowSearchTapped(currentInput:),
            secondaryScreenPresenter: secondaryScreenPresenter,
            completionHandler: handleAddressInputFormCompletion(validAddress:)
        )
    }
    
    internal func buildAddressSearchViewModel(
        presentationHandler: @escaping (UIViewController) -> Void
    ) -> AddressLookupSearchViewController.ViewModel {
        
        .init(
            style: style.search,
            theme: theme,
            localizationParameters: localizationParameters,
            lookupProvider: lookupProvider,
            presentationHandler: presentationHandler,
            showFormHandler: handleShowForm(with:),
            switchToManualEntryHandler: handleSwitchToManualEntryTapped,
            cancellationHandler: handleDismissSearchTapped
        )
    }
}
