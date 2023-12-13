//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import TwintSDK

public final class TwintActionComponent: ActionComponent {
    
    public var delegate: Adyen.ActionComponentDelegate?
    
    public var context: Adyen.AdyenContext
    
    private func handleDidLoadTwintConfigurations(
        _ configurations: [TWAppConfiguration],
        code: String
    ) {
        // No app installed - show an alert
        if configurations.isEmpty {
            handleNoAppInstalled()
            return
        }
        
        // If only a single twint app is installed we open it directly
        if configurations.count == 1 {
            invokeTwintApp(
                with: configurations.first,
                code: code
            )
        }
        
        // Multiple Twint apps available -> Show the Twint app picker
        let controller = Twint.controller(for: configurations) { [weak self] in
            self?.invokeTwintApp(with: $0, code: code)
        } cancelHandler: { [weak self] in
            guard let self else { return }
            self.delegate?.didFail(with: ComponentError.cancelled, from: self)
        }
        
        guard let controller else { return }
        
        // TODO: How do we notify the TwintComponent?!
//        self.viewController.present(controller, animated: true)
    }
    
    /// Invokes the pay method of the TwintSDK
    private func invokeTwintApp(
        with appConfiguration: TWAppConfiguration?,
        code: String
    ) {
        guard let appConfiguration else { return }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRedirect),
            name: TwintComponent.RedirectNotification,
            object: nil
        )
        
        Twint.pay(
            withCode: code,
            appConfiguration: appConfiguration,
            callback: configuration.redirectURL.absoluteString
        )
    }
    
    private func handleNoAppInstalled() {
        // TODO: Implement Correctly
        let localizationParameters = configuration.localizationParameters
        let alertController = UIAlertController(title: "Error",
                                                message: "No Twint app installed",
                                                preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: localizedString(.dismissButton, localizationParameters), style: .cancel) { [weak self] _ in
            guard let self else { return }
            // TODO: Use a different error as it might be shown after the component closed
            self.delegate?.didFail(with: TwintError(errorDescription: "No app installed"), from: self)
        }
        alertController.addAction(cancelAction)
        
        self.viewController.presentViewController(alertController, animated: true)
    }
    
    @objc
    private func handleRedirect(notification: Notification) {
        NotificationCenter.default.removeObserver(self)
        
        if let error = notification.userInfo?[TwintComponent.RedirectNotificationErrorKey] as? String {
            handleError(TwintError(errorDescription: error))
            return
        }
        
        initiatePayment()
    }
    
    private func handleError(_ error: Error) {
        delegate?.didFail(with: error, from: self)
    }
}
