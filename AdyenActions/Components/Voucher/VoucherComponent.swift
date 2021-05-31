//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A component that handles voucher action's.
internal protocol AnyVoucherActionHandler: ActionComponent {
    func handle(_ action: VoucherAction)
}

/// A component that handles voucher action's.
public final class VoucherComponent: AnyVoucherActionHandler {
    
    /// :nodoc:
    public let apiContext: APIContext

    /// Delegates `PresentableComponent`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?

    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?

    /// :nodoc:
    public let requiresModalPresentation: Bool = true

    /// The Component UI style.
    public let style: VoucherComponentStyle

    /// :nodoc:
    public var localizationParameters: LocalizationParameters?

    /// :nodoc:
    private var voucherViewControllerProvider: AnyVoucherViewControllerProvider?

    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter apiContext: The API context.
    /// - Parameter style: The Component UI style.
    public init(apiContext: APIContext, style: VoucherComponentStyle?) {
        self.apiContext = apiContext
        self.style = style ?? VoucherComponentStyle()
    }

    /// Initializes the `AwaitComponent`.
    /// - Parameter apiContext: The API context.
    /// - Parameter awaitComponentBuilder: The payment method specific await action handler provider.
    /// - Parameter style: The Component UI style.
    internal convenience init(apiContext: APIContext,
                              voucherViewControllerProvider: AnyVoucherViewControllerProvider?,
                              style: VoucherComponentStyle? = nil) {
        self.init(apiContext: apiContext, style: style)
        self.voucherViewControllerProvider = voucherViewControllerProvider
    }

    /// :nodoc:
    private let componentName = "voucher"

    /// Handles await action.
    ///
    /// - Parameter action: The await action object.
    public func handle(_ action: VoucherAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, context: apiContext)

        var viewControllerProvider = voucherViewControllerProvider
            ?? VoucherViewControllerProvider(style: style, environment: apiContext.environment)
        viewControllerProvider.localizationParameters = localizationParameters
        viewControllerProvider.delegate = self

        let viewController = viewControllerProvider.provide(with: action)

        if let presentationDelegate = presentationDelegate {
            let presentableComponent = PresentableComponentWrapper(component: self, viewController: viewController)
            presentationDelegate.present(component: presentableComponent)
        } else {
            let message = "PresentationDelegate is nil. Provide a presentation delegate to VoucherAction."
            AdyenAssertion.assertionFailure(message: message)
        }
    }

}

/// :nodoc:
extension VoucherComponent: VoucherViewDelegate {
    
    internal func didComplete(presentingViewController: UIViewController) {
        delegate?.didComplete(from: self)
    }

    internal func saveAsImage(voucherView: UIView, presentingViewController: UIViewController) {
        guard let image = voucherView.adyen.snapShot() else { return }
        
        presentSharePopover(
            with: image,
            presentingViewController: presentingViewController,
            sourceView: voucherView
        )
    }
    
    internal func download(url: URL, voucherView: UIView, presentingViewController: UIViewController) {
        presentSharePopover(
            with: url,
            presentingViewController: presentingViewController,
            sourceView: voucherView
        )
    }

    internal func addToAppleWallet(action: OpaqueEncodable, presentingViewController: UIViewController) {}
    
    private func presentSharePopover(
        with item: Any,
        presentingViewController: UIViewController,
        sourceView: UIView
    ) {
        let activityViewController = UIActivityViewController(
            activityItems: [item],
            applicationActivities: nil
        )
        activityViewController.popoverPresentationController?.sourceView = sourceView
        presentingViewController.present(activityViewController, animated: true, completion: nil)
    }
}
