//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

extension AsyncAPIClientProtocol {

    /// Convenience method to match the signature of the response to the non async version.
    package func performAsync<R: Request>(_ request: R) async throws -> R.ResponseType {
        do {
            return try await perform(request).responseBody
        } catch let error as HTTPErrorResponse<R.ErrorResponseType> {
            throw error.responseBody
        } catch let error as ParsingError {
            throw error.underlyingError
        }
    }
}
