//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenSwiftUI
import SwiftUI

struct ComponentsView: View {

    @ObservedObject var viewModel = PaymentsViewModel()

    var body: some View {
        ZStack {
            NavigationView {
                List {
                    Toggle("Using Session", isOn: $viewModel.isUsingSession)
                        .accessibilityIdentifier("sessionSwitch")
                        .listRowBackground(Color.clear)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 5))
                    
                    ForEach(viewModel.items, id: \.self) { section in
                        Section {
                            ForEach(section, id: \.self) { item in
                                Button(action: {
                                    item.selectionHandler()
                                }, label: {
                                    Text(item.title)
                                        .frame(maxWidth: .infinity)
                                })
                            }
                        }
                    }
                }
                .disabled(viewModel.isLoading)
                .listStyle(.insetGrouped)
                .navigationBarTitle("Components")
                .navigationBarItems(trailing: configurationButton)
            }
            
            if viewModel.isLoading {
                loadingIndicator
            }
        }
        .ignoresSafeArea()
        .present(viewController: $viewModel.viewControllerToPresent)
        .onAppear {
            self.viewModel.viewDidAppear()
        }
    }
    
    private var loadingIndicator: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(.primary)
            .background(Color(UIColor.systemBackground).opacity(0.3))
    }

    private var configurationButton: some View {
        Button(action: viewModel.presentConfiguration, label: {
            Image(systemName: "gear")
        })
        .disabled(viewModel.isLoading)
    }
}

// swiftlint:disable:next type_name
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ComponentsView()
    }
}

extension EdgeInsets {
    static var zero: EdgeInsets {
        EdgeInsets(top: 0,
                   leading: 0,
                   bottom: 0,
                   trailing: 0)
    }
}
