//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey
import AdyenNetworking
#if canImport(AdyenUI)
    import AdyenUI
#endif
import UIKit

/// A component that handles document actions.
@MainActor
package final class DocumentComponent: ActionComponent, ShareableComponent {

    /// The context object for this component.
    package let context: AdyenContext

    package weak var delegate: ActionComponentDelegate?

    /// Delegates `PresentableComponent`'s presentation.
    package weak var presentationDelegate: PresentationDelegate?

    /// The document component configurations.
    package struct Configuration {
        
        /// The component UI style.
        package var style: DocumentComponentStyle
        
        /// The localization parameters, leave it nil to use the default parameters.
        package var localizationParameters: LocalizationParameters?
        
        package init(style: DocumentComponentStyle = DocumentComponentStyle()) {
            self.init(style: style, localizationParameters: nil)
        }

        package init(style: DocumentComponentStyle = DocumentComponentStyle(), localizationParameters: LocalizationParameters? = nil) {
            self.style = style
            self.localizationParameters = localizationParameters
        }
    }
    
    /// The document component configurations.
    package var configuration: Configuration = .init()

    internal let presenterViewController = UIViewController()
    
    private let componentName = "documentAction"
    
    /// Initializes the `DocumentComponent`.
    ///
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The Component configurations.
    package init(
        context: AdyenContext,
        configuration: Configuration = .init()
    ) {
        self.context = context
        self.configuration = configuration
    }
    
    /// Handles document action.
    ///
    /// - Parameter action: The document action object.
    package func handle(_ action: DocumentAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, context: context.apiContext)
        
        let imageURL = LogoURLProvider.logoURL(
            withName: action.paymentMethodType.rawValue,
            environment: context.apiContext.environment,
            size: .medium
        )
        let viewModel = DocumentActionViewModel(
            action: action,
            message: localizedString(.bacsDownloadMandate, configuration.localizationParameters),
            logoURL: imageURL,
            buttonTitle: localizedString(.boletoDownloadPdf, configuration.localizationParameters)
        )
        let view = DocumentActionView(viewModel: viewModel, style: configuration.style)
        view.delegate = self
        let viewController = ActionViewController(view: view)
        
        setUpPresenterViewController(parentViewController: viewController)

        if let presentationDelegate {
            presentationDelegate.present(viewController: viewController)
        } else {
            AdyenAssertion.assertionFailure(
                message: "PresentationDelegate is nil. Provide a presentation delegate to DocumentComponent."
            )
        }
    }
}

extension DocumentComponent: DocumentActionViewDelegate {
    
    internal func didComplete() {
        delegate?.didComplete(from: self)
    }
    
    internal func mainButtonTap(sourceView: UIView, downloadable: Downloadable) {
        presentSharePopover(with: downloadable.downloadUrl, sourceView: sourceView)
    }
}
