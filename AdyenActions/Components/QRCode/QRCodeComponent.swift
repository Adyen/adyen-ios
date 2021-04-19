//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// An error that occured during the use of QRCodeComponent
internal enum QRCodeComponentError: LocalizedError {
    /// Indicates the QR code is not longer valid
    case qrCodeExpired
    
    public var errorDescription: String? {
        "QR code is no longer valid"
    }
}

/// A component that presents a QR code.
internal final class QRCodeComponent: ActionComponent, Localizable, Cancellable {
    
    /// Delegates `ViewController`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?
    
    /// The component UI style.
    public let style: QRCodeComponentStyle

    /// :nodoc:
    public weak var delegate: ActionComponentDelegate?
    
    /// :nodoc:
    public var action: QRCodeAction?
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    /// Initializes the `QRCodeComponent`.
    ///
    /// - Parameter style: The component UI style.
    public convenience init(style: QRCodeComponentStyle?) {
        self.init(
            style: style ?? QRCodeComponentStyle(),
            awaitComponentBuilder: nil,
            timeoutInterval: 60 * 15
        )
    }
    
    /// Initializes the `QRCodeComponent`.
    ///
    /// - Parameter style: The component UI style.
    /// - Parameter awaitComponentBuilder: The payment method specific await action handler provider.
    /// - Parameter timeoutInterval: QR Code expiration timeout
    internal init(style: QRCodeComponentStyle = QRCodeComponentStyle(),
                  awaitComponentBuilder: AnyAwaitActionHandlerProvider?,
                  timeoutInterval: TimeInterval) {
        self.style = style
        self.awaitComponentBuilder = awaitComponentBuilder
        self.timeoutInterval = timeoutInterval
        self.timeLeft = timeoutInterval
        
        updateExpiration()
    }
    
    /// Handles QR code action.
    ///
    /// - Parameter action: The QR code action.
    public func handle(_ action: QRCodeAction) {
        self.action = action
        
        let awaitComponentBuilder = self.awaitComponentBuilder ?? AwaitActionHandlerProvider(environment: environment, apiClient: nil)
        
        let awaitComponent = awaitComponentBuilder.handler(for: action.paymentMethodType)
        awaitComponent.delegate = self
        
        presentationDelegate?.present(
            component: PresentableComponentWrapper(
                component: self, viewController: createViewController(with: action))
        )
        
        startTimer()
        
        awaitComponent.handle(action)
    }
    
    /// :nodoc:
    private var awaitComponentBuilder: AnyAwaitActionHandlerProvider?
    
    /// :nodoc:
    private var awaitComponent: AnyAwaitActionHandler?
    
    /// :nodoc:
    private var timeoutTimer: Timer?
    
    /// :nodoc
    private let progress: Progress = Progress()
    
    /// :nodoc:
    @Observable(nil) private var expirationText: String?
    
    /// :nodoc:
    private let timeoutInterval: TimeInterval
    
    /// :nodoc:
    private var timeLeft: TimeInterval
    
    /// :nodoc
    private func startTimer() {
        let unitCount = Int64(timeoutInterval)
        progress.totalUnitCount = unitCount
        progress.completedUnitCount = unitCount
        
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.onTimerTick()
        }
    }
    
    /// :nodoc
    private func onTimerTick() {
        timeLeft -= 1
        
        if timeLeft > 0 {
            updateExpiration()
        } else {
            onTimerTimeout()
        }
    }
    
    /// :nodoc:
    private func updateExpiration() {
        progress.completedUnitCount = Int64(timeLeft)
        expirationText = ADYLocalizedString("adyen.pix.expirationLabel", localizationParameters, timeLeft.adyen.timeLeftString())
    }
    
    /// :nodoc:
    private func onTimerTimeout() {
        awaitComponent?.didCancel()
        stopTimer()
        
        delegate?.didFail(with: QRCodeComponentError.qrCodeExpired, from: self)
    }
    
    /// :nodoc:
    fileprivate func stopTimer() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
    
    /// :nodoc:
    private func createViewController(with action: QRCodeAction) -> UIViewController {
        let view = QRCodeView(model: createModel(with: action))
        view.delegate = self
        return QRCodeViewController(qrCodeView: view)
    }
    
    /// :nodoc:
    private func createModel(with action: QRCodeAction) -> QRCodeView.Model {
        let url = LogoURLProvider.logoURL(withName: "pix", environment: .test)
        return QRCodeView.Model(
            instruction: ADYLocalizedString("adyen.pix.instructions", localizationParameters),
            logoUrl: url,
            observedProgress: progress,
            expiration: $expirationText,
            style: QRCodeView.Model.Style(
                copyButton: style.copyButton,
                instructionLabel: style.instructionLabel,
                progressView: style.progressView,
                expirationLabel: style.expirationLabel,
                backgroundColor: style.backgroundColor
            )
        )
    }
    
    ///: nodoc:
    public func didCancel() {
        stopTimer()
        awaitComponent?.didCancel()
    }
}

extension QRCodeComponent: ActionComponentDelegate {
    
    func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        stopTimer()
        awaitComponent?.didCancel()
        delegate?.didProvide(data, from: self)
    }
    
    func didComplete(from component: ActionComponent) { }
    
    func didFail(with error: Error, from component: ActionComponent) {
        stopTimer()
        awaitComponent?.didCancel()
        delegate?.didFail(with: error, from: self)
    }
    
}

extension QRCodeComponent: QRCodeViewDelegate {
    
    func copyToPasteboard() {
        UIPasteboard.general.string = action.map(\.qrCodeData)
    }
    
}
