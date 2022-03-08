//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

extension RedirectComponent: AnyRedirectComponent {}

/// Handles any redirect Url whether its a web url, an App custom scheme url, or an app universal link.
public final class RedirectComponent: ActionComponent {
    
    /// Describes the types of errors that can be returned by the component.
    public enum Error: Swift.Error {
        
        /// Indicates that no app is installed that can handle the payment.
        case appNotFound
        
    }
    
    /// The component configurations.
    public struct Configuration {
        
        /// The component's UI style.
        public var style: RedirectComponentStyle?
        
        fileprivate let componentName = "redirect"
        
        /// Initializes an instance of `Configuration`
        ///
        /// - Parameter style: The component's UI style.
        public init(style: RedirectComponentStyle? = nil) {
            self.style = style
        }
    }
    
    /// :nodoc:
    public let apiContext: APIContext

    /// The Adyen context.
    public let adyenContext: AdyenContext
    
    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?

    /// Delegates `PresentableComponent`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?
    
    /// :nodoc:
    internal var appLauncher: AnyAppLauncher = AppLauncher()
    private var browserComponent: BrowserComponent?
    
    /// The component configurations.
    public var configuration: Configuration
    
    /// Initializes the component.
    ///
    /// - Parameter apiContext: The API context.
    /// - Parameter adyenContext: The Adyen context
    /// - Parameter configuration: The component configurations.
    public init(apiContext: APIContext,
                adyenContext: AdyenContext,
                configuration: Configuration = Configuration()) {
        self.apiContext = apiContext
        self.adyenContext = adyenContext
        self.configuration = configuration
    }
    
    /// Handles a redirect action.
    ///
    /// - Parameter action: The redirect action object.
    public func handle(_ action: RedirectAction) {
        Analytics.sendEvent(component: configuration.componentName,
                            flavor: _isDropIn ? .dropin : .components,
                            context: apiContext)
        
        if action.url.adyen.isHttp {
            openHttpSchemeUrl(action)
        } else {
            openCustomSchemeUrl(action)
        }
    }

    // MARK: - Returning From a Redirect

    /// This function should be invoked from the application's delegate when the application is opened through a URL.
    ///
    /// - Parameter url: The URL through which the application was opened.
    /// - Returns: A boolean value indicating whether the URL was handled by the redirect component.
    @discardableResult
    public static func applicationDidOpen(from url: URL) -> Bool {
        RedirectListener.applicationDidOpen(from: url)
    }
    
    // MARK: - Http link handling

    private func openHttpSchemeUrl(_ action: RedirectAction) {
        // Try to open as a universal app link, if it fails open the in-app browser.
        appLauncher.openUniversalAppUrl(action.url) { [weak self] success in
            guard let self = self else { return }
            self.registerRedirectBounceBackListener(action)
            if success {
                self.delegate?.didOpenExternalApplication(self)
            } else {
                self.openInAppBrowser(action)
            }
        }
    }

    private func openInAppBrowser(_ action: RedirectAction) {
        let component = BrowserComponent(url: action.url,
                                         apiContext: apiContext,
                                         style: configuration.style)
        component.delegate = self
        browserComponent = component
        presentationDelegate?.present(component: component)
    }
    
    // MARK: - Custom scheme link handling

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

    private func registerRedirectBounceBackListener(_ action: RedirectAction) {
        RedirectListener.registerForURL { [weak self] returnURL in
            guard let self = self else { return }
            
            let additionalDetails = RedirectDetails(returnURL: returnURL)
            let actionData = ActionComponentData(details: additionalDetails, paymentData: action.paymentData)
            self.delegate?.didProvide(actionData, from: self)
        }
    }
    
}

extension RedirectComponent: BrowserComponentDelegate {

    /// :nodoc:
    internal func didCancel() {
        if browserComponent != nil {
            browserComponent = nil
            delegate?.didFail(with: ComponentError.cancelled, from: self)
        }
    }

    /// :nodoc:
    internal func didOpenExternalApplication() {
        delegate?.didOpenExternalApplication(self)
    }
    
}

/// :nodoc:
extension RedirectComponent: ActionComponentDelegate {
    
    /// :nodoc:
    public func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        delegate?.didProvide(data, from: self)
    }

    /// :nodoc:
    public func didComplete(from component: ActionComponent) {
        delegate?.didComplete(from: self)
    }
    
    /// :nodoc:
    public func didFail(with error: Swift.Error, from component: ActionComponent) {
        delegate?.didFail(with: error, from: self)
    }
    
    /// :nodoc:
    public func didOpenExternalApplication(_ component: ActionComponent) {
        delegate?.didOpenExternalApplication(self)
    }
    
}
