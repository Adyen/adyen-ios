//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import PassKit
import UIKit

/// A component that handles voucher action's.
internal protocol AnyVoucherActionHandler: ActionComponent, Cancellable {
    func handle(_ action: VoucherAction)
}

/// A component that handles voucher action's.
public final class VoucherComponent: AnyVoucherActionHandler {
    
    /// :nodoc:
    private static let maximumDisplayedCodeLength = 10

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
    private var viewControllerProvider: AnyVoucherShareableViewProvider
    
    /// :nodoc:
    private var action: VoucherAction?

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
    private let passProvider: AnyAppleWalletPassProvider

    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter apiContext: The API context.
    /// - Parameter style: The Component UI style.
    public convenience init(apiContext: APIContext, style: VoucherComponentStyle?) {
        self.init(
            apiContext: apiContext,
            voucherViewControllerProvider: nil,
            style: style ?? VoucherComponentStyle(),
            passProvider: AppleWalletPassProvider(apiContext: apiContext)
        )
    }

    /// Initializes the `AwaitComponent`.
    /// - Parameter apiContext: The API context.
    /// - Parameter awaitComponentBuilder: The payment method specific await action handler provider.
    /// - Parameter style: The Component UI style.
    internal init(
        apiContext: APIContext,
        voucherViewControllerProvider: AnyVoucherShareableViewProvider?,
        style: VoucherComponentStyle,
        passProvider: AnyAppleWalletPassProvider?
    ) {
        self.apiContext = apiContext
        self.style = style
        self.viewControllerProvider = voucherViewControllerProvider ??
            VoucherShareableViewProvider(style: style, environment: apiContext.environment)
        self.passProvider = passProvider ?? AppleWalletPassProvider(apiContext: apiContext)
    }

    /// :nodoc:
    public func didCancel() { }

    /// Handles await action.
    ///
    /// - Parameter action: The await action object.
    public func handle(_ action: VoucherAction) {
        self.action = action
        
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, context: apiContext)
        fetchAndCacheAppleWalletPassIfNeeded(with: action.anyAction)

        viewControllerProvider.localizationParameters = localizationParameters

        let view = VoucherView(model: viewModel(with: action))
        view.delegate = self
        let viewController = ADYViewController(view: view)
        view.presenter = viewController

        if let presentationDelegate = presentationDelegate {
            let presentableComponent = PresentableComponentWrapper(
                component: self,
                viewController: viewController,
                navBarType: getNavBarType()
            )
            presentationDelegate.present(component: presentableComponent)
        } else {
            let message = "PresentationDelegate is nil. Provide a presentation delegate to VoucherComponent."
            AdyenAssertion.assertionFailure(message: message)
        }
    }
    
    private func getNavBarType() -> NavigationBarType {
        let bundle = Bundle(for: UIBarButtonItem.self)
        let localizedEdit = bundle.localizedString(forKey: "Edit", value: "Edit", table: nil)
        let localizedDone = bundle.localizedString(forKey: "Done", value: "Done", table: nil)
        let model = VoucherNavBar.Model(
            editButtonTitle: localizedEdit,
            doneButtonTitle: localizedDone,
            style: VoucherNavBar.Model.Style(
                editButton: style.editButton,
                doneButton: style.doneButton,
                backgroundColor: style.backgroundColor)
        )
        let navBar = VoucherNavBar(
            model: model
        )
        navBar.trailingButtonHandler = { [weak self] in
            self.map { $0.delegate?.didComplete(from: $0) }
        }
        return .custom(navBar)
    }
    
    private func viewModel(with action: VoucherAction) -> VoucherView.Model {
        let anyAction = action.anyAction
        let viewStyle = VoucherView.Model.Style(
            editButton: style.editButton,
            doneButton: style.doneButton,
            mainButton: getPrimaryButtonStyle(with: anyAction),
            secondaryButton: style.secondaryButton,
            amountLabel: style.amountLabel,
            currencyLabel: style.currencyLabel,
            logoCornerRounding: .fixed(5),
            backgroundColor: style.backgroundColor
        )
        
        var amount = anyAction.totalAmount.formatted
        amount
            .range(of: anyAction.totalAmount.currencyCode)
            .map { amount.removeSubrange($0) }
        
        return VoucherView.Model(
            amount: amount,
            currency: anyAction.totalAmount.currencyCode,
            logoUrl: LogoURLProvider.logoURL(
                withName: anyAction.paymentMethodType.rawValue,
                environment: apiContext.environment,
                size: .medium
            ),
            mainButton: getPrimaryButtonTitle(with: anyAction),
            secondaryButtonTitle: getSecondaryButtonTitle(with: action),
            passToken: anyAction.passCreationToken,
            style: viewStyle
        )
    }
    
    private func getPrimaryButtonTitle(with action: AnyVoucherAction) -> String {
        return localizedString(.voucherSaveImage, localizationParameters)
    }
    
    private func getPrimaryButtonStyle(with action: AnyVoucherAction) -> ButtonStyle {
        // TODO: Display depending on the payment method type
        return style.mainButton
    }
    
    private func getSecondaryButtonTitle(with action: VoucherAction) -> String {
        // TODO: Display depending on the payment method type
        return localizedString(.boletoDownloadPdf, localizationParameters)
    }

    private func fetchAndCacheAppleWalletPassIfNeeded(with action: AnyVoucherAction) {
        guard let passToken = action.passCreationToken else { return }
        passProvider.provide(with: passToken) { _ in
            /* Do nothting, this is just to cache the response */
        }
    }

}

/// :nodoc:
extension VoucherComponent: VoucherViewDelegate {
    
    internal func didComplete(presentingViewController: UIViewController) {
        delegate?.didComplete(from: self)
    }

    internal func saveAsImage(voucherView: UIView, presentingViewController: UIViewController) {
        guard let action = action else { return }
        
        let view = viewControllerProvider.provideView(with: action)
        view.frame = UIScreen.main.bounds
        
        guard let image = view.adyen.snapShot() else { return }
        
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
        passProvider.provide(with: passToken) { [weak self] result in
            self?.handle(
                result: result,
                presentingViewController: presentingViewController,
                completion: completion
            )
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
