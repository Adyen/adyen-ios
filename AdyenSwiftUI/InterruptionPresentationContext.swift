//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Combine
import Network
import SwiftUI

internal struct AlertItem: Identifiable {
    // swiftlint:disable:next identifier_name
    internal let id = UUID()
    internal let title: Text
    internal let message: Text?
    internal let primaryButton: Alert.Button?
    internal let dismissButton: Alert.Button
}

internal final class InterruptionPresentationContext: ObservableObject, Identifiable {

    internal var alertItem: Binding<AlertItem?>

    @Published internal var alertItemToShow: AlertItem?

    internal init() {
        alertItem = Binding(get: { nil }, set: { _ in })
        alertItem = Binding(get: { self.alertItemToShow }, set: { [weak self] in
            guard let self = self else { return }
            if let newValue = $0 {
                guard self.alertItemToShow == nil else { return }
                self.alertItemToShow = newValue
            } else {
                self.alertItemToShow = nil
            }
        })
    }
}
