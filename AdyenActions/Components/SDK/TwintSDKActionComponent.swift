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
    struct TwintActionDetails: AdditionalDetails {}

    /// A component that handles Twint SDK action's.
    public final class TwintSDKActionComponent: ActionComponent {

        /// The context object for this component.
        @_spi(AdyenInternal)
        public let context: AdyenContext

        /// Delegates `PresentableComponent`'s presentation.
        public weak var presentationDelegate: PresentationDelegate?

        public weak var delegate: ActionComponentDelegate?

        public let requiresModalPresentation: Bool = false

        /// The TwintSDK component configurations.
        public struct Configuration {

            /// The component UI style.
            public var style: AwaitComponentStyle

            /// The localization parameters, leave it nil to use the default parameters.
            public var localizationParameters: LocalizationParameters?
            
            public let returnUrl: String

            /// Initializes an instance of `Configuration`
            ///
            /// - Parameters:
            ///   - style: The Component UI style.
            ///   - localizationParameters: The localization parameters, leave it nil to use the default parameters.
            public init(
                style: AwaitComponentStyle = .init(),
                returnUrl: String,
                localizationParameters: LocalizationParameters? = nil
            ) {
                self.style = style
                self.localizationParameters = localizationParameters
                self.returnUrl = returnUrl
            }
        }

        /// The twint component configurations.
        public var configuration: Configuration
        
        private let twint: Twint

        /// Initializes the `TwintSDKActionComponent`.
        ///
        /// - Parameter context: The context object for this component.
        /// - Parameter configuration: The TwintSDK component configurations.
        public init(
            context: AdyenContext,
            configuration: Configuration
        ) {
            self.context = context
            self.configuration = configuration
            self.twint = Twint()
        }
        
        internal init(
            context: AdyenContext,
            configuration: Configuration,
            twint: Twint
        ) {
            self.context = context
            self.configuration = configuration
            self.twint = twint
        }

        /// Handles TwintSDK action.
        ///
        /// - Parameter action: The Twint SDK action object.
        public func handle(_ action: TwintSDKAction) {
            AdyenAssertion.assert(message: "presentationDelegate is nil", condition: presentationDelegate == nil)
            twint.fetchInstalledAppConfigurations { [weak self] installedApps in
                guard let self else { return }
                
                guard let firstApp = installedApps.first else {
                    self.handleShowError("No or an outdated version of TWINT is installed on this device. Please update or install the TWINT app.")
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

            let error = twint.pay(
                withCode: action.sdkData.token,
                appConfiguration: app,
                callback: configuration.returnUrl
            )
            
            if let error {
                handleShowError(error.localizedDescription)
                return
            }
            
            RedirectListener.registerForURL { [weak self] url in
                self?.twint.handleOpen(url) { [weak self] error in
                    self?.handlePaymentResult(error: error, action: action)
                }
            }
        }

        private func presentAppChooser(for installedApps: [TWAppConfiguration], action: TwintSDKAction) {
            let appChooserViewController = twint.controller(
                for: installedApps,
                selectionHandler: { [weak self] in
                    self?.invokeTwint(
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
            
            if let error, (error as NSError).code != TWErrorCode.B_SUCCESS.rawValue {
                delegate.didFail(with: error, from: self)
                return
            }
            
            let data = ActionComponentData(
                details: TwintActionDetails(),
                paymentData: action.paymentData
            )
            
            delegate.didProvide(data, from: self)
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
