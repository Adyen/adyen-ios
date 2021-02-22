//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import PassKit

/// A component that handles voucher action's.
internal protocol AnyVoucherActionHandler: ActionComponent {
    func handle(_ action: VoucherAction)
}

/// A component that handles voucher action's.
public final class VoucherComponent: AnyVoucherActionHandler {

    /// Delegates `ViewController`'s presentation.
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
    private lazy var apiClient: APIClientProtocol = APIClient(environment: environment)

    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter style: The Component UI style.
    public convenience init(style: VoucherComponentStyle?) {
        self.init(style: style, apiClient: nil)
    }

    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter style: The Component UI style.
    internal init(style: VoucherComponentStyle?,
                  apiClient: APIClientProtocol?) {
        self.style = style ?? VoucherComponentStyle()
        if let apiClient = apiClient {
            self.apiClient = apiClient
        }
    }

    /// Initializes the `AwaitComponent`.
    ///
    /// - Parameter awaitComponentBuilder: The payment method specific await action handler provider.
    /// - Parameter style: The Component UI style.
    internal convenience init(voucherViewControllerProvider: AnyVoucherViewControllerProvider?,
                              style: VoucherComponentStyle? = nil) {
        self.init(style: style)
        self.voucherViewControllerProvider = voucherViewControllerProvider
    }

    /// :nodoc:
    private let componentName = "voucher"

    /// Handles await action.
    ///
    /// - Parameter action: The await action object.
    public func handle(_ action: VoucherAction) {
        Analytics.sendEvent(component: componentName, flavor: _isDropIn ? .dropin : .components, environment: environment)

        var viewControllerProvider = voucherViewControllerProvider ?? VoucherViewControllerProvider(style: style)
        viewControllerProvider.localizationParameters = localizationParameters
        viewControllerProvider.delegate = self

        let viewController = viewControllerProvider.provide(with: action)

        if let presentationDelegate = presentationDelegate {
            let presentableComponent = PresentableComponentWrapper(component: self, viewController: viewController)
            presentationDelegate.present(component: presentableComponent, disableCloseButton: false)
        } else {
            assertionFailure("presentationDelegate is nil, please provide a presentation delegate to present the VoucherComponent UI.")
        }
    }

}

extension VoucherComponent: VoucherViewDelegate {
    internal func didComplete(voucherAction: GenericVoucherAction, presentingViewController: UIViewController) {
        delegate?.didComplete(from: self)
    }

    internal func saveToAppleWallet(voucherAction: GenericVoucherAction, presentingViewController: UIViewController, completion: (() -> Void)?) {
        let request = AppleWalletPassRequest(action: voucherAction)
        apiClient.perform(request, completionHandler: { [weak self] result in
            switch result {
            case let .failure(error):
                adyenPrint(error)
                completion?()
            case let .success(response):
                self?.handle(response: response,
                             presentingViewController: presentingViewController,
                             completion: completion)
            }
        })
    }

    private func handle(response: AppleWalletPassResponse, presentingViewController: UIViewController, completion: (() -> Void)?) {
        guard let data = response.appleWalletPassBundle else { completion?(); return }
        do {
            let pass = try PKPass(data: data)
            guard let viewController = PKAddPassesViewController(pass: pass) else { completion?(); return }
            presentingViewController.present(viewController, animated: true) {
                completion?()
            }
        } catch {
            adyenPrint(error)
            completion?()
        }
    }

    internal func saveAsImage(voucherView: UIView, presentingViewController: UIViewController) {
        guard let image = voucherView.adyen.snapShot() else { return }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = voucherView
        presentingViewController.present(activityViewController, animated: true, completion: nil)
    }
}
