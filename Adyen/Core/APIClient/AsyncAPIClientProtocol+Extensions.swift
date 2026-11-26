//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

extension AsyncAPIClientProtocol {

    /// Convenience method to match the signature of the response to the non async version.
    @MainActor package func performAsync<R: Request>(_ request: sending R) async throws -> R.ResponseType {
        // TODO: Robert: Swift6: This may be of a concern
        
        // AdyenNetworking does not declare its clients `Sendable`. `perform(_:)` always ran off the main actor;
        // conformers hold only immutable state or isolate themselves. Remove once AdyenNetworking adopts `Sendable`.
        nonisolated(unsafe) let client = self
        do {
            return try await client.perform(request).responseBody
        } catch let error as HTTPErrorResponse<R.ErrorResponseType> {
            throw error.responseBody
        } catch let error as ParsingError {
            throw error.underlyingError
        }
    }
}
