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

/// A component that presents a QR code.
public final class QRCodeComponent: ActionComponent, Cancellable {
    
    public let apiContext: APIContext
    
    /// Delegates `PresentableComponent`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?

    public weak var delegate: ActionComponentDelegate?
    
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
    
    /// The voucher component configurations.
    public var configuration: Configuration
    
    private let pollingComponentBuilder: AnyPollingHandlerProvider
    
    private var pollingComponent: AnyPollingHandler?
    
    private var timeoutTimer: ExpirationTimer?
    
    private let progress = Progress()
    
    @AdyenObservable(nil) private var expirationText: String?
    
    private let expirationTimeout: TimeInterval
    
    /// Initializes the `QRCodeComponent`.
    ///
    /// - Parameter apiContext: the `APIContext`.
    /// - Parameter configuration: The component configurations
    public convenience init(apiContext: APIContext,
                            configuration: Configuration = .init()) {
        self.init(
            apiContext: apiContext,
            configuration: configuration,
            pollingComponentBuilder: PollingHandlerProvider(apiContext: apiContext),
            timeoutInterval: 60 * 15
        )
    }
    
    /// Initializes the `QRCodeComponent`.
    ///
    /// - Parameter apiContext: the `APIContext`.
    /// - Parameter configuration: The component configurations
    /// - Parameter pollingComponentBuilder: The payment method specific await action handler provider.
    /// - Parameter timeoutInterval: QR Code expiration timeout
    internal init(apiContext: APIContext,
                  configuration: Configuration = .init(),
                  pollingComponentBuilder: AnyPollingHandlerProvider,
                  timeoutInterval: TimeInterval) {
        self.apiContext = apiContext
        self.configuration = configuration
        self.pollingComponentBuilder = pollingComponentBuilder
        self.expirationTimeout = timeoutInterval
        
        updateExpiration(timeoutInterval)
    }

    /// Handles QR code action.
    ///
    /// - Parameter action: The QR code action.
    public func handle(_ action: QRCodeAction) {
        let pollingComponent = pollingComponentBuilder.handler(for: action.paymentMethodType)
        pollingComponent.delegate = self
        
        assert(presentationDelegate != nil)
        
        presentationDelegate?.present(
            component: PresentableComponentWrapper(
                component: self,
                viewController: createViewController(with: action)
            )
        )
        
        startTimer()
        
        pollingComponent.handle(action)
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
        let url = LogoURLProvider.logoURL(withName: action.paymentMethodType.rawValue, environment: apiContext.environment)
        return QRCodeView.Model(
            action: action,
            instruction: localizedString(.pixInstructions,
                                         configuration.localizationParameters),
            logoUrl: url,
            observedProgress: progress,
            expiration: $expirationText,
            style: QRCodeView.Model.Style(
                copyButton: configuration.style.copyButton,
                instructionLabel: configuration.style.instructionLabel,
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
extension QRCodeComponent: ActionComponentDelegate {

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
extension QRCodeComponent: QRCodeViewDelegate {
    
    internal func copyToPasteboard(with action: QRCodeAction) {
        UIPasteboard.general.string = action.qrCodeData
    }
    
}
