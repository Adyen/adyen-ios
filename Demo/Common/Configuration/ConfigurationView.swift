//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI
import Adyen

@available(iOS 13.0.0, *)
internal struct ConfigurationView: View {
    
    private enum ConfigurationSection: String, CaseIterable {
        case apiVersion = "Api Version"
        case merchantAccount = "Merchant Account"
        case region = "Region"
        case payment = "Payment"
    }
    
    @ObservedObject internal var viewModel: ConfigurationViewModel
    @State private var countrySearchSting: String = ""
    private var filteredCountries: [CountryDisplayInfo] {
        if countrySearchSting.isEmpty {
            return ConfigurationViewModel.countries
        } else {
            return ConfigurationViewModel.countries.filter { $0.matches(countrySearchSting) }
        }
    }
    
    internal init(viewModel: ConfigurationViewModel) {
        self.viewModel = viewModel
    }
    
    internal var body: some View {
        NavigationView {
            Form {
                wrapInSection(view: apiVersionSection, section: .apiVersion)
                wrapInSection(view: merchantAccountSection, section: .merchantAccount)
                wrapInSection(view: regionSection, section: .region)
                wrapInSection(view: paymentSection, section: .payment)
            }.navigationBarTitle("Configuration", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Default", action: viewModel.defaultTapped),
                trailing: Button("Save", action: viewModel.doneTapped)
            )
        }.onAppear {
            countrySearchSting = ""
        }
    }
    
    private func wrapInSection<T: View>(
        view: T,
        section: ConfigurationSection
    ) -> some View {
        Section(header: Text(section.rawValue.uppercased())) { view }
    }
    
    private var apiVersionSection: some View {
        TextField(ConfigurationSection.apiVersion.rawValue, text: $viewModel.apiVersion)
                .keyboardType(.numberPad)
    }
    
    private var merchantAccountSection: some View {
        TextField(ConfigurationSection.merchantAccount.rawValue, text: $viewModel.merchantAccount)
    }
    
    private var regionSection: some View {
        let selectionBinding = Binding(
            get: { viewModel.countryCode },
            set: { newValue in
                viewModel.countryCode = newValue
                countrySearchSting = ""
            }
        )
        
        return Picker("Country code",
               selection: selectionBinding) {
            SearchBar(searchString: $countrySearchSting, placeholder: "Search Countries")
            ForEach(filteredCountries, id: \.self) { country in
                ListItemView(viewModel: country.toListItemViewModel)
            }
        }
    }
    
    private var paymentSection: some View {
        Group {
            Picker("Currency code", selection: $viewModel.currencyCode) {
                ForEach(ConfigurationViewModel.currencies, id: \.self) { currency in
                    ListItemView(viewModel: currency.toListItemViewModel)
                }
            }
            TextField("Amount", text: $viewModel.value)
                .keyboardType(.numberPad)
        }
    }
    
}

@available(iOS 13.0.0, *)
private struct ListItemView<T: Hashable>: View {
    let viewModel: ViewModel<T>
    
    var body: some View {
        HStack {
            Text(viewModel.title).foregroundColor(Color(UIColor.label))
            Text(viewModel.subtitle).foregroundColor(Color(UIColor.secondaryLabel))
        }.tag(viewModel.tag)
    }
    
    fileprivate struct ViewModel<T: Hashable> {
        let title: String
        let subtitle: String
        let tag: T
    }
}

@available(iOS 13.0.0, *)
extension CountryDisplayInfo {
    fileprivate var toListItemViewModel: ListItemView<String>.ViewModel<String> {
        ListItemView.ViewModel(
            title: "\(code) \(emojiFlag(regionCode: code))",
            subtitle: name,
            tag: code
        )
    }
    
    internal func matches(_ predicate: String) -> Bool {
        code.range(of: predicate, options: [.anchored, .caseInsensitive]) != nil ||
            name.range(of: predicate, options: [.anchored, .caseInsensitive]) != nil
    }
    
    private func emojiFlag(regionCode: String) -> String {
        regionCode.unicodeScalars
            .compactMap { UnicodeScalar(127397 + $0.value) }
            .map(String.init)
            .joined()
    }
}

@available(iOS 13.0.0, *)
extension CurrencyDisplayInfo {
    fileprivate var toListItemViewModel: ListItemView<String>.ViewModel<String> {
        ListItemView.ViewModel(title: code, subtitle: symbol, tag: code)
    }
}
