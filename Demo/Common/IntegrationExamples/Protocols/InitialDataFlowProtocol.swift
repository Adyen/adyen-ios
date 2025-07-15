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
    func requestSessionSetupModel(completion: @escaping (Result<AdyenSession.SetupModel, Error>) -> Void)
    func generateContext() -> AdyenContext
    func start()
}

extension InitialDataFlowProtocol {

    internal func requestSessionSetupModel(completion: @escaping (Result<AdyenSession.SetupModel, Error>) -> Void) {
        let request = SessionRequest()
        apiClient.perform(request) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(response):
                let setupModel = self.initializeModel(with: response.sessionId, data: response.sessionData)
                completion(.success(setupModel))
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

    private func initializeModel(with sessionId: String, data: String) -> AdyenSession.SetupModel {
        let setupModel = AdyenSession.SetupModel(
            sessionIdentifier: sessionId,
            initialSessionData: data
        )
        return setupModel
    }
}

extension CheckoutResultCode {
    var isSuccess: Bool {
        self == .authorised || self == .received || self == .pending
    }
}
