//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Contains the result of a 3DS transaction.
public struct ThreeDSResult: Decodable {

    /// The payload to submit to verify the authentication.
    public let payload: String
    
    private struct Payload: Codable {
        internal let authorisationToken: String?
        internal let delegatedAuthenticationSDKOutput: String?
        internal let threeDS2SDKError: String?
        internal let transStatus: String?
    }

    internal init(authorizationToken: String?,
                  threeDS2SDKError: String?,
                  transStatus: String) throws {
        let payload = Payload(authorisationToken: authorizationToken,
                              delegatedAuthenticationSDKOutput: nil,
                              threeDS2SDKError: threeDS2SDKError,
                              transStatus: transStatus)
        self.payload = try AdyenCoder.encode(payload).base64EncodedString()
    }
    
    internal init(from challengeResult: AnyChallengeResult,
                  delegatedAuthenticationSDKOutput: String?,
                  authorizationToken: String?,
                  threeDS2SDKError: String?) throws {
        let payload = Payload(authorisationToken: authorizationToken,
                              delegatedAuthenticationSDKOutput: delegatedAuthenticationSDKOutput,
                              threeDS2SDKError: threeDS2SDKError,
                              transStatus: challengeResult.transactionStatus)

        self.payload = try AdyenCoder.encode(payload).base64EncodedString()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.payload = try container.decode(String.self, forKey: .payload)
    }
    
    internal func withDelegatedAuthenticationSDKOutput(delegatedAuthenticationSDKOutput: String?) throws -> ThreeDSResult {
        let oldPayload: Payload = try AdyenCoder.decodeBase64(payload)
        let newPayload = Payload(authorisationToken: oldPayload.authorisationToken,
                                 delegatedAuthenticationSDKOutput: delegatedAuthenticationSDKOutput,
                                 threeDS2SDKError: oldPayload.threeDS2SDKError,
                                 transStatus: oldPayload.transStatus)
        return try .init(payload: AdyenCoder.encode(newPayload).base64EncodedString())
    }

    internal init(authenticated: Bool, authorizationToken: String?) throws {
        var payloadJson = ["transStatus": authenticated ? "Y" : "N"]

        if let authorizationToken {
            payloadJson["authorisationToken"] = authorizationToken
        }

        let payloadData = try JSONSerialization.data(withJSONObject: payloadJson,
                                                     options: [])

        self.payload = payloadData.base64EncodedString()
    }

    internal init(payload: String) {
        self.payload = payload
    }

    private enum CodingKeys: String, CodingKey {
        case payload = "threeDSResult"
    }

}
