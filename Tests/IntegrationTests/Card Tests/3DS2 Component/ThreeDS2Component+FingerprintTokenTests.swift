//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenActions
import XCTest
@_spi(AdyenInternal) import Adyen

@available(iOS 16.0, *)
extension ThreeDS2ComponentTests {
    func testParsingTokenWithFeaturesInConfiguration() throws {
        let token = """
        eyJjb25maWd1cmF0aW9uIjp7ImZlYXR1cmVGbGFncyI6eyJmZWF0dXJlQSI6ZmFsc2UsImZlYXR1cmVCIjp0cnVlfSwidmVyc2lvbiI6IjEuMCJ9LCJkaXJlY3RvcnlTZXJ2ZXJJZCI6IkYwMTMzNzEzMzciLCJkaXJlY3RvcnlTZXJ2ZXJQdWJsaWNLZXkiOiJkaXJlY3RvcnlTZXJ2ZXJQdWJsaWNLZXkiLCJkaXJlY3RvcnlTZXJ2ZXJSb290Q2VydGlmaWNhdGVzIjoiZGlyZWN0b3J5U2VydmVyUm9vdENlcnRpZmljYXRlcyIsInRocmVlRFNNZXNzYWdlVmVyc2lvbiI6IjIuMi4wIiwidGhyZWVEU1NlcnZlclRyYW5zSUQiOiJiNzljZjg5MS1kNmRjLTQ1MmItOWFjMi00ZWZiYWJjMWU0MjMifQ==
        """
        let fingerprintToken = try AdyenCoder.decodeBase64(token) as ThreeDS2Component.FingerprintToken
        let configuration = try XCTUnwrap(fingerprintToken.configuration)
        XCTAssertFalse(configuration.isFeatureEnabled("featureA"))
        XCTAssertTrue(configuration.isFeatureEnabled("featureB"))
    }
    
    func testParsingTokenWithUnsupportedConfigurationVersion() throws {
        let token = """
        eyJjb25maWd1cmF0aW9uIjp7ImZlYXR1cmVGbGFncyI6eyJmZWF0dXJlQSI6IkFCQyIsImZlYXR1cmVCIjoiREVGIn0sInZlcnNpb24iOiIyLjAifSwiZGlyZWN0b3J5U2VydmVySWQiOiJGMDEzMzcxMzM3IiwiZGlyZWN0b3J5U2VydmVyUHVibGljS2V5IjoiZGlyZWN0b3J5U2VydmVyUHVibGljS2V5IiwiZGlyZWN0b3J5U2VydmVyUm9vdENlcnRpZmljYXRlcyI6ImRpcmVjdG9yeVNlcnZlclJvb3RDZXJ0aWZpY2F0ZXMiLCJ0aHJlZURTTWVzc2FnZVZlcnNpb24iOiIyLjIuMCIsInRocmVlRFNTZXJ2ZXJUcmFuc0lEIjoiYjc5Y2Y4OTEtZDZkYy00NTJiLTlhYzItNGVmYmFiYzFlNDIzIn0=
        """
        let fingerprintToken = try AdyenCoder.decodeBase64(token) as ThreeDS2Component.FingerprintToken
        let configuration = try XCTUnwrap(fingerprintToken.configuration)
        XCTAssertNil(configuration.featureFlags)
    }
    
    func testParsingTokenWithoutConfiguration() throws {
        let token = """
        eyJkZWxlZ2F0ZWRBdXRoZW50aWNhdGlvblNES0lucHV0IjoiIyNTb21lZGVsZWdhdGVkQXV0aGVudGljYXRpb25TREtJbnB1dCMjIiwiZGlyZWN0b3J5U2VydmVySWQiOiJGMDEzMzcxMzM3IiwiZGlyZWN0b3J5U2VydmVyUHVibGljS2V5IjoiI0RpcmVjdG9yeVNlcnZlclB1YmxpY0tleSMiLCJkaXJlY3RvcnlTZXJ2ZXJSb290Q2VydGlmaWNhdGVzIjoiIyNEaXJlY3RvcnlTZXJ2ZXJSb290Q2VydGlmaWNhdGVzIyMiLCJ0aHJlZURTTWVzc2FnZVZlcnNpb24iOiIyLjIuMCIsInRocmVlRFNTZXJ2ZXJUcmFuc0lEIjoiMTUwZmEzYjgtZTZjOC00N2ExLTk2ZTAtOTEwNzYzYmVlYzU3In0=
        """
        let fingerprintToken = try AdyenCoder.decodeBase64(token) as ThreeDS2Component.FingerprintToken
        XCTAssertNil(fingerprintToken.configuration)
    }
}
