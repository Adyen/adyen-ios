//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

/// Performs requests to the API.
/// :nodoc:
public final class APIClient {
    
    public init() {}
    
    // MARK: - Networking
    
    /// Performs a request.
    ///
    /// - Parameters:
    ///   - request: The request to perform.
    ///   - completion: The completion handler to invoke when a response has been received.
    public func perform<R: Request>(_ request: R, completion: @escaping Completion<Result<R.ResponseType>>) {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = "POST"
        urlRequest.allHTTPHeaderFields = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        
        do {
            urlRequest.httpBody = try Coder.encode(request)
        } catch {
            completion(.failure(error))
            
            return
        }
        
        urlSession.dataTask(with: urlRequest) { result in
            switch result {
            case let .success(data):
                do {
                    let response = try Coder.decode(data) as R.ResponseType
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }.resume()
    }
    
    private let urlSession = URLSession.shared
    
}

/// A request that can be sent using an APIClient.
/// :nodoc:
public protocol Request: Encodable {
    /// The type of response expected from the request.
    associatedtype ResponseType: Response
    
    /// The payment session.
    var paymentSession: PaymentSession { get }
    
    /// The payment method for which to initiate a payment.
    var paymentMethod: PaymentMethod { get }
    
    /// The payment data to submit with the request, containing the state of the session.
    var paymentData: String { get }
    
    /// The URL to which the request should be made.
    var url: URL { get }
    
}

/// The response to a request sent using an APIClient.
/// :nodoc:
public protocol Response: Decodable {}

/// :nodoc:
public extension Request {
    
    /// The payment data to submit with the request, containing the state of the session.
    var paymentData: String {
        return paymentSession.paymentData
    }
    
    /// Encodes the payment data for the request.
    ///
    /// - Parameter encoder: The encoder to encode the payment data with.
    func encodePaymentData(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(paymentData, forKey: .paymentData)
        try container.encode(paymentMethod.paymentMethodData, forKey: .paymentMethodData)
    }
    
}

private enum CodingKeys: String, CodingKey {
    case paymentData
    case paymentMethodData
}
