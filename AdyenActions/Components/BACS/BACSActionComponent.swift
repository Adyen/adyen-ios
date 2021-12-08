//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking

/// A component that handles actions after paying with BACS direct debit.
public final class BACSActionComponent: ActionComponent, ShareableComponent {
    /// :nodoc:
    public let apiContext: APIContext
    
    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?
    
    /// Delegates `PresentableComponent`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?
    
    /// The Component UI style.
    public let style: BACSActionComponentStyle
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    internal let presenterViewController = UIViewController()
    
    /// :nodoc:
    internal var action: BACSAction?
    
    /// :nodoc:
    private let componentName = "bacsAction"
    
    public init(apiContext: APIContext, style: BACSActionComponentStyle) {
        self.apiContext = apiContext
        self.style = style
    }
    
    public func handle(_ action: BACSAction) {
        self.action = action
        
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, context: apiContext)
        
        let viewModel = BACSActionViewModel(message: localizedString(.bacsDownloadMandate, localizationParameters),
                                            imageName: "",
                                            buttonTitle: localizedString(.boletoDownloadPdf, localizationParameters))
        let view = BACSActionView(viewModel: viewModel, style: style)
        let viewController = ADYViewController(view: view)
        
        setUpPresenterViewController(parentViewController: viewController)

        if let presentationDelegate = presentationDelegate {
            let presentableComponent = PresentableComponentWrapper(component: self,
                                                                   viewController: viewController)
            presentationDelegate.present(component: presentableComponent)
        } else {
            AdyenAssertion.assertionFailure(
                message: "PresentationDelegate is nil. Provide a presentation delegate to VoucherComponent."
            )
        }
    }
}

extension BACSActionComponent: ActionViewDelegate {
    
    internal func didComplete() {
        delegate?.didComplete(from: self)
    }
    
    internal func mainButtonTap(sourceView: UIView) {
        guard let action = action else { return }
        presentSharePopover(with: action.downloadUrl, sourceView: sourceView)
    }
}
