//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import SafariServices
import UIKit

internal protocol BrowserComponentDelegate: AnyObject {
    func didCancel()
    func didOpenExternalApplication()
}

/// A component that opens a URL in web browsed and presents it.
internal final class BrowserComponent: NSObject, PresentableComponent {

    /// :nodoc
    internal let context: AdyenContext

    private let url: URL
    private let style: RedirectComponentStyle?
    private let componentName = "browser"

    internal lazy var viewController: UIViewController = {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.delegate = self
        safariViewController.modalPresentationStyle = style?.modalPresentationStyle ?? .formSheet
        safariViewController.presentationController?.delegate = self
        safariViewController.dismissButtonStyle = .cancel

        style.map {
            safariViewController.preferredBarTintColor = $0.preferredBarTintColor
            safariViewController.preferredControlTintColor = $0.preferredControlTintColor
        }

        return safariViewController
    }()
    
    internal weak var delegate: BrowserComponentDelegate?
    
    /// Initializes the component.
    ///
    /// - Parameter url: The URL to where the user should be redirected
    /// - Parameter context: The context object for this component.
    /// - Parameter style: The component's UI style.
    internal init(url: URL,
                  context: AdyenContext,
                  style: RedirectComponentStyle? = nil) {
        self.url = url
        self.context = context
        self.style = style
        super.init()
    }

    /// This allows us to assume one of the following scenarios:
    /// - SFSafariViewController deliberately closed by user and current app still in foreground;
    /// - SFSafariViewController finished due to a successful redirect to an external app and current app no longer in foreground.
    private func finish() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            if UIApplication.shared.applicationState == .active {
                self.delegate?.didCancel()
            } else {
                self.delegate?.didOpenExternalApplication()
            }
        }
    }

}

// MARK: - SFSafariViewControllerDelegate

extension BrowserComponent: SFSafariViewControllerDelegate, UIAdaptivePresentationControllerDelegate {
    
    /// Called when user clicks "Cancel" button or Safari redirects to other app.
    internal func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        finish()
    }

    /// Called when user drag VC down to dismiss.
    internal func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.delegate?.didCancel()
    }

}
