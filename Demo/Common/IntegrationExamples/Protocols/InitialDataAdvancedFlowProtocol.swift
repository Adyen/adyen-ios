//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import AdyenSession

protocol InitialDataAdvancedFlowProtocol: AnyObject, APIClientAware {
    var context: AdyenContext { get }
    var palApiClient: APIClientProtocol { get }
    func requestPaymentMethods(order: PartialPaymentOrder?,
                               completion: @escaping (Result<PaymentMethods, Error>) -> Void)
}

extension InitialDataAdvancedFlowProtocol {

    var context: AdyenContext {
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = ConfigurationConstants.current.analyticsSettings.isEnabled
        return AdyenContext(apiContext: ConfigurationConstants.apiContext,
                            payment: ConfigurationConstants.current.payment,
                            analyticsConfiguration: analyticsConfiguration)
    }

    var palApiClient: APIClientProtocol {
        let context = DemoAPIContext(environment: ConfigurationConstants.classicAPIEnvironment)
        return DefaultAPIClient(apiContext: context)
    }

    func requestPaymentMethods(order: PartialPaymentOrder?,
                               completion: @escaping (Result<PaymentMethods, Error>) -> Void) {
        let request = PaymentMethodsRequest(order: order)
        apiClient.perform(request) { result in
            switch result {
            case let .success(response):
                completion(.success(response.paymentMethods))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

}
