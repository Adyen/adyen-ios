//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A component that presents a QR code.
internal final class QRCodeComponent: ActionComponent, Localizable {
    
    /// Delegates `ViewController`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?
    
    /// The component UI style.
    public let style: QRCodeComponentStyle

    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?
    
    /// :nodoc:
    public var action: QRCodeAction?
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    /// Initializes the `QRCodeComponent`.
    ///
    /// - Parameter style: The component UI style.
    public init(style: QRCodeComponentStyle = QRCodeComponentStyle()) {
        self.style = style
    }
    
    /// Handles QR code action.
    ///
    /// - Parameter action: The QR code action.
    public func handle(_ action: QRCodeAction) {
        self.action = action
        
        presentationDelegate?.present(
            component: PresentableComponentWrapper(
                component: self, viewController: createViewController(with: action))
        )
    }
    
    private func createViewController(with action: QRCodeAction) -> UIViewController {
        let view = QRCodeView(model: createModel(with: action))
        view.delegate = self
        return QRCodeViewController(qrCodeView: view)
    }
    
    private func createModel(with action: QRCodeAction) -> QRCodeView.Model {
        let url = LogoURLProvider.logoURL(withName: "pix", environment: .test)
        return QRCodeView.Model(
            instruction: ADYLocalizedString("adyen.pix.instructions", localizationParameters),
            logoUrl: url,
            style: QRCodeView.Model.Style(
                copyButton: style.copyButton,
                instructionLabel: style.instructionLabel,
                backgroundColor: style.backgroundColor
            )
        )
    }
}

extension QRCodeComponent: QRCodeViewDelegate {
    
    func copyToPasteboard() {
        UIPasteboard.general.string = action.map(\.qrCodeData)
    }
}
