//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey
import Foundation
#if canImport(TwintSDK)
    import TwintSDK
#endif

#if canImport(TwintSDK)
    /// A component that handles Twint SDK action's.
    @MainActor
    package final class TwintSDKActionComponent: ActionComponent {

        /// The context object for this component.
        package let context: AdyenContext

        /// Delegates `PresentableComponent`'s presentation.
        package weak var presentationDelegate: PresentationDelegate?

        package weak var delegate: ActionComponentDelegate?

        private let pollingComponentBuilder: AnyPollingHandlerProvider?

        private var pollingComponent: AnyPollingHandler?

        /// The twint component configurations.
        package var configuration: TwintActionConfiguration

        private let twint: Twint

        /// Initializes the `TwintSDKActionComponent`.
        ///
        /// - Parameter context: The context object for this component.
        /// - Parameter configuration: The TwintSDK component configurations.
        package init(
            context: AdyenContext,
            configuration: TwintActionConfiguration
        ) {
            self.context = context
            self.configuration = configuration
            self.twint = Twint()
            self.pollingComponentBuilder = PollingHandlerProvider(context: context)
        }

        internal init(
            context: AdyenContext,
            configuration: TwintActionConfiguration,
            twint: Twint,
            pollingComponentBuilder: AnyPollingHandlerProvider? = nil
        ) {
            self.context = context
            self.configuration = configuration
            self.twint = twint
            self.pollingComponentBuilder = pollingComponentBuilder
        }

        /// Handles TwintSDK action.
        ///
        /// - Parameter action: The Twint SDK action object.
        package func handle(_ action: TwintSDKAction) {
            AdyenAssertion.assert(message: "presentationDelegate is nil", condition: presentationDelegate == nil)
            twint.fetchInstalledAppConfigurations(maxIssuerNumber: configuration.maxIssuerNumber) { [weak self] installedApps in
                guard let self else { return }

                guard let firstApp = installedApps.first else {
                    let errorMessage = localizedString(
                        .twintNoAppsInstalledMessage,
                        self.configuration.localizationParameters
                    )
                    self.handleShowError(
                        errorMessage,
                        componentName: action.paymentMethodType
                    )
                    return
                }

                if installedApps.count > 1 {
                    self.presentAppChooser(for: installedApps, action: action)
                } else {
                    self.invokeTwint(app: firstApp, action: action)
                }
            }
        }

        private func invokeTwint(app: TWAppConfiguration, action: TwintSDKAction) {
            let completionHandler: (Error?) -> Void = { [weak self] error in
                guard let self else { return }
                if let error {
                    self.handleShowError(
                        error.localizedDescription,
                        componentName: action.paymentMethodType
                    )
                    return
                }

                RedirectListener.registerForURL { [weak self] url in
                    self?.twint.handleOpen(url) { [weak self] error in
                        self?.handlePaymentResult(error: error, action: action)
                    }
                }
            }

            if action.sdkData.isStored {
                twint.registerForUOF(
                    withCode: action.sdkData.token,
                    appConfiguration: app,
                    callback: configuration.callbackAppScheme,
                    completionHandler: completionHandler
                )
            } else {
                twint.pay(
                    withCode: action.sdkData.token,
                    appConfiguration: app,
                    callback: configuration.callbackAppScheme,
                    completionHandler: completionHandler
                )
            }
        }

        private func presentAppChooser(for installedApps: [TWAppConfiguration], action: TwintSDKAction) {
            let appChooserViewController = twint.controller(
                for: installedApps,
                selectionHandler: { [weak self] in
                    guard let self else { return }
                    self.invokeTwint(
                        app: $0 ?? installedApps[0],
                        action: action
                    )
                },
                cancelHandler: { [weak self] in
                    guard let self else { return }
                    self.delegate?.didFail(
                        with: ComponentError.cancelled,
                        from: self
                    )
                }
            )

            if let viewController = appChooserViewController, let delegate = presentationDelegate {
                present(viewController, presentationDelegate: delegate)
            }
        }

        private func handlePaymentResult(error: Error?, action: TwintSDKAction) {
            guard let delegate else { return }

            // Twint always returns an error (even if the call was successful)
            // We have to treat the error as optional because of Obj-C
            if let error, (error as NSError).code != TWErrorCode.B_SUCCESS.rawValue {
                delegate.didFail(with: error, from: self)
                return
            }
            startPolling(action)
        }

        private func startPolling(_ action: TwintSDKAction) {
            pollingComponent = pollingComponentBuilder?.handler(for: AwaitPaymentMethod(rawValue: action.paymentMethodType) ?? .twint)
            pollingComponent?.delegate = self
            pollingComponent?.handle(action)
        }

        private func present(_ viewController: UIViewController, presentationDelegate: PresentationDelegate) {
            presentationDelegate.present(viewController: viewController)
        }

        private func handleShowError(_ errorMessage: String, componentName: String) {
            sendThirdPartyErrorEvent(
                with: errorMessage,
                componentName: componentName
            )
            let alert = UIAlertController(
                title: nil,
                message: errorMessage,
                preferredStyle: .alert
            )
            alert.addAction(
                .init(
                    title: localizedString(.dismissButton, configuration.localizationParameters),
                    style: .default,
                    handler: { _ in
                        self.delegate?.didFail(with: ComponentError.cancelled, from: self)
                    }
                )
            )
            if let presentationDelegate {
                self.present(alert, presentationDelegate: presentationDelegate)
            }
        }

        private func cleanup() {
            pollingComponent?.didCancel()
        }
        
        private func sendThirdPartyErrorEvent(with message: String?, componentName: String) {
            var errorEvent = AnalyticsEventError(
                component: componentName,
                type: .thirdParty
            )
            errorEvent.code = AnalyticsConstants.ErrorCode.thirdPartyError.stringValue
            errorEvent.message = message
            
            context.analyticsProvider?.add(error: errorEvent)
        }
    }

    extension TwintSDKActionComponent: ActionComponentDelegate {

        package func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
            cleanup()
            delegate?.didProvide(data, from: self)
        }

        package func didComplete(from component: ActionComponent) {}

        package func didFail(with error: Error, from component: ActionComponent) {
            cleanup()
            delegate?.didFail(with: error, from: self)
        }

    }
#endif
