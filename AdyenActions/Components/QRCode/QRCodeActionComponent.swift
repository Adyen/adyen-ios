//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// An error that occurred during the use of QRCodeComponent
internal enum QRCodeComponentError: LocalizedError {
    /// Indicates the QR code is not longer valid
    case qrCodeExpired

    public var errorDescription: String? {
        "QR code is no longer valid"
    }
}

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

    private let pollingComponentBuilder: AnyPollingHandlerProvider?
    
    private var pollingComponent: AnyPollingHandler?

    private var timeoutTimer: ExpirationTimer?
    
    private let progress = Progress()

    @AdyenObservable(nil) private var expirationText: String?
    
    /// Initializes the `QRCodeComponent`.
    ///
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The component configurations
    public convenience init(context: AdyenContext,
                            configuration: Configuration = .init()) {
        self.init(context: context,
                  configuration: configuration,
                  pollingComponentBuilder: PollingHandlerProvider(context: context))
    }

    /// Initializes the `QRCodeComponent`.
    ///
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The component configurations
    /// - Parameter pollingComponentBuilder: The payment method specific await action handler provider.
    internal init(context: AdyenContext,
                  configuration: Configuration = .init(),
                  pollingComponentBuilder: AnyPollingHandlerProvider? = nil) {
        self.context = context
        self.configuration = configuration
        self.pollingComponentBuilder = pollingComponentBuilder
    }

    /// Handles QR code action.
    ///
    /// - Parameter action: The QR code action.
    public func handle(_ action: QRCodeAction) {
        AdyenAssertion.assert(message: "presentationDelegate is nil", condition: presentationDelegate == nil)
        
        let viewController = createViewController(with: action)
        setUpPresenterViewController(parentViewController: viewController)
        
        if let presentationDelegate {
            renderExpirationLabelAndStartTimer(action)
            
            startPolling(action)
            
            present(viewController, presentationDelegate: presentationDelegate)
        } else {
            AdyenAssertion.assertionFailure(
                message: "PresentationDelegate is nil. Provide a presentation delegate to QRCodeActionComponent."
            )
        }
    }
    
    private func renderExpirationLabelAndStartTimer(_ action: QRCodeAction) {
        let timeout = timeoutDuration(for: action)
        updateExpiration(timeout)
        startTimer(from: timeout, qrCodeAction: action)
    }
    
    private func startPolling(_ action: QRCodeAction) {
        pollingComponent = pollingComponentBuilder?.handler(for: action.paymentMethodType)
        pollingComponent?.delegate = self
        pollingComponent?.handle(action)
    }
    
    private func present(_ viewController: UIViewController, presentationDelegate: PresentationDelegate) {
        let pollingComponentToolBar = CancellingToolBar(title: viewController.title, style: NavigationStyle())
        let presentableComponent = PresentableComponentWrapper(
            component: self,
            viewController: viewController,
            navBarType: .custom(pollingComponentToolBar)
        )
        presentationDelegate.present(component: presentableComponent)
    }
    
    internal func timeoutDuration(for action: QRCodeAction) -> TimeInterval {
        switch action.paymentMethodType {
        case .promptPay, .duitNow:
            return 90
        case .payNow:
            return 180
        case .pix:
            return 60 * 15
        case .upiQRCode:
            return 60 * 5
        }
    }
    
    private func startTimer(from interval: TimeInterval, qrCodeAction: QRCodeAction) {
        let unitCount = Int64(interval)
        progress.totalUnitCount = unitCount
        progress.completedUnitCount = unitCount
        
        timeoutTimer = ExpirationTimer(
            expirationTimeout: interval,
            onTick: { [weak self] in self?.updateExpiration($0, qrCodeAction: qrCodeAction) },
            onExpiration: { [weak self] in self?.onTimerTimeout() }
        )
        timeoutTimer?.startTimer()
    }

    private func updateExpiration(_ timeLeft: TimeInterval, qrCodeAction: QRCodeAction? = nil) {
        progress.completedUnitCount = Int64(timeLeft)
        let timeLeftString = timeLeft.adyen.timeLeftString() ?? ""

        switch qrCodeAction?.paymentMethodType {
        case .promptPay, .duitNow, .payNow:
            expirationText = localizedString(.qrCodeTimerExpirationMessage,
                                             configuration.localizationParameters,
                                             timeLeftString)
        case .pix:
            expirationText = localizedString(.pixExpirationLabel,
                                             configuration.localizationParameters,
                                             timeLeftString)
        case .upiQRCode:
            expirationText = localizedString(.UPIQrcodeTimerMessage,
                                             configuration.localizationParameters,
                                             timeLeftString)
        case .none:
            expirationText = ""
        }
    }
    
    private func onTimerTimeout() {
        cleanup()
        
        delegate?.didFail(with: QRCodeComponentError.qrCodeExpired, from: self)
    }
    
    private func createViewController(with action: QRCodeAction) -> UIViewController {
        let viewController = QRCodeViewController(viewModel: createViewModel(with: action))
        viewController.qrCodeView.delegate = self
        return viewController
    }

    private func QRCodeInstruction(with action: QRCodeAction) -> String {
        switch action.paymentMethodType {
        case .promptPay, .duitNow, .payNow:
            return localizedString(.qrCodeInstructionMessage,
                                   configuration.localizationParameters)
        case .pix:
            return localizedString(.pixInstructions,
                                   configuration.localizationParameters)
        case .upiQRCode:
            return localizedString(.UPIQRCodeInstructions,
                                   configuration.localizationParameters)
        }
    }

    private func createViewModel(with action: QRCodeAction) -> QRCodeView.Model {
        let url = LogoURLProvider.logoURL(withName: action.paymentMethodType.rawValue, environment: context.apiContext.environment)
        return QRCodeView.Model(
            action: action,
            instruction: QRCodeInstruction(with: action),
            payment: context.payment,
            logoUrl: url,
            observedProgress: progress,
            expiration: $expirationText,
            style: QRCodeView.Model.Style(
                copyCodeButton: configuration.style.copyCodeButton,
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
        pollingComponent?.didCancel()
    }
}

@_spi(AdyenInternal)
extension QRCodeActionComponent: ActionComponentDelegate {

    public func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        cleanup()
        delegate?.didProvide(data, from: self)
    }

    public func didComplete(from component: ActionComponent) {}

    public func didFail(with error: Error, from component: ActionComponent) {
        cleanup()
        delegate?.didFail(with: error, from: self)
    }

}

@_spi(AdyenInternal)
extension QRCodeActionComponent: QRCodeViewDelegate {
    
    internal func copyToPasteboard(with action: QRCodeAction) {
        UIPasteboard.general.string = action.qrCodeData
    }

    internal func saveAsImage(qrCodeImage: UIImage?, sourceView: UIView) {
        presentSharePopover(with: qrCodeImage as Any, sourceView: sourceView)
    }
}
