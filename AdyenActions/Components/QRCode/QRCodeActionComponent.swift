//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A component  for QRCode action.
public final class QRCodeActionComponent: ActionComponent, Cancellable, ShareableComponent {
    
    /// The context object for this component.
    @_spi(AdyenInternal)
    public let context: AdyenContext
    
    /// Delegates `PresentableComponent`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?

    public weak var delegate: ActionComponentDelegate?
    
    internal let presenterViewController = UIViewController()
    
    /// The QR code component configurations.
    public struct Configuration {
        
        /// The component UI style.
        public var style: QRCodeComponentStyle = .init()
        
        /// The localization parameters, leave it nil to use the default parameters.
        public var localizationParameters: LocalizationParameters?
        
        /// Initializes an instance of `Configuration`
        ///
        /// - Parameters:
        ///   - style: The Component UI style.
        ///   - localizationParameters: The localization parameters, leave it nil to use the default parameters.
        public init(style: QRCodeComponentStyle = QRCodeComponentStyle(), localizationParameters: LocalizationParameters? = nil) {
            self.style = style
            self.localizationParameters = localizationParameters
        }
    }
    
    /// The QR code component configurations.
    public var configuration: Configuration
    
    private var timeoutTimer: ExpirationTimer?
    
    private let progress = Progress()
    
    @AdyenObservable(nil) private var expirationText: String?
    
    private let expirationTimeout: TimeInterval
    
    /// Initializes the `QRCodeComponent`.
    ///
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The component configurations
    public convenience init(context: AdyenContext,
                            configuration: Configuration = .init()) {
        self.init(context: context,
                  configuration: configuration,
                  timeoutInterval: 60 * 15)
    }
    
    /// Initializes the `QRCodeComponent`.
    ///
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The component configurations
    /// - Parameter timeoutInterval: QR Code expiration timeout
    internal init(context: AdyenContext,
                  configuration: Configuration = .init(),
                  timeoutInterval: TimeInterval) {
        self.context = context
        self.configuration = configuration
        self.expirationTimeout = timeoutInterval
        
        updateExpiration(timeoutInterval)
    }

    /// Handles QR code action.
    ///
    /// - Parameter action: The QR code action.
    public func handle(_ action: QRCodeAction) {
        assert(presentationDelegate != nil)
        
        let viewController = createViewController(with: action)
        setUpPresenterViewController(parentViewController: viewController)

        if let presentationDelegate = presentationDelegate {
            let presentableComponent = PresentableComponentWrapper(
                component: self,
                viewController: viewController
            )
            presentationDelegate.present(component: presentableComponent)
        } else {
            AdyenAssertion.assertionFailure(
                message: "PresentationDelegate is nil. Provide a presentation delegate to QRCodeActionComponent."
            )
        }
        
        startTimer()
    }
    
    /// :nodoc
    private func startTimer() {
        let unitCount = Int64(expirationTimeout)
        progress.totalUnitCount = unitCount
        progress.completedUnitCount = unitCount
        
        timeoutTimer = ExpirationTimer(
            expirationTimeout: self.expirationTimeout,
            onTick: { [weak self] in self?.updateExpiration($0) },
            onExpiration: { [weak self] in self?.onTimerTimeout() }
        )
        timeoutTimer?.startTimer()
    }
    
    private func updateExpiration(_ timeLeft: TimeInterval) {
        progress.completedUnitCount = Int64(timeLeft)
        let timeLeftString = timeLeft.adyen.timeLeftString() ?? ""
        expirationText = localizedString(.pixExpirationLabel,
                                         configuration.localizationParameters,
                                         timeLeftString)
    }
    
    private func onTimerTimeout() {
        cleanup()
        
        delegate?.didFail(with: QRCodeComponentError.qrCodeExpired, from: self)
    }
    
    private func createViewController(with action: QRCodeAction) -> UIViewController {
        let viewController = QRCodeViewController(viewModel: createModel(with: action))
        viewController.qrCodeView.delegate = self
        return viewController
    }
    
    private func createModel(with action: QRCodeAction) -> QRCodeView.Model {
        let url = LogoURLProvider.logoURL(withName: action.paymentMethodType.rawValue, environment: context.apiContext.environment)
        return QRCodeView.Model(
            action: action,
            instruction: localizedString(.pixInstructions,
                                         configuration.localizationParameters),
            payment: context.payment,
            logoUrl: url,
            observedProgress: progress,
            expiration: $expirationText,
            style: QRCodeView.Model.Style(
                saveAsImageButton: configuration.style.saveAsImageButton,
                instructionLabel: configuration.style.instructionLabel,
                amountToPayLabel: configuration.style.amountToPayLabel,
                progressView: configuration.style.progressView,
                expirationLabel: configuration.style.expirationLabel,
                logoCornerRounding: configuration.style.logoCornerRounding,
                backgroundColor: configuration.style.backgroundColor
            )
        )
    }
    
    public func didCancel() {
        cleanup()
    }
    
    fileprivate func cleanup() {
        timeoutTimer?.stopTimer()
    }

}

@_spi(AdyenInternal)
extension QRCodeActionComponent: QRCodeViewDelegate {

    internal func saveAsImage(qrCodeImage: UIImage?, sourceView: UIView) {
        presentSharePopover(with: qrCodeImage as Any, sourceView: sourceView)
    }
    
}
