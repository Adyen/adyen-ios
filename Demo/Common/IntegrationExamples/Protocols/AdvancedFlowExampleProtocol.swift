//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import AdyenSession

internal protocol AdvancedFlowExampleProtocol: AnyObject, APIClientAware {
    var context: AdyenContext { get }
    var palApiClient: APIClientProtocol { get }
    func requestPaymentMethods(order: PartialPaymentOrder?,
                               completion: ((PaymentMethods?, Error?) -> Void)?)
}

extension AdvancedFlowExampleProtocol {

    internal var context: AdyenContext {
        var analyticsConfiguration = AnalyticsConfiguration()
        analyticsConfiguration.isEnabled = true
        return AdyenContext(apiContext: ConfigurationConstants.apiContext,
                            payment: ConfigurationConstants.current.payment,
                            analyticsConfiguration: analyticsConfiguration)
    }

    internal var palApiClient: APIClientProtocol {
        let context = DemoAPIContext(environment: ConfigurationConstants.classicAPIEnvironment)
        return DefaultAPIClient(apiContext: context)
    }

    internal func requestPaymentMethods(order: PartialPaymentOrder?,
                                        completion: ((PaymentMethods?, Error?) -> Void)?) {
        let request = PaymentMethodsRequest(order: order)
        apiClient.perform(request) { result in
            switch result {
            case let .success(response):
                completion?(response.paymentMethods, nil)
            case let .failure(error):
                completion?(nil, error)
            }
        }
    }

}
