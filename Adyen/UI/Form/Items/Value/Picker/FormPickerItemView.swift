//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

internal class FormPickerItemView<ValueType: Equatable>: FormSelectableValueItemView<ValueType, FormPickerItem<ValueType>> {
    
    private var shouldBecomeFirstResponder: Bool = false
    
    private var viewController: UIViewController? {
        window?.rootViewController?.adyen.topPresenter
    }
    
    internal required init(item: FormPickerItem<ValueType>) {
        super.init(item: item)
        item.selectionHandler = { [weak self] in
            
            let viewModel = AddressLookupViewController.ViewModel(
                style: FormComponentStyle(),
                localizationParameters: nil,
                supportedCountryCodes: ["NL"],
                initialCountry: "NL",
                prefillAddress: nil,
                lookupProvider: { searchTerm, handler in handler([.init(city: searchTerm)]) }
            ) { [weak self] address in
                guard let self else { return }
                print(address)
                self.viewController?.dismiss(animated: true)
            }
            
            let searchViewController = AddressLookupViewController(viewModel: viewModel)
            
            self?.viewController?.present(searchViewController, animated: true)
        }
    }
    
    override internal func reset() {
        item.resetValue()
        resetValidationStatus()
    }
}
