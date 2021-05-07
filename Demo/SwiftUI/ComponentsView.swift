//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenSwiftUI
import SwiftUI

internal struct ComponentsView: View {

    @ObservedObject internal var viewModel = PaymentsViewModel()

    internal var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.items, id: \.self) { section in
                    Section(content: {
                        ForEach(section, id: \.self) { item in
                            Button(action: {
                                item.selectionHandler()
                            }, label: {
                                Text(item.title)
                                    .frame(maxWidth: .infinity)
                            })
                        }

                    })
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Components")
            .navigationBarItems(trailing: configurationButton)
            .present(viewController: $viewModel.viewControllerToPresent)
            .onAppear {
                self.viewModel.viewDidAppear()
            }
        }
    }

    private var configurationButton: some View {
        Button(action: viewModel.presentConfiguration, label: {
            Image(systemName: "gear")
        })
    }
}

// swiftlint:disable:next type_name
internal struct ContentView_Previews: PreviewProvider {
    internal static var previews: some View {
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
