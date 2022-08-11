//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import UIKit

extension RedirectComponent: AnyRedirectComponent {}

/// Handles any redirect Url whether its a web url, an App custom scheme url, or an app universal link.
public final class RedirectComponent: ActionComponent {
    
    /// Describes the types of errors that can be returned by the component.
    public enum Error: LocalizedError {
        
        /// Indicates that no app is installed that can handle the payment.
        case appNotFound
        
        /// Indicates that invalid parameters are passed back from the issuer.
        case invalidRedirectParameters
        
        public var errorDescription: String? {
            switch self {
            case .appNotFound:
                return "No app installed that can handle the payment."
            case .invalidRedirectParameters:
                return "Query parameters returned by the issuer is invalid or empty ."
            }
        }
        
    }
    
    /// :nodoc:
    public let apiContext: APIContext
    
    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?
    
    /// Delegates `PresentableComponent`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?
    
    /// :nodoc:
    internal var appLauncher: AnyAppLauncher = AppLauncher()
    
    internal lazy var apiClient: AnyRetryAPIClient = {
        APIClient(apiContext: apiContext).retryAPIClient(with: SimpleScheduler(maximumCount: 2))
    }()
    
    private var browserComponent: BrowserComponent?
    
    private let style: RedirectComponentStyle?
    
    private let componentName = "redirect"
    
    /// Initializes the component.
    ///
    /// - Parameter apiContext: The API context.
    /// - Parameter style: The component's UI style.
    public init(apiContext: APIContext,
                style: RedirectComponentStyle? = nil) {
        self.apiContext = apiContext
        self.style = style
    }
    
    internal convenience init(apiContext: APIContext,
                              style: RedirectComponentStyle? = nil,
                              apiClient: AnyRetryAPIClient) {
        self.init(apiContext: apiContext, style: style)
        self.apiClient = apiClient
    }
    
    /// Handles a redirect action.
    ///
    /// - Parameter action: The redirect action object.
    public func handle(_ action: RedirectAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, context: apiContext)
        
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
        let component = BrowserComponent(url: action.url, apiContext: apiContext, style: style)
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
            
            self.didOpen(url: returnURL, action)
        }
    }
    
    private func didOpen(url returnURL: URL, _ action: RedirectAction) {
        if let redirectStateData = action.nativeRedirectData {
            handleNativeMobileRedirect(withReturnURL: returnURL, redirectStateData: redirectStateData, action)
        } else {
            do {
                notifyDelegateDidProvide(redirectDetails: try RedirectDetails(returnURL: returnURL), action)
            } catch {
                delegate?.didFail(with: error, from: self)
            }
        }
    }
    
    private func handleNativeMobileRedirect(withReturnURL returnURL: URL, redirectStateData: String, _ action: RedirectAction) {
        guard let queryString = returnURL.query else {
            delegate?.didFail(with: Error.invalidRedirectParameters, from: self)
            return
        }
        let request = NativeRedirectResultRequest(redirectData: redirectStateData,
                                                  returnQueryString: queryString)
        apiClient.perform(request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                self.delegate?.didFail(with: error, from: self)
            case let .success(response):
                self.notifyDelegateDidProvide(redirectDetails: response, action)
            }
        }
    }
    
    private func notifyDelegateDidProvide(redirectDetails: RedirectDetails, _ action: RedirectAction) {
        let actionData = ActionComponentData(details: redirectDetails, paymentData: action.paymentData)
        delegate?.didProvide(actionData, from: self)
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
