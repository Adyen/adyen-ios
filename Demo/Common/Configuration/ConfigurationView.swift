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
    
    internal init(viewModel: ConfigurationViewModel) {
        self.viewModel = viewModel
    }
    
    internal var body: some View {
        NavigationView {
            Form {
                ForEach(ConfigurationSection.allCases, id: \.self, content: buildSection)
            }.navigationBarTitle("Configuration", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Default", action: viewModel.defaultTapped),
                trailing: Button("Save", action: viewModel.doneTapped)
            )
        }
    }
    
    private func buildSection(
        _ section: ConfigurationSection
    ) -> some View {
        Section(header: Text(section.rawValue.uppercased())) { getSectionView(section) }
    }
    
    @ViewBuilder
    private func getSectionView(_ section: ConfigurationSection) -> some View {
        switch section {
        case .apiVersion: apiVersionSection
        case .merchantAccount: merchantAccountSection
        case .region: regionSection
        case .payment: paymentSection
        }
    }
    
    private var apiVersionSection: some View {
        TextField(ConfigurationSection.apiVersion.rawValue, text: $viewModel.apiVersion)
                .keyboardType(.numberPad)
    }
    
    private var merchantAccountSection: some View {
        TextField(ConfigurationSection.merchantAccount.rawValue, text: $viewModel.merchantAccount)
    }
    
    private var regionSection: some View {
        Picker("Country code",
               selection: $viewModel.countryCode) {
            ForEach(ConfigurationViewModel.countries, id: \.self) { country in
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
private extension CountryDisplayInfo {
    var toListItemViewModel: ListItemView<String>.ViewModel<String> {
        ListItemView.ViewModel(title: code, subtitle: name, tag: code)
    }
}

@available(iOS 13.0.0, *)
private extension CurrencyDisplayInfo {
    var toListItemViewModel: ListItemView<String>.ViewModel<String> {
        ListItemView.ViewModel(title: code, subtitle: symbol, tag: code)
    }
}
