//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import AdyenSession

internal protocol InitialDataAdvancedFlowProtocol: AnyObject {
    var context: AdyenContext { get }
    var apiClient: APIClientProtocol { get }
    func requestPaymentMethods(order: PartialPaymentOrder?,
                               completion: @escaping (Result<PaymentMethods, Error>) -> Void)
}

extension InitialDataAdvancedFlowProtocol {

    internal var context: AdyenContext {
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = ConfigurationConstants.current.analyticsSettings.isEnabled
        return AdyenContext(apiContext: ConfigurationConstants.apiContext,
                            payment: ConfigurationConstants.current.payment,
                            analyticsConfiguration: analyticsConfiguration)
    }

    internal func requestPaymentMethods(order: PartialPaymentOrder?,
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
