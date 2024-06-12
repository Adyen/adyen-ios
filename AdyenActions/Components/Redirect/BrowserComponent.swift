//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import SafariServices
import UIKit
import WebKit

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

    class Browser: UIViewController, WKNavigationDelegate, WKUIDelegate {
        var webView = WKWebView()
        
        init(url: URL) {
            super.init(nibName: nil, bundle: nil)
            self.webView.load(URLRequest(url: url))
            self.webView.navigationDelegate = self
            self.webView.uiDelegate = self
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.view.addSubview(webView)
            self.webView.translatesAutoresizingMaskIntoConstraints = false
            self.webView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        }
        
        @available(iOS 13.0.0, *)
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            print("BOB: \(#function): navigationAction:\(navigationAction)")
            return .allow
        }
        
        @available(iOS 13.0.0, *)
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
            print("BOB: \(#function): navigationResponse:\(navigationResponse)")
            return .allow
        }
        
        @available(iOS 13.0.0, *)
        func webView(_ webView: WKWebView, respondTo challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
            print("BOB: \(#function): challenge:\(challenge)")

            return (.useCredential, nil)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
            print("BOB: \(#function): navigation:\(navigation) error:\(error)")
        }
    }

    internal lazy var viewController: UIViewController = {
        Browser(url: url)
    }()
    
    internal lazy var viewControllerr: UIViewController = {
        
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
    
    @AdyenDependency(\.openAppDetector) private var openAppDetector
    
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
        openAppDetector.checkIfExternalAppDidOpen { didOpenExternalApp in
            if didOpenExternalApp {
                self.delegate?.didOpenExternalApplication()
            } else {
                self.delegate?.didCancel()
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

    /// Called when the user opens the current page in the default browser by tapping the toolbar button.
    internal func safariViewControllerWillOpenInBrowser(_ controller: SFSafariViewController) {
        self.delegate?.didOpenExternalApplication()
    }
}
