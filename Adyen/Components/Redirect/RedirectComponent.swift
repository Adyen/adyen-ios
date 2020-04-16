//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A component that handles a redirect action. Supports external websites, apps and universal links.
public final class RedirectComponent: ActionComponent {
    
    /// Describes the types of errors that can be returned by the component.
    public enum Error: Swift.Error {
        
        /// Indicates that no app is installed that can handle the payment.
        case appNotFound
        
    }
    
    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?
    
    /// The view controller to use to present the in-app browser incase the redirect is a non native app redirect.
    public var presentingViewController: UIViewController? {
        
        get {
            universalRedirectComponent.presentingViewController
        }
        
        set {
            universalRedirectComponent.presentingViewController = newValue
        }
        
    }
    
    /// Initializes the component.
    ///
    /// - Parameter style: The component's UI style.
    public init(style: RedirectComponentStyle? = nil) {
        self.style = style
    }
    
    /// Handles a redirect action.
    ///
    /// - Parameter action: The redirect action object.
    public func handle(_ action: RedirectAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, environment: environment)
        
        universalRedirectComponent.handle(action)
    }
    
    /// This function should be invoked from the application's delegate when the application is opened through a URL.
    ///
    /// - Parameter url: The URL through which the application was opened.
    /// - Returns: A boolean value indicating whether the URL was handled by the redirect component.
    @discardableResult
    public static func applicationDidOpen(from url: URL) -> Bool {
        return UniversalRedirectComponent.applicationDidOpen(from: url)
    }
    
    /// :nodoc:
    internal lazy var universalRedirectComponent: UniversalRedirectComponent = {
        let component = UniversalRedirectComponent(style: style)
        component.delegate = self
        return component
    }()
    
    /// :nodoc:
    private let style: RedirectComponentStyle?
    
    /// :nodoc:
    private let componentName = "redirect"
    
    // MARK: - Deprecated Interface
    
    /// :nodoc:
    private var webRedirectComponent: WebRedirectComponent?
    
    /// Initializes the component.
    ///
    /// - Parameter url: The URL to where the user should be redirected.
    /// - Parameter paymentData: The payment data returned by the server.
    /// - Parameter style: The component's UI style.
    @available(*, deprecated, message: "Use init(style:) and handle(action:) instead.")
    public init(url: URL, paymentData: String, style: RedirectComponentStyle? = nil) {
        self.webRedirectComponent = WebRedirectComponent(url: url, paymentData: paymentData, style: style)
        self.style = style
        self.webRedirectComponent?.delegate = self
    }
    
    /// Initializes the component.
    ///
    /// - Parameter action: The redirect action to perform.
    /// - Parameter style: The component's UI style.
    @available(*, deprecated, message: "Use init(style:) and handle(action:) instead.")
    public convenience init(action: RedirectAction, style: RedirectComponentStyle? = nil) {
        self.init(url: action.url, paymentData: action.paymentData, style: style)
    }
    
    /// :nodoc:
    @available(*, deprecated, message: "Use init(style:) and handle(action:) instead.")
    public lazy var viewController: UIViewController = {
        guard let redirectComponent = webRedirectComponent else { fatalError("Use init(style:) and handle(action:) instead.") }
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, environment: environment)
        
        return redirectComponent.viewController
    }()
}

/// :nodoc:
extension RedirectComponent: ActionComponentDelegate {
    
    /// :nodoc:
    public func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        delegate?.didProvide(data, from: self)
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

/// :nodoc:
extension RedirectComponent: PresentableComponent {}
