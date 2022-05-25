//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import UIKit

/// A component that handles document actions.
public final class DocumentComponent: ActionComponent, ShareableComponent {

    /// The context object for this component.
    @_spi(AdyenInternal)
    public let context: AdyenContext
    
    public weak var delegate: ActionComponentDelegate?
    
    /// Delegates `PresentableComponent`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?
    
    /// The document component configurations.
    public struct Configuration {
        
        /// The component UI style.
        public var style: DocumentComponentStyle
        
        /// The localization parameters, leave it nil to use the default parameters.
        public var localizationParameters: LocalizationParameters?
        
        /// Initializes an instance of `Configuration`
        ///
        /// - Parameters:
        ///   - style: The Component UI style.
        ///   - localizationParameters: The localization parameters, leave it nil to use the default parameters.
        public init(style: DocumentComponentStyle = DocumentComponentStyle(), localizationParameters: LocalizationParameters? = nil) {
            self.style = style
            self.localizationParameters = localizationParameters
        }
    }
    
    /// The document component configurations.
    public var configuration: Configuration = .init()
    
    internal let presenterViewController = UIViewController()
    
    private let componentName = "documentAction"
    
    /// Initializes the `DocumentComponent`.
    ///
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The Component configurations.
    public init(context: AdyenContext,
                configuration: Configuration = .init()) {
        self.context = context
        self.configuration = configuration
    }
    
    /// Handles document action.
    ///
    /// - Parameter action: The document action object.
    public func handle(_ action: DocumentAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, context: context.apiContext)
        
        let imageURL = LogoURLProvider.logoURL(withName: action.paymentMethodType.rawValue,
                                               environment: context.apiContext.environment,
                                               size: .medium)
        let viewModel = DocumentActionViewModel(action: action,
                                                message: localizedString(.bacsDownloadMandate, configuration.localizationParameters),
                                                logoURL: imageURL,
                                                buttonTitle: localizedString(.boletoDownloadPdf, configuration.localizationParameters))
        let view = DocumentActionView(viewModel: viewModel, style: configuration.style)
        view.delegate = self
        let viewController = ADYViewController(view: view)
        
        setUpPresenterViewController(parentViewController: viewController)

        if let presentationDelegate = presentationDelegate {
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
                                              trailingButton: configuration.style.doneButton,
                                              backgroundColor: configuration.style.backgroundColor)
        
        let navBar = ActionNavigationBar(model: model, style: style)
        navBar.trailingButtonHandler = { [weak self] in
            self.map { $0.delegate?.didComplete(from: $0) }
        }
        return .custom(navBar)
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
