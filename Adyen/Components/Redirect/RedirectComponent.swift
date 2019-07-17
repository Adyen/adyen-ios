//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import SafariServices
import UIKit

/// A component that handles a redirect action.
public final class RedirectComponent: NSObject, PresentableComponent, ActionComponent {
    
    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?
    
    /// Initializes the component.
    ///
    /// - Parameter url: The URL to where the user should be redirected.
    /// - Parameter paymentData: The payment data returned by the server.
    public init(url: URL, paymentData: String) {
        self.url = url
        self.paymentData = paymentData
        
        super.init()
    }
    
    /// Initializes the component.
    ///
    /// - Parameter action: The redirect action to perform.
    public convenience init(action: RedirectAction) {
        self.init(url: action.url, paymentData: action.paymentData)
    }
    
    // MARK: - Returning From a Redirect
    
    /// This function should be invoked from the application's delegate when the application is opened through a URL.
    ///
    /// - Parameter url: The URL through which the application was opened.
    /// - Returns: A boolean value indicating whether the URL was handled by the redirect component.
    @discardableResult
    public static func applicationDidOpen(from url: URL) -> Bool {
        return RedirectListener.applicationDidOpen(from: url)
    }
    
    // MARK: - Presentable Component
    
    /// :nodoc:
    public lazy var viewController: UIViewController = {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, environment: environment)
        
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.delegate = self
        safariViewController.modalPresentationStyle = .formSheet
        
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
    
    /// :nodoc:
    public var preferredPresentationMode: PresentableComponentPresentationMode {
        return .present
    }
    
    // MARK: - Private
    
    private let componentName = "redirect"
    
    /// The URL to where the user should be redirected.
    private let url: URL
    
    /// The Payment Data returned by the server.
    private let paymentData: String
    
}

// MARK: - SFSafariViewControllerDelegate

extension RedirectComponent: SFSafariViewControllerDelegate {
    
    /// :nodoc:
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        delegate?.didFail(with: ComponentError.cancelled, from: self)
    }
    
}
