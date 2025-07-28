//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import AdyenSession

internal protocol InitialDataFlowProtocol: AnyObject {
    var context: AdyenContext { get }
    var apiClient: APIClientProtocol { get }
    func requestSessionInitialInfo(completion: @escaping (Result<AdyenSession.InitialInfo, Error>) -> Void)
    func generateContext() -> AdyenContext
    func start()
}

extension InitialDataFlowProtocol {

    internal func requestSessionInitialInfo(completion: @escaping (Result<AdyenSession.InitialInfo, Error>) -> Void) {
        let request = SessionRequest()
        apiClient.perform(request) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(response):
                let initialInfo = AdyenSession.InitialInfo(
                    sessionIdentifier: response.sessionId,
                    initialSessionData: response.sessionData
                )
                completion(.success(initialInfo))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func generateContext() -> AdyenContext {
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = ConfigurationConstants.current.analyticsSettings.isEnabled
        return AdyenContext(
            apiContext: ConfigurationConstants.apiContext,
            payment: ConfigurationConstants.current.payment,
            amount: ConfigurationConstants.current.amount,
            analyticsConfiguration: analyticsConfiguration
        )
    }

    private func initialInfo(with sessionId: String, data: String) -> AdyenSession.InitialInfo {
        let initialInfo = AdyenSession.InitialInfo(
            sessionIdentifier: sessionId,
            initialSessionData: data
        )
        return initialInfo
    }
}

extension CheckoutResultCode {
    var isSuccess: Bool {
        self == .authorised || self == .received || self == .pending
    }
}
