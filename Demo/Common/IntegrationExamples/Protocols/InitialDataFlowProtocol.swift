//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import AdyenSession

@MainActor
internal protocol InitialDataFlowProtocol: AnyObject {
    var apiClient: APIClientProtocol { get }
    func requestSessionInitialInfo(completion: @escaping (Result<SessionResponse, Error>) -> Void)

    func start()
}

extension InitialDataFlowProtocol {

    internal func requestSessionInitialInfo(completion: @escaping (Result<SessionResponse, Error>) -> Void) {
        let request = SessionRequest()
        apiClient.perform(request, completionHandler: completion)
    }
    
    internal func requestSessionInitialInfo(payable: Bool = true) async throws -> SessionResponse {
        let request = SessionRequest(payable: payable)
        return try await withCheckedThrowingContinuation { continuation in
            apiClient.perform(request) { result in
                continuation.resume(with: result)
            }
        }
    }
}

extension CheckoutResultCode {
    var isSuccess: Bool {
        self == .authorised || self == .received || self == .pending
    }
}
