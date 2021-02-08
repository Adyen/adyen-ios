//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import SwiftUI

internal struct ComponentsView: View {

    @ObservedObject internal var viewModel = PaymentsViewModel()

    internal var body: some View {
        List {
            ForEach(viewModel.items, id: \.self) { section in
                Section(content: {
                    ForEach(section, id: \.self) { item in
                        Button(action: {
                            item.selectionHandler?()
                        }, label: {
                            Text(item.title)
                                .frame(maxWidth: .infinity)
                        })
                    }

                })
            }.listRowInsets(.zero)
        }
        .listStyle(GroupedListStyle())
        .present(viewController: $viewModel.viewControllerToPresent)
        .onAppear {
            self.viewModel.viewDidAppear()
        }
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
