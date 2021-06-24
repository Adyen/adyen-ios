//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import PassKit
import UIKit

/// A component that handles voucher action's.
internal protocol AnyVoucherActionHandler: ActionComponent {
    func handle(_ action: VoucherAction)
}

/// A component that handles voucher action's.
public final class VoucherComponent: AnyVoucherActionHandler, Cancellable {
    
    /// :nodoc:
    public let apiContext: APIContext

    /// Delegates `PresentableComponent`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?

    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?

    /// :nodoc:
    public let requiresModalPresentation: Bool = true

    /// The Component UI style.
    public let style: VoucherComponentStyle

    /// :nodoc:
    public var localizationParameters: LocalizationParameters?

    /// :nodoc:
    private var voucherViewControllerProvider: AnyVoucherViewControllerProvider?

    /// :nodoc:
    private lazy var apiClient: APIClientProtocol = {
        let scheduler = SimpleScheduler(maximumCount: 3)
        return APIClient(apiContext: apiContext)
            .retryAPIClient(with: scheduler)
            .retryOnErrorAPIClient()
    }()

    /// :nodoc:
    private let componentName = "voucher"

    /// :nodoc:
    private var passProvider: AnyAppleWalletPassProvider?

    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter apiContext: The API context.
    /// - Parameter style: The Component UI style.
    public init(apiContext: APIContext, style: VoucherComponentStyle?) {
        self.apiContext = apiContext
        self.style = style ?? VoucherComponentStyle()
    }

    /// Initializes the `AwaitComponent`.
    /// - Parameter apiContext: The API context.
    /// - Parameter awaitComponentBuilder: The payment method specific await action handler provider.
    /// - Parameter style: The Component UI style.
    internal convenience init(apiContext: APIContext,
                              voucherViewControllerProvider: AnyVoucherViewControllerProvider?,
                              style: VoucherComponentStyle? = nil) {
        self.init(apiContext: apiContext, style: style)
        self.voucherViewControllerProvider = voucherViewControllerProvider
    }

    /// :nodoc:
    public func didCancel() {
        passProvider = nil
    }

    /// Handles await action.
    ///
    /// - Parameter action: The await action object.
    public func handle(_ action: VoucherAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, context: apiContext)
        fetchAndCacheAppleWalletPassIfNeeded(with: action)

        var viewControllerProvider = voucherViewControllerProvider
            ?? VoucherViewControllerProvider(style: style, environment: apiContext.environment)
        viewControllerProvider.localizationParameters = localizationParameters
        viewControllerProvider.delegate = self

        let viewController = viewControllerProvider.provide(with: action)

        if let presentationDelegate = presentationDelegate {
            let presentableComponent = PresentableComponentWrapper(component: self, viewController: viewController)
            presentationDelegate.present(component: presentableComponent)
        } else {
            let message = "PresentationDelegate is nil. Provide a presentation delegate to VoucherComponent."
            AdyenAssertion.assertionFailure(message: message)
        }
    }

    private func fetchAndCacheAppleWalletPassIfNeeded(with action: VoucherAction) {
        if let passToken = action.passCreationToken {
            passProvider = createPassProvider()

            passProvider?.provide(with: passToken, completion: { _ in /* Do nothting, this is just to cache the response */ })
        } else {
            passProvider = nil
        }
    }

    private func createPassProvider() -> AnyAppleWalletPassProvider {
        AppleWalletPassProvider(apiContext: apiContext)
    }

}

/// :nodoc:
extension VoucherComponent: VoucherViewDelegate {
    
    internal func didComplete(presentingViewController: UIViewController) {
        passProvider = nil
        delegate?.didComplete(from: self)
    }

    internal func saveAsImage(voucherView: UIView, presentingViewController: UIViewController) {
        guard let image = voucherView.adyen.snapShot() else { return }
        
        presentSharePopover(
            with: image,
            presentingViewController: presentingViewController,
            sourceView: voucherView
        )
    }
    
    internal func download(url: URL, voucherView: UIView, presentingViewController: UIViewController) {
        presentSharePopover(
            with: url,
            presentingViewController: presentingViewController,
            sourceView: voucherView
        )
    }

    internal func addToAppleWallet(passToken: String,
                                   presentingViewController: UIViewController,
                                   completion: ((Bool) -> Void)?) {
        let passProvider = self.passProvider ?? createPassProvider()
        passProvider.provide(with: passToken) { [weak self] result in
            self?.handle(result: result, presentingViewController: presentingViewController, completion: completion)
        }
    }

    private func handle(result: Result<Data, Swift.Error>,
                        presentingViewController: UIViewController,
                        completion: ((Bool) -> Void)?) {
        switch result {
        case let .failure(error):
            delegate?.didFail(with: error, from: self)
        case let .success(data):
            showAppleWallet(passData: data,
                            presentingViewController: presentingViewController,
                            completion: completion)
        }
    }

    private func presentSharePopover(
        with item: Any,
        presentingViewController: UIViewController,
        sourceView: UIView
    ) {
        let activityViewController = UIActivityViewController(
            activityItems: [item],
            applicationActivities: nil
        )
        activityViewController.popoverPresentationController?.sourceView = sourceView
        presentingViewController.present(activityViewController, animated: true, completion: nil)
    }

    private func showAppleWallet(passData: Data?,
                                 presentingViewController: UIViewController,
                                 completion: ((Bool) -> Void)?) {
        do {
            guard let data = passData else { throw AppleWalletError.failedToAddToAppleWallet }

            let pass = try PKPass(data: data)
            if let viewController = PKAddPassesViewController(pass: pass) {
                presentingViewController.present(viewController, animated: true) {
                    completion?(true)
                }
            } else {
                throw AppleWalletError.failedToAddToAppleWallet
            }
        } catch {
            completion?(false)
            delegate?.didFail(with: error, from: self)
        }
    }
}
