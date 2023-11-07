//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import AdyenSession

internal protocol InitialDataFlowProtocol: ExampleComponentProtocol {
    func requestAdyenSessionConfiguration(completion: @escaping (Result<AdyenSession.Configuration, Error>) -> Void)
}

extension InitialDataFlowProtocol {

    internal func requestAdyenSessionConfiguration(completion: @escaping (Result<AdyenSession.Configuration, Error>) -> Void) {
        let request = SessionRequest()
        apiClient.perform(request) { result in
            switch result {
            case let .success(response):
                let config = Self.initializeSession(with: response.sessionId, data: response.sessionData)
                completion(.success(config))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private static func initializeSession(with sessionId: String, data: String) -> AdyenSession.Configuration {
        let configuration = AdyenSession.Configuration(
            sessionIdentifier: sessionId,
            initialSessionData: data,
            context: Self.context,
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
