//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// Contains the result of a 3DS transaction.
public struct ThreeDSResult: Decodable {

    /// The payload to submit to verify the authentication.
    public let payload: String
    
    private struct Payload: Codable {
        internal let authorisationToken: String?
        
        internal let delegatedAuthenticationSDKOutput: String?
        
        internal let transStatus: String?
    }

    internal init(from challengeResult: AnyChallengeResult,
                  delegatedAuthenticationSDKOutput: String?,
                  authorizationToken: String?) throws {
        let payload = Payload(authorisationToken: authorizationToken,
                              delegatedAuthenticationSDKOutput: delegatedAuthenticationSDKOutput,
                              transStatus: challengeResult.transactionStatus)
        
        let payloadData = try JSONEncoder().encode(payload)

        self.payload = payloadData.base64EncodedString()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.payload = try container.decode(String.self, forKey: .payload)
    }
    
    internal func withDelegatedAuthenticationSDKOutput(delegatedAuthenticationSDKOutput: String?) throws -> ThreeDSResult {
        let oldPayload: Payload = try Coder.decodeBase64(payload)
        let newPayload = Payload(authorisationToken: oldPayload.authorisationToken,
                                 delegatedAuthenticationSDKOutput: delegatedAuthenticationSDKOutput,
                                 transStatus: oldPayload.transStatus)
        let newPayloadData = try JSONEncoder().encode(newPayload)
        return .init(payload: newPayloadData.base64EncodedString())
    }

    internal init(authenticated: Bool, authorizationToken: String?) throws {
        var payloadJson = ["transStatus": authenticated ? "Y" : "N"]

        if let authorizationToken = authorizationToken {
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
