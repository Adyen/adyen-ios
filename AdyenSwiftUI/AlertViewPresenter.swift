//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI

extension View {
    func alertPresenter(presentationContext: InterruptionPresentationContext) -> some View {
        modifier(AlertViewPresenter(presentationContext: presentationContext))
    }
}

internal struct AlertViewPresenter: ViewModifier {

    @ObservedObject internal var presentationContext: InterruptionPresentationContext

    internal func body(content: Content) -> some View {
        return content.alert(item: $presentationContext.alertItemToShow) {
            if $0.primaryButton != nil {
                return Alert(title: $0.title, message: $0.message, primaryButton: $0.primaryButton!, secondaryButton: $0.dismissButton)
            } else {
                return Alert(title: $0.title, message: $0.message, dismissButton: $0.dismissButton)
            }
        }
    }
}
