//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Used for requests made to the CheckoutShopper API.
internal class PaymentServer {
    
    // MARK: - Internal
    
    internal let paymentSetup: PaymentSetup
    
    internal init(paymentSetup: PaymentSetup) {
        self.paymentSetup = paymentSetup
    }
    
    internal static let redirectSessionConfiguration: URLSessionConfiguration = {
        // This is necessary because some payment method providers, i.e. Rabobank,
        // only expect the redirect URL to come from a browser, otherwise they redirect to desktop site.
        // In the browser the user agent corresponds to Safari, whereas the default user agent corresponds to the app.
        
        let configuration = URLSessionConfiguration.default
        
        let semaphore = DispatchSemaphore(value: 0)
        var safariUserAgent: String?
        
        DispatchQueue.main.async {
            // Web view can only be created on main thread. Otherwise app crashes.
            let webView = UIWebView()
            safariUserAgent = webView.stringByEvaluatingJavaScript(from: "navigator.userAgent")
            semaphore.signal()
        }
        
        semaphore.wait()
        
        if let safariUserAgent = safariUserAgent {
            configuration.httpAdditionalHeaders = [
                "User-Agent": safariUserAgent
            ]
        }
        
        return configuration
    }()
    
    internal func initiatePayment(for paymentMethod: PaymentMethod, completion: @escaping Completion<PaymentInitiation>) {
        var parameters: [String: Any] = [
            "paymentData": paymentSetup.paymentData,
            "paymentMethodData": paymentMethod.paymentMethodData
        ]
        
        if var serializedPaymentDetails = paymentMethod.fulfilledPaymentDetails?.serialized {
            if let providedAdditionalRequiredFields = paymentMethod.providedAdditionalRequiredFields {
                serializedPaymentDetails.formUnion(providedAdditionalRequiredFields)
            }
            
            parameters["paymentDetails"] = serializedPaymentDetails
        }
        
        post(paymentSetup.initiationURL, parameters: parameters) { dictionary, error in
            var paymentInitiation: PaymentInitiation?
            
            if let dictionary = dictionary {
                paymentInitiation = PaymentInitiation(dictionary: dictionary)
            }
            
            completion(paymentInitiation, error)
        }
        
    }
    
    internal func deletePreferredPaymentMethod(_ paymentMethod: PaymentMethod, completion: @escaping Completion<[String: Any]>) {
        let parameters = [
            "paymentData": paymentSetup.paymentData,
            "paymentMethodData": paymentMethod.paymentMethodData
        ]
        
        post(paymentSetup.deletePreferredPaymentMethodURL, parameters: parameters, completion: completion)
    }
    
    internal typealias Completion<ResponseType> = (_ response: ResponseType?, _ error: Error?) -> Void
    
    // MARK: - Private
    
    private let session = URLSession(configuration: .default)
    
    private func post(_ url: URL, parameters: [String: Any], completion: @escaping (_ info: [String: Any]?, _ error: Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        
        _ = session.dataTask(with: request) { data, response, error in
            guard
                let rawData = data,
                let json = try? JSONSerialization.jsonObject(with: rawData, options: []) as? [String: Any]
            else {
                if let error = error {
                    completion(nil, .networkError(error))
                } else {
                    completion(nil, .unexpectedData)
                }
                return
            }
            
            completion(json, nil)
            
        }.resume()
    }
}
