//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Adyen3DS2
import Foundation

internal protocol AnyRedirectComponent: ActionComponent {
    func handle(_ action: RedirectAction)
}

/// Handles the 3D Secure 2 fingerprint and challenge.
public final class ThreeDS2Component: ActionComponent {
    
    /// The context object for this component.
    @_spi(AdyenInternal)
    public let context: AdyenContext
    
    /// The delegate of the component.
    public weak var delegate: ActionComponentDelegate?

    /// Delegates `PresentableComponent`'s presentation.
    public weak var presentationDelegate: PresentationDelegate?
    
    /// Three DS2 component configurations.
    public var configuration: Configuration {
        didSet {
            updateConfiguration()
        }
    }
    
    /// Three DS2 component configurations.
    public struct Configuration {
        
        /// ``RedirectComponent`` style
        public var redirectComponentStyle: RedirectComponentStyle?
        
        /// The appearance configuration of the 3D Secure 2 challenge UI.
        public var appearanceConfiguration = ADYAppearanceConfiguration()
        
        /// `threeDSRequestorAppURL` for protocol version 2.2.0 OOB challenges
        public var requestorAppURL: URL?
        
        /// The configuration for Delegated Authentication.
        public let delegateAuthentication: DelegatedAuthentication?
        
        /// The configuration for Delegated Authentication.
        public struct DelegatedAuthentication {
            /// The localized reason string show to the user during registration.
            public let localizedRegistrationReason: String

            /// The localized reason string show to the user during authentication.
            public let localizedAuthenticationReason: String

            /// The Apple registered development team identifier.
            public let appleTeamIdentifier: String

            /// Initializes a new instance.
            ///
            /// - Parameter localizedRegistrationReason: The localized reason string show to the user while registration flow.
            /// - Parameter localizedAuthenticationReason: The localized reason string show to the user while authentication flow.
            /// - Parameter appleTeamIdentifier: The Apple registered development team identifier.
            public init(localizedRegistrationReason: String, localizedAuthenticationReason: String, appleTeamIdentifier: String) {
                self.localizedRegistrationReason = localizedRegistrationReason
                self.localizedAuthenticationReason = localizedAuthenticationReason
                self.appleTeamIdentifier = appleTeamIdentifier
            }
        }
        
        /// Initializes a new instance
        ///
        /// - Parameters:
        ///   - redirectComponentStyle: `RedirectComponent` style
        ///   - appearanceConfiguration: The appearance configuration of the 3D Secure 2 challenge UI.
        ///   - requestorAppURL: `threeDSRequestorAppURL` for protocol version 2.2.0 OOB challenges
        public init(redirectComponentStyle: RedirectComponentStyle? = nil,
                    appearanceConfiguration: ADYAppearanceConfiguration = ADYAppearanceConfiguration(),
                    requestorAppURL: URL? = nil,
                    delegateAuthentication: DelegatedAuthentication? = nil) {
            self.redirectComponentStyle = redirectComponentStyle
            self.appearanceConfiguration = appearanceConfiguration
            self.requestorAppURL = requestorAppURL
            self.delegateAuthentication = delegateAuthentication
        }
    }
    
    /// Initializes the 3D Secure 2 component.
    ///
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The component's configuration.
    public init(context: AdyenContext,
                configuration: Configuration = Configuration()) {
        self.context = context
        self.configuration = configuration
        self.updateConfiguration()
    }
    
    /// Initializes the 3D Secure 2 component.
    ///
    /// - Parameters:
    ///   - context: The  Adyen context.
    ///   - threeDS2CompactFlowHandler: The internal `AnyThreeDS2ActionHandler` for the compact flow.
    ///   - threeDS2ClassicFlowHandler: The internal `AnyThreeDS2ActionHandler` for the classic flow.
    ///   - redirectComponent: The redirect component.
    ///   - redirectComponentStyle: `RedirectComponent` style.
    internal convenience init(context: AdyenContext,
                              threeDS2CompactFlowHandler: AnyThreeDS2ActionHandler,
                              threeDS2ClassicFlowHandler: AnyThreeDS2ActionHandler,
                              redirectComponent: AnyRedirectComponent,
                              configuration: Configuration = Configuration()) {
        self.init(context: context,
                  configuration: configuration)
        self.threeDS2CompactFlowHandler = threeDS2CompactFlowHandler
        self.threeDS2ClassicFlowHandler = threeDS2ClassicFlowHandler
        self.redirectComponent = redirectComponent
        self.updateConfiguration()
    }
    
    private func updateConfiguration() {
        let threeDSRequestorAppURL = configuration.requestorAppURL
        threeDS2ClassicFlowHandler.threeDSRequestorAppURL = threeDSRequestorAppURL
        threeDS2CompactFlowHandler.threeDSRequestorAppURL = threeDSRequestorAppURL
    }

    // MARK: - 3D Secure 2 action
    
