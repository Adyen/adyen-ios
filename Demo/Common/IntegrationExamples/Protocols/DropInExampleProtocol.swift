//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import AdyenSession

internal protocol DropInExampleProtocol: APIClientAware {
    var palApiClient: APIClientProtocol { get }
    var context: AdyenContext { get }
    func requestAdyenSessionConfiguration(completion: ((AdyenSession.Configuration?, Error?) -> Void)?)
}

extension DropInExampleProtocol {

    var palApiClient: APIClientProtocol {
        let context = DemoAPIContext(environment: ConfigurationConstants.classicAPIEnvironment)
        return DefaultAPIClient(apiContext: context)
    }

    internal var context: AdyenContext {
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = true
        return AdyenContext(apiContext: ConfigurationConstants.apiContext,
                            payment: ConfigurationConstants.current.payment,
                            analyticsConfiguration: analyticsConfiguration)
    }

    internal func requestAdyenSessionConfiguration(completion: ((AdyenSession.Configuration?, Error?) -> Void)?) {
        let request = SessionRequest()
        apiClient.perform(request) { result in
            switch result {
            case let .success(response):
                let config = self.initializeSession(with: response.sessionId, data: response.sessionData)
                completion?(config, nil)
            case let .failure(error):
                completion?(nil, error)
            }
        }
    }

    private func initializeSession(with sessionId: String, data: String) -> AdyenSession.Configuration {
        let configuration = AdyenSession.Configuration(
            sessionIdentifier: sessionId,
            initialSessionData: data,
            context: context,
            actionComponent: .init(
                threeDS: .init(
                    requestorAppURL: URL(string: ConfigurationConstants.returnUrl),
                    delegateAuthentication: ConfigurationConstants.delegatedAuthenticationConfigurations
                )
            )
        )
        return configuration
    }
}

extension SessionPaymentResultCode {
    var isSuccess: Bool {
        self == .authorised || self == .received || self == .pending
    }
}
