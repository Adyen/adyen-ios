//
//  JWAA256CBCHS512AlgorithmTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 8/18/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@testable import AdyenEncryption
import XCTest

/// Using test fixtures from [here] (https://tools.ietf.org/id/draft-mcgrew-aead-aes-cbc-hmac-sha2-03.html#rfc.section.2.7)
class JWAA256CBCHS512AlgorithmTests: XCTestCase {
    
    var validInput: JWAInput!

    var invalidKeyLengthInput: JWAInput!

    var invalidIVInput: JWAInput!

    var sut: JWAA256CBCHS512Algorithm!

    override func setUp() {
        super.setUp()
        sut = JWAA256CBCHS512Algorithm()
        let key: [UInt8] = byteArray(from: "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63")
        let keyData = Data(bytes: key, count: key.count)

        let payload: [UInt8] = byteArray(from: "65 32 99 105 112 104 101 114 32 115 121 115 116 101 109 32 109 117 115 116 32 110 111 116 32 98 101 32 114 101 113 117 105 114 101 100 32 116 111 32 98 101 32 115 101 99 114 101 116 44 32 97 110 100 32 105 116 32 109 117 115 116 32 98 101 32 97 98 108 101 32 116 111 32 102 97 108 108 32 105 110 116 111 32 116 104 101 32 104 97 110 100 115 32 111 102 32 116 104 101 32 101 110 101 109 121 32 119 105 116 104 111 117 116 32 105 110 99 111 110 118 101 110 105 101 110 99 101")
        let payloadData = Data(bytes: payload, count: payload.count)

        let initializationVector: [UInt8] = byteArray(from: "26 243 140 45 194 185 111 253 216 102 148 9 35 65 188 4")
        let initializationVectorData = Data(bytes: initializationVector, count: initializationVector.count)

        let additionalAuth: [UInt8] = byteArray(from: "84 104 101 32 115 101 99 111 110 100 32 112 114 105 110 99 105 112 108 101 32 111 102 32 65 117 103 117 115 116 101 32 75 101 114 99 107 104 111 102 102 115")
        let additionalAuthData = Data(bytes: additionalAuth, count: additionalAuth.count)
        validInput = JWAInput(payload: payloadData,
                              key: keyData,
                              initializationVector: initializationVectorData,
                              additionalAuthenticationData: additionalAuthData)

        invalidKeyLengthInput = JWAInput(payload: payloadData,
                                         key: keyData[0...3],
                                         initializationVector: initializationVectorData,
                                         additionalAuthenticationData: additionalAuthData)

        invalidIVInput = JWAInput(payload: payloadData,
                                  key: keyData,
                                  initializationVector: initializationVectorData[0...5],
                                  additionalAuthenticationData: additionalAuthData)
    }

    func testSuccess() throws {
        let output = try sut.encrypt(input: validInput)
        let expectedEncryptedPayload = byteArray(from: "74 255 170 173 183 140 49 197 218 75 27 89 13 16 255 189 61 216 213 211 2 66 53 38 145 45 160 55 236 188 199 189 130 44 48 29 214 124 55 59 204 181 132 173 62 146 121 194 230 209 42 19 116 183 127 7 117 83 223 130 148 16 68 107 54 235 217 112 102 41 106 230 66 126 167 92 46 8 70 161 26 9 204 245 55 13 200 11 254 203 173 40 199 63 9 179 163 183 94 102 42 37 148 65 10 228 150 178 226 230 96 158 49 230 224 44 200 55 240 83 210 31 55 255 79 81 149 11 190 38 56 208 157 215 164 147 9 48 128 109 7 3 177 246")
        XCTAssertEqual(output.encryptedPayload.asBytes.count, expectedEncryptedPayload.count)
        XCTAssertEqual(output.encryptedPayload.asBytes, expectedEncryptedPayload)
        
        let expectedAuthenticationTag = byteArray(from: "77 211 180 192 136 167 244 92 33 104 57 100 91 32 18 191 46 98 105 168 197 106 129 109 188 27 38 119 97 149 91 197")
        XCTAssertEqual(output.authenticationTag.asBytes.count, expectedAuthenticationTag.count)
        XCTAssertEqual(output.authenticationTag.asBytes, expectedAuthenticationTag)
    }
    
    private func byteArray(from string: String) -> [UInt8] {
        string.split(separator: " ").compactMap { UInt8($0) }
    }

    func testInvalidKeyLength() throws {
        XCTAssertThrowsError(try sut.encrypt(input: invalidKeyLengthInput)) { error in
            XCTAssertEqual(error.localizedDescription, EncryptionError.invalidKey.localizedDescription)
        }
    }

    func testInvalidIV() throws {
        XCTAssertThrowsError(try sut.encrypt(input: invalidIVInput)) { error in
            XCTAssertEqual(error.localizedDescription, EncryptionError.invalidInitializationVector.localizedDescription)
        }
    }

}
