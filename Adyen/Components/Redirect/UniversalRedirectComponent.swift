//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Handles any redirect Url whether its a web url, an App custom scheme url, or an app universal link.
internal final class UniversalRedirectComponent: ActionComponent, DismissableComponent {
    
    /// :nodoc:
    internal weak var delegate: ActionComponentDelegate?
    
    /// :nodoc:
    internal var appLauncher: AnyAppLauncher = AppLauncher()
    
    /// :nodoc:
    private var redirectComponent: WebRedirectComponent?
    
    /// :nodoc:
    private let style: RedirectComponentStyle?
    
    /// :nodoc:
    private let componentName = "redirect"
    
    /// Initializes the component.
    ///
    /// - Parameter style: The component's UI style.
    internal init(style: RedirectComponentStyle? = nil) {
        self.style = style
    }
    
    /// This function should be invoked from the application's delegate when the application is opened through a URL.
    ///
    /// - Parameter url: The URL through which the application was opened.
    /// - Returns: A boolean value indicating whether the URL was handled by the redirect component.
    @discardableResult
    internal static func applicationDidOpen(from url: URL) -> Bool {
        WebRedirectComponent.applicationDidOpen(from: url)
    }
    
    /// Handles a redirect action.
    ///
    /// - Parameter action: The redirect action object.
    internal func handle(_ action: RedirectAction) {
        if action.url.isHttp {
            openHttpSchemeUrl(action)
        } else {
            openCustomSchemeUrl(action)
        }
    }
    
    /// :nodoc:
    internal func dismiss(_ animated: Bool, completion: (() -> Void)?) {
        redirectComponent?.viewController.dismiss(animated: animated, completion: completion)
    }
    
    // MARK: - Http link handling
    
    /// :nodoc:
    private func openHttpSchemeUrl(_ action: RedirectAction) {
        // Try to open as a universal app link, if it fails open the in-app browser.
        appLauncher.openUniversalAppUrl(action.url) { [weak self] success in
            guard let self = self else { return }
            if success {
                self.registerRedirectBounceBackListener(action)
                self.delegate?.didOpenExternalApplication(self)
            } else {
                self.openInAppBrowser(action)
            }
        }
    }
    
    /// :nodoc:
    private func openInAppBrowser(_ action: RedirectAction) {
        let component = WebRedirectComponent(url: action.url,
                                             paymentData: action.paymentData,
                                             style: style)
        component.delegate = self
        component._isDropIn = _isDropIn
        component.environment = environment
        redirectComponent = component
        
        UIViewController.findTopPresenter()?.present(component.viewController, animated: true)
    }
    
    // MARK: - Custom scheme link handling
    
    /// :nodoc:
    private func openCustomSchemeUrl(_ action: RedirectAction) {
        appLauncher.openCustomSchemeUrl(action.url) { [weak self] success in
            guard let self = self else { return }
            if success {
                self.registerRedirectBounceBackListener(action)
                self.delegate?.didOpenExternalApplication(self)
            } else {
                self.delegate?.didFail(with: RedirectComponent.Error.appNotFound, from: self)
            }
        }
    }
    
    // MARK: - Helpers
    
    /// :nodoc:
    private func registerRedirectBounceBackListener(_ action: RedirectAction) {
        RedirectListener.registerForURL { [weak self] returnURL in
            guard let self = self else { return }
            
            let additionalDetails = RedirectDetails(returnURL: returnURL)
            let actionData = ActionComponentData(details: additionalDetails, paymentData: action.paymentData)
            self.delegate?.didProvide(actionData, from: self)
        }
    }
    
}

/// :nodoc:
extension UniversalRedirectComponent: ActionComponentDelegate {
    
    /// :nodoc:
    public func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        delegate?.didProvide(data, from: self)
    }
    
    /// :nodoc:
    public func didFail(with error: Error, from component: ActionComponent) {
        delegate?.didFail(with: error, from: self)
    }
    
    /// :nodoc:
    public func didOpenExternalApplication(_ component: ActionComponent) {
        delegate?.didOpenExternalApplication(self)
    }
    
}
