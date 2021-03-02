//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import SafariServices
import UIKit

internal protocol BrowserComponentDelegate: AnyObject {
    func didCancel()
}

/// A component that opens a URL in web browsed and presents it.
internal final class BrowserComponent: NSObject, PresentableComponent {

    private let url: URL
    private let style: RedirectComponentStyle?
    private let componentName = "browser"

    internal lazy var viewController: UIViewController = {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.delegate = self
        safariViewController.modalPresentationStyle = style?.modalPresentationStyle ?? .formSheet
        safariViewController.presentationController?.delegate = self

        style.map {
            safariViewController.preferredBarTintColor = $0.preferredBarTintColor
            safariViewController.preferredControlTintColor = $0.preferredControlTintColor
        }

        if #available(iOS 11, *) {
            safariViewController.dismissButtonStyle = .cancel
        }

        return safariViewController
    }()
    
    /// :nodoc:
    internal weak var delegate: BrowserComponentDelegate?
    
    /// Initializes the component.
    ///
    /// - Parameter url: The URL to where the user should be redirected
    /// - Parameter style: The component's UI style.
    internal init(url: URL, style: RedirectComponentStyle? = nil) {
        self.url = url
        self.style = style
        super.init()
    }

}

// MARK: - SFSafariViewControllerDelegate

extension BrowserComponent: SFSafariViewControllerDelegate {
    
    /// Called when user clicks "Cancel" button.
    /// :nodoc:
    internal func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        delegate?.didCancel()
    }
    
}

extension BrowserComponent: UIAdaptivePresentationControllerDelegate {

    /// Called when user drag VC down to dismiss.
    /// :nodoc:
    internal func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.didCancel()
    }

}