    /// Handles the 3D Secure 2 action.
    ///
    /// - Parameter threeDS2Action: The 3D Secure 2 action as received from the Checkout API.
    public func handle(_ threeDS2Action: ThreeDS2Action) {
        switch threeDS2Action {
        case let .fingerprint(fingerprintAction):
            threeDS2CompactFlowHandler.handle(fingerprintAction) { [weak self] result in
                self?.didReceive(result, paymentData: nil)
            }
        case let .challenge(challengeAction):
            threeDS2CompactFlowHandler.handle(challengeAction) { [weak self] result in
                self?.didReceive(result, paymentData: nil)
            }
        }
    }

    // MARK: - Fingerprint

    /// Handles the 3D Secure 2 fingerprint action.
    ///
    /// - Parameter fingerprintAction: The fingerprint action as received from the Checkout API.
    public func handle(_ fingerprintAction: ThreeDS2FingerprintAction) {
        threeDS2ClassicFlowHandler.handle(fingerprintAction) { [weak self] result in
            self?.didReceive(result, paymentData: fingerprintAction.paymentData)
        }
    }
    
    // MARK: - Challenge
    
    /// Handles the 3D Secure 2 challenge action.
    ///
    /// - Parameter challengeAction: The challenge action as received from the Checkout API.
    public func handle(_ challengeAction: ThreeDS2ChallengeAction) {
        threeDS2ClassicFlowHandler.handle(challengeAction) { [weak self] result in
            self?.didReceive(result, paymentData: challengeAction.paymentData)
        }
    }
    
    // MARK: - Private

    private func didReceive(_ result: Result<ThreeDSActionHandlerResult, Swift.Error>, paymentData: String?) {
        switch result {
        case let .success(result):
            didReceive(result, paymentData: paymentData)
        case let .failure(error):
            didFail(with: error)
        }
    }

    private func didReceive(_ result: ThreeDSActionHandlerResult, paymentData: String?) {
        switch result {
        case let .action(action):
            didReceive(action)
        case let .details(details):
            let data = ActionComponentData(details: details, paymentData: paymentData)
            didFinish(data: data)
        }
    }

    private func didReceive(_ action: Action) {
        switch action {
        case let .redirect(redirectAction):
            redirectComponent.handle(redirectAction)
        case let .threeDS2(threeDS2Action):
            handle(threeDS2Action)
        default:
            didFail(with: Error.unexpectedAction)
        }
    }

    private func didFinish(data: ActionComponentData) {
        delegate?.didProvide(data, from: self)
    }

    private func didFail(with error: Swift.Error) {
        delegate?.didFail(with: error, from: self)
    }

    internal lazy var threeDS2CompactFlowHandler: AnyThreeDS2ActionHandler = {
        let handler = ThreeDS2CompactActionHandler(context: context,
                                                   appearanceConfiguration: configuration.appearanceConfiguration,
                                                   delegatedAuthenticationConfiguration: configuration.delegateAuthentication)

        handler._isDropIn = _isDropIn
        handler.threeDSRequestorAppURL = configuration.requestorAppURL

        return handler
    }()

    internal lazy var threeDS2ClassicFlowHandler: AnyThreeDS2ActionHandler = {
        let handler = ThreeDS2ClassicActionHandler(context: context,
                                                   appearanceConfiguration: configuration.appearanceConfiguration,
                                                   delegatedAuthenticationConfiguration: configuration.delegateAuthentication)
        handler._isDropIn = _isDropIn
        handler.threeDSRequestorAppURL = configuration.requestorAppURL

        return handler
    }()

    private lazy var redirectComponent: AnyRedirectComponent = {
        let component = RedirectComponent(context: context)
        component.configuration.style = configuration.redirectComponentStyle

        component.delegate = self
        component._isDropIn = _isDropIn
        component.presentationDelegate = presentationDelegate

        return component
    }()
}

// This is for the RedirectComponent inside the ThreeDS2Component
extension ThreeDS2Component: ActionComponentDelegate {

    public func didOpenExternalApplication(component: ActionComponent) {
        delegate?.didOpenExternalApplication(component: self)
    }

    public func didProvide(_ data: ActionComponentData, from component: ActionComponent) {
        delegate?.didProvide(data, from: self)
    }

    public func didComplete(from component: ActionComponent) {
        delegate?.didComplete(from: self)
    }

    public func didFail(with error: Swift.Error, from component: ActionComponent) {
        delegate?.didFail(with: error, from: self)
    }

}

extension ThreeDS2Component {

    /// An error that occurred during the use of the 3D Secure 2 component.
    public enum Error: Swift.Error {

        /// Indicates that the challenge action was provided while no 3D Secure transaction was active.
        /// This is likely the result of calling handle(_:) with a challenge action after the challenge was already completed,
        /// or before a fingerprint action was provided.
        case missingTransaction

        /// Indicates that the Checkout API returned an unexpected `Action` during processing the 3DS2 flow.
        case unexpectedAction

    }

}
