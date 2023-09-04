//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import UIKit

/// A component that handles document actions.
public final class DocumentComponent: ActionComponent, ShareableComponent {
    /// :nodoc:
    public let apiContext: APIContext
    
    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?
    
    /// Delegates `PresentableComponent`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?
    
    /// The Component UI style.
    public let style: DocumentComponentStyle
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    internal let presenterViewController = UIViewController()
    
    /// :nodoc:
    internal var action: DocumentAction?
    
    /// :nodoc:
    private let componentName = "documentAction"
    
    /// Initializes the `DocumentComponent`.
    ///
    /// - Parameter apiContext: The API context.
    /// - Parameter style: The Component UI style.
    public init(apiContext: APIContext, style: DocumentComponentStyle) {
        self.apiContext = apiContext
        self.style = style
    }
    
    /// Handles document action.
    ///
    /// - Parameter action: The document action object.
    public func handle(_ action: DocumentAction) {
        self.action = action
        
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, context: apiContext)
        
        let imageURL = LogoURLProvider.logoURL(withName: action.paymentMethodType.rawValue,
                                               environment: apiContext.environment,
                                               size: .medium)
        let viewModel = DocumentActionViewModel(message: localizedString(.bacsDownloadMandate, localizationParameters),
                                                logoURL: imageURL,
                                                buttonTitle: localizedString(.boletoDownloadPdf, localizationParameters))
        let view = DocumentActionView(viewModel: viewModel, style: style)
        view.delegate = self
        let viewController = ADYViewController(view: view)
        
        setUpPresenterViewController(parentViewController: viewController)

        if let presentationDelegate {
            let presentableComponent = PresentableComponentWrapper(component: self,
                                                                   viewController: viewController, navBarType: navBarType())
            presentationDelegate.present(component: presentableComponent)
        } else {
            AdyenAssertion.assertionFailure(
                message: "PresentationDelegate is nil. Provide a presentation delegate to DocumentComponent."
            )
        }
    }
    
    private func navBarType() -> NavigationBarType {
        let model = ActionNavigationBar.Model(leadingButtonTitle: nil,
                                              trailingButtonTitle: Bundle.Adyen.localizedDoneCopy)
        let style = ActionNavigationBar.Style(leadingButton: nil,
                                              trailingButton: style.doneButton,
                                              backgroundColor: style.backgroundColor)
        
        let navBar = ActionNavigationBar(model: model, style: style)
        navBar.trailingButtonHandler = { [weak self] in
            self.map { $0.delegate?.didComplete(from: $0) }
        }
        return .custom(navBar)
    }
}

extension DocumentComponent: ActionViewDelegate {
    
    internal func didComplete() {
        delegate?.didComplete(from: self)
    }
    
    internal func mainButtonTap(sourceView: UIView) {
        guard let action else { return }
        presentSharePopover(with: action.downloadUrl, sourceView: sourceView)
    }
}
