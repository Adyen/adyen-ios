//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
#if canImport(TwintSDK)
    import TwintSDK
#endif

#if canImport(TwintSDK)
    /// A component that handles Twint SDK action's.
    public final class TwintSDKActionComponent: ActionComponent {

        /// The context object for this component.
        @_spi(AdyenInternal)
        public let context: AdyenContext

        /// Delegates `PresentableComponent`'s presentation.
        public weak var presentationDelegate: PresentationDelegate?

        public weak var delegate: ActionComponentDelegate?

        public let requiresModalPresentation: Bool = false

        private let callback = "ui-host-twint"

        /// The TwintSDK component configurations.
        public struct Configuration {

            /// The component UI style.
            public var style: AwaitComponentStyle

            /// The localization parameters, leave it nil to use the default parameters.
            public var localizationParameters: LocalizationParameters?

            /// Initializes an instance of `Configuration`
            ///
            /// - Parameters:
            ///   - style: The Component UI style.
            ///   - localizationParameters: The localization parameters, leave it nil to use the default parameters.
            public init(style: AwaitComponentStyle = .init(),
                        localizationParameters: LocalizationParameters? = nil) {
                self.style = style
                self.localizationParameters = localizationParameters
            }
        }

        /// The twint component configurations.
        public var configuration: Configuration

        /// Initializes the `TwintSDKActionComponent`.
        ///
        /// - Parameter context: The context object for this component.
        /// - Parameter configuration: The TwintSDK component configurations.
        public init(context: AdyenContext,
                    configuration: Configuration = .init()) {
            self.context = context
            self.configuration = configuration
        }

        /// Handles TwintSDK action.
        ///
        /// - Parameter action: The Twint SDK action object.
        public func handle(_ action: TwintSDKAction) {
            AdyenAssertion.assert(message: "presentationDelegate is nil", condition: presentationDelegate == nil)
            Twint.fetchInstalledAppConfigurations { [weak self] installedApps in
                guard let self else { return }
                
                guard let installedApps, let firstApp = installedApps.first else {
                    self.handleShowError("No or an outdated version of TWINT is installed on this device. Please update or install the TWINT app.")
                    return
                }
                
                if installedApps.count > 1 {
                    self.presentAppChooser(installedApps: installedApps, code: action.sdkData.token)
                } else {
                    self.invokeTwintAppWithCode(app: firstApp, code: action.sdkData.token)
                }
            }
        }

        private func invokeTwintAppWithCode(app: TWAppConfiguration, code: String) {

            let error = Twint.pay(withCode: code, appConfiguration: app, callback: callback)
            if let error {
                AdyenAssertion.assertionFailure(message: error.localizedDescription)
            }
        }

        private func presentAppChooser(installedApps: [TWAppConfiguration], code: String) {
            let appChooserViewController = Twint.controller(for: installedApps) { [weak self] selectedApp in
                self?.invokeTwintAppWithCode(app: selectedApp ?? installedApps[0],
                                             code: code)
            } cancelHandler: { [weak self] in
                guard let self else { return }
                self.delegate?.didFail(with: ComponentError.cancelled, from: self)
            }
            
            if let viewcontroller = appChooserViewController, let delegate = presentationDelegate {
                present(viewcontroller, presentationDelegate: delegate)
            }
        }

        private func present(_ viewController: UIViewController, presentationDelegate: PresentationDelegate) {
            let toolBar = CancellingToolBar(title: nil, style: NavigationStyle())
            let presentableComponent = PresentableComponentWrapper(
                component: self,
                viewController: viewController,
                navBarType: .custom(toolBar)
            )
            presentableComponent.requiresModalPresentation = false
            toolBar.isHidden = true
            presentationDelegate.present(component: presentableComponent)
        }

        private func handleShowError(_ error: String) {
            let alert = UIAlertController(
                title: nil,
                message: error,
                preferredStyle: .alert
            )
            alert.addAction(
                .init(
                    title: localizedString(.dismissButton, configuration.localizationParameters),
                    style: .default, 
                    handler: { _ in
                        // TODO: Is this the right thing to do here? - we have to let drop-in know to hide the spinner without dismissing drop-in
                        self.delegate?.didFail(with: ComponentError.cancelled, from: self)
                    }
                )
            )
            if let presentationDelegate {
                self.present(alert, presentationDelegate: presentationDelegate)
            }
        }
    }
#endif
