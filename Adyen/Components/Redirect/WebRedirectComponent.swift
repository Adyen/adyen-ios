//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import SafariServices
import UIKit

/// A component that handles a redirect action, but only supports http(s) links and opens them in in-app browser.
internal final class WebRedirectComponent: NSObject, PresentableComponent, ActionComponent {
    
    /// :nodoc:
    internal weak var delegate: ActionComponentDelegate?
    
    /// Indicates the component's UI style.
    private let style: RedirectComponentStyle?
    
    /// Initializes the component.
    ///
    /// - Parameter url: The URL to where the user should be redirected.
    /// - Parameter paymentData: The payment data returned by the server.
    /// - Parameter style: The component's UI style.
    internal init(url: URL, paymentData: String, style: RedirectComponentStyle? = nil) {
        self.url = url
        self.paymentData = paymentData
        self.style = style
        
        super.init()
    }
    
    /// Initializes the component.
    ///
    /// - Parameter action: The redirect action to perform.
    /// - Parameter style: The component's UI style.
    internal convenience init(action: RedirectAction, style: RedirectComponentStyle? = nil) {
        self.init(url: action.url, paymentData: action.paymentData, style: style)
    }
    
    // MARK: - Returning From a Redirect
    
    /// This function should be invoked from the application's delegate when the application is opened through a URL.
    ///
    /// - Parameter url: The URL through which the application was opened.
    /// - Returns: A boolean value indicating whether the URL was handled by the redirect component.
    @discardableResult
    internal static func applicationDidOpen(from url: URL) -> Bool {
        return RedirectListener.applicationDidOpen(from: url)
    }
    
    // MARK: - Presentable Component
    
    /// :nodoc:
    internal lazy var viewController: UIViewController = {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.delegate = self
        safariViewController.modalPresentationStyle = .formSheet
        
        style.map {
            safariViewController.preferredBarTintColor = $0.preferredBarTintColor
            safariViewController.preferredControlTintColor = $0.preferredControlTintColor
        }
        
        if #available(iOS 11, *) {
            safariViewController.dismissButtonStyle = .cancel
        }
        
        RedirectListener.registerForURL { [weak self] returnURL in
            guard let self = self else { return }
            
            let additionalDetails = RedirectDetails(returnURL: returnURL)
            self.delegate?.didProvide(ActionComponentData(details: additionalDetails, paymentData: self.paymentData), from: self)
        }
        
        return safariViewController
    }()
    
    // MARK: - Private
    
    /// The URL to where the user should be redirected.
    private let url: URL
    
    /// The Payment Data returned by the server.
    private let paymentData: String
    
}

// MARK: - SFSafariViewControllerDelegate

extension WebRedirectComponent: SFSafariViewControllerDelegate {
    
    /// :nodoc:
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        delegate?.didFail(with: ComponentError.cancelled, from: self)
    }
    
}
