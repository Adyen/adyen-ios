//
//  JWAA128CBCHS256AlgorithmTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 8/18/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import XCTest
@testable import AdyenEncryption

class JWAA128CBCHS256AlgorithmTests: XCTestCase {
    
//    var validInput: JWAInput!
//
//    var invalidKeyLengthInput: JWAInput!
//
//    var invalidIVInput: JWAInput!
//
//    var sut: JWAA256CBCHS512Algorithm!
//
//    override func setUp() {
//        super.setUp()
//        sut = JWAA256CBCHS512Algorithm()
//        let key: [UInt8] = [96, 61, 235, 16, 21, 202, 113, 190, 43, 115, 174, 240, 133, 125, 119, 129, 31, 53, 44, 7, 59, 97, 8, 215, 45, 152, 16, 163, 9, 20, 223, 244]
//        let keyData = Data(bytes: key, count: key.count)
//
//        let payload: [UInt8] = [246, 159, 36, 69, 223, 79, 155, 23, 173, 43, 65, 123, 230, 108, 55, 16]
//        let payloadData = Data(bytes: payload, count: payload.count)
//
//        let initializationVector: [UInt8] = [57, 242, 51, 105, 169, 217, 186, 207, 165, 48, 226, 99, 4, 35, 20, 97]
//        let initializationVectorData = Data(bytes: initializationVector, count: initializationVector.count)
//
//        let additionalAuth: [UInt8] = [101, 121, 74, 104, 98, 71, 99, 105, 79, 105, 74, 66, 77, 84, 73, 52,
//                                       83, 49, 99, 105, 76, 67, 74, 108, 98, 109, 77, 105, 79, 105, 74, 66,
//                                       77, 84, 73, 52, 81, 48, 74, 68, 76, 85, 104, 84, 77, 106, 85, 50, 73,
//                                       110, 48]
//        let additionalAuthData = Data(bytes: additionalAuth, count: additionalAuth.count)
//        validInput = JWAInput(payload: payloadData,
//                             key: keyData,
//                             initializationVector: initializationVectorData,
//                             additionalAuthenticationData: additionalAuthData)
//
//        invalidKeyLengthInput = JWAInput(payload: payloadData,
//                                         key: keyData[0...3],
//                                         initializationVector: initializationVectorData,
//                                         additionalAuthenticationData: additionalAuthData)
//
//        invalidIVInput = JWAInput(payload: payloadData,
//                                  key: keyData,
//                                  initializationVector: initializationVectorData[0...5],
//                                  additionalAuthenticationData: additionalAuthData)
//    }
//
//    func testSuccess() throws {
//        let output = try sut.encrypt(input: validInput)
//        XCTAssertEqual(output.encryptedPayload.asBytes,
//                       [40, 57, 83, 181, 119, 33, 133, 148, 198, 185, 243, 24, 152, 230, 6,
//                                                                  75, 129, 223, 127, 19, 210, 82, 183, 230, 168, 33, 215, 104, 143,
//                                                                  112, 56, 102])
//        XCTAssertEqual(output.authenticationTag.asBytes,
//                       [83, 73, 191, 98, 104, 205, 211, 128, 201, 189, 199, 133, 32, 38,
//                                                  194, 85])
//    }
//
//    func testInvalidKeyLength() throws {
//        XCTAssertThrowsError(try sut.encrypt(input: invalidKeyLengthInput)) { error in
//            XCTAssertEqual(error as? JsonWebEncryptionError, .invalidKey)
//        }
//    }
//
//    func testInvalidIV() throws {
//        XCTAssertThrowsError(try sut.encrypt(input: invalidIVInput)) { error in
//            XCTAssertEqual(error as? JsonWebEncryptionError, .invalidInitializationVector)
//        }
//    }

}
