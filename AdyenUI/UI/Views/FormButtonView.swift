//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SwiftUI
import UIKit

package struct FormButtonView: View {

    package let title: String
    package let style: AdyenButtonStyle
    package let titleStyle: AdyenLabelStyle
    package let isEnabled: Bool
    package let showsActivityIndicator: Bool
    package let accessibilityIdentifier: String
    package let action: () -> Void

    /// Stores the configuration used to create and update the form button.
    package init(
        title: String,
        style: AdyenButtonStyle,
        titleStyle: AdyenLabelStyle,
        isEnabled: Bool,
        showsActivityIndicator: Bool,
        accessibilityIdentifier: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.titleStyle = titleStyle
        self.isEnabled = isEnabled
        self.showsActivityIndicator = showsActivityIndicator
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
    }

    package var body: some View {
        FormButtonBridge(
            title: title,
            style: style,
            titleStyle: titleStyle,
            showsActivityIndicator: showsActivityIndicator,
            accessibilityIdentifier: accessibilityIdentifier,
            action: action
        )
        .disabled(!isEnabled || showsActivityIndicator)
    }
}

private struct FormButtonBridge: UIViewRepresentable {

    let title: String
    let style: AdyenButtonStyle
    let titleStyle: AdyenLabelStyle
    let showsActivityIndicator: Bool
    let accessibilityIdentifier: String
    let action: () -> Void

    /// Creates the coordinator that forwards UIKit tap events.
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    /// Creates the UIKit form button and connects its tap handler.
    func makeUIView(context: Context) -> FormButton {
        let button = FormButton(buttonStyle: style, titleStyle: titleStyle)
        button.addTarget(context.coordinator, action: #selector(Coordinator.didTapButton), for: .touchUpInside)
        return button
    }

    /// Synchronizes the latest SwiftUI state with the UIKit form button.
    func updateUIView(_ button: FormButton, context: Context) {
        context.coordinator.action = action
        button.title = title
        button.showsActivityIndicator = showsActivityIndicator
        button.isEnabled = context.environment.isEnabled && !showsActivityIndicator
        button.accessibilityIdentifier = accessibilityIdentifier
    }

    final class Coordinator: NSObject {
        var action: () -> Void

        /// Stores the action invoked when the button is tapped.
        init(action: @escaping () -> Void) {
            self.action = action
        }

        /// Forwards the UIKit tap event to the configured action.
        @objc func didTapButton() {
            action()
        }
    }
}
