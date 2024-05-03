//
// Copyright (c) 2024 Adyen N.V.
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
    private let localizationParameters: LocalizationParameters?
    private let appLauncher: AnyAppLauncher
    private let componentName = "browser"
    
    internal var requiresModalPresentation: Bool { false }
    
    internal lazy var viewController: UIViewController = {
        BrowserComponentViewController(
            url: url,
            localizationParameters: localizationParameters,
            appLauncher: appLauncher,
            delegate: delegate
        )
    }()
    
    internal weak var delegate: BrowserComponentDelegate?
    
    /// Initializes the component.
    ///
    /// - Parameter url: The URL to where the user should be redirected
    /// - Parameter context: The context object for this component.
    /// - Parameter style: The component's UI style.
    internal init(
        url: URL,
        context: AdyenContext,
        style: RedirectComponentStyle? = nil
    ) {
        self.url = url
        self.context = context
        self.style = style
        
        // TODO: Pass LocalizationParamaters + AppLauncher!
        self.localizationParameters = nil
        self.appLauncher = AppLauncher()
        
        super.init()
    }
}

// TODO: Make this a custom ViewController - not a UIAlertController
private class BrowserComponentViewController: UIAlertController {
    
    private let url: URL
    private let localizationParameters: LocalizationParameters?
    private let appLauncher: AnyAppLauncher
    private weak var delegate: BrowserComponentDelegate?
    
    override var preferredStyle: UIAlertController.Style { .actionSheet }
    
    init(
        url: URL,
        localizationParameters: LocalizationParameters?,
        appLauncher: AnyAppLauncher,
        delegate: BrowserComponentDelegate?
    ) {
        self.url = url
        self.localizationParameters = localizationParameters
        self.appLauncher = appLauncher
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
        
        // TODO: Take the strings from the LocalizationParameters
        self.title = "Payment in progress"
        self.message = "Awaiting completion..."
        
        addAction(
            .init(
                title: localizedString(.cancelButton, localizationParameters),
                style: .cancel,
                handler: { _ in
                    delegate?.didCancel()
                }
            )
        )
        
        // TODO: Tapping a button dismisses the alert -> build a custom sheet that allows button presses without dismissal
        
//        addAction(
//            .init(
//                title: "Try again",
//                style: .default,
//                handler: { [weak self] _ in
//                    self?.handleRetry()
//                }
//            )
//        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleOpenUrl()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func handleOpenUrl() {
        appLauncher.openCustomSchemeUrl(url) { [weak self] _ in
            // Could triggering `didOpenExternalApplication` multiple times cause issues?
            self?.delegate?.didOpenExternalApplication()
        }
    }
    
    private func handleRetry() {
        // Not triggering `didOpenExternalApplication` anymore
        appLauncher.openCustomSchemeUrl(url) { _ in }
    }
}
