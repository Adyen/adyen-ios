//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// An error that occured during the use of QRCodeComponent
internal enum QRCodeComponentError: Error {
    /// Indicates the QR code is not longer valid
    case qrCodeExpired
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
    public init(style: QRCodeComponentStyle = QRCodeComponentStyle()) {
        self.style = style
        
        self.timeLeft = timeoutInterval
        self.progress = Progress()
        
        updateExpiration()
    }
    
    /// Handles QR code action.
    ///
    /// - Parameter action: The QR code action.
    public func handle(_ action: QRCodeAction) {
        self.action = action
        
        presentationDelegate?.present(
            component: PresentableComponentWrapper(
                component: self, viewController: createViewController(with: action))
        )
        
        startTimer()
        
        awaitComponent.handle(action)
    }
    
    private var timeoutTimer: Timer?
    private let progress: Progress
    @Observable(nil) private var expirationText: String?
    
    /// Default timeout is 15 min
    private let timeoutInterval: TimeInterval = 60 * 15
    private var timeLeft: TimeInterval
    
    private func startTimer() {
        let unitCount = Int64(timeoutInterval)
        progress.totalUnitCount = unitCount
        progress.completedUnitCount = unitCount
        
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.onTimerTick()
        }
    }
    
    private func onTimerTick() {
        timeLeft -= 1
        
        if timeLeft > 0 {
            updateExpiration()
        } else {
            onTimerTimeout()
        }
    }
    
    private func updateExpiration() {
        progress.completedUnitCount = Int64(timeLeft)
        expirationText = "You have \(timeLeft.adyen.timeLeftString()) to pay"
    }
    
    private func onTimerTimeout() {
        awaitComponent.didCancel()
        stopTimer()
        
        delegate?.didFail(with: QRCodeComponentError.qrCodeExpired, from: self)
    }
    
    fileprivate func stopTimer() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
    
    private func createViewController(with action: QRCodeAction) -> UIViewController {
        let view = QRCodeView(model: createModel(with: action))
        view.delegate = self
        return QRCodeViewController(qrCodeView: view)
    }
    
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
    
    private lazy var awaitComponent: AnyAwaitActionHandler = {
        let client = APIClient(environment: environment)
        let scheduler = BackoffScheduler(queue: .main)
        let retry = RetryAPIClient(apiClient: client, scheduler: scheduler)
        let component = PollingAwaitComponent(
            apiClient: RetryAPIClient(apiClient: APIClient(environment: environment),
                                      scheduler: BackoffScheduler(queue: .main))
        )
        component.delegate = self
        
        return component
    }()
    
    public func didCancel() {
        stopTimer()
        awaitComponent.didCancel()
    }
}

extension QRCodeComponent: ActionComponentDelegate {
    
    func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        stopTimer()
        awaitComponent.didCancel()
        delegate?.didProvide(data, from: self)
    }
    
    func didComplete(from component: ActionComponent) { }
    
    func didFail(with error: Error, from component: ActionComponent) {
        stopTimer()
        awaitComponent.didCancel()
        delegate?.didFail(with: error, from: self)
    }
    
}

extension QRCodeComponent: QRCodeViewDelegate {
    
    func copyToPasteboard() {
        UIPasteboard.general.string = action.map(\.qrCodeData)
    }
    
}
