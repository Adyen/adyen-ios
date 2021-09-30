//
//  RSAOAEP256AlgorithmTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 8/18/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@testable import AdyenEncryption
import Security
import XCTest

class RSAOAEP256AlgorithmTests: XCTestCase {

    func testSuccess() throws {
        let sut = RSAOAEP256Algorithm()
        let publicKey = try createSecKey(fromModulus: "a43f364bde8a3f6fcb417df2289c2f6f1d6f202da34b31a8cbc33f39f0911158d0e750af246b74659cbd1f71fa00f1cd2ec80cc18b72c8d0212dcf94f68e4d6b3dd4e2068e7f7e95347d1b21d7f4622602b08f76d3c8775fc5a448717288909dded87a11c3be42fe887518e96eb11fc45e7a37e8ba5b4a7667d5c98d53e8b6808af9a4e0b027671f41dfaa721eab8a728261ed2f04498b497ca4c4d9d9bd57e37f6698395cd9454696236f6163984de8d53563ea080f5810c004addc1332f5c970d7e5eaa874312b0670c16e6bb381e00e7c27d5177a424a232a9f04c6e7ebf597f1cbdd6840d4a1b6bc95aebcc00c5c7b9154b0a7ab32092c86f3a13dc652b1", exponent: "10001")
        let payload = "66 28 19 4e 12 07 3d b0 3b a9 4c da 9e f9 53 23 97 d5 0d ba 79 b9 87 00 4a fe fe 34".hexadecimal!
        let cipherText = try sut.encrypt(payload, withKey: publicKey)
        print(cipherText.asBytes)
        
        var error: Unmanaged<CFError>?
        let keyData = Data(base64Encoded: "MIIEpAIBAAKCAQEApD82S96KP2/LQX3yKJwvbx1vIC2jSzGoy8M/OfCREVjQ51CvJGt0ZZy9H3H6APHNLsgMwYtyyNAhLc+U9o5Naz3U4gaOf36VNH0bIdf0YiYCsI9208h3X8WkSHFyiJCd3th6EcO+Qv6IdRjpbrEfxF56N+i6W0p2Z9XJjVPotoCK+aTgsCdnH0HfqnIeq4pygmHtLwRJi0l8pMTZ2b1X439mmDlc2UVGliNvYWOYTejVNWPqCA9YEMAErdwTMvXJcNfl6qh0MSsGcMFua7OB4A58J9UXekJKIyqfBMbn6/WX8cvdaEDUoba8la68wAxce5FUsKerMgkshvOhPcZSsQIDAQABAoIBAQCdxLp7FkDlvpUXS8uYhq5ppXRhDHWWfRUO5XWOSi6O4ymHiFE0QqOEF5Ly6aCj16CoFzFpmHGhw4qbXpJQY1CqerJKitHGVeksih/N2oq83JYo0yXpON6x+D9d9tt1orSCop5fAg94etbI5C0WTr2c+sObgMnBdz1VcF4yiy82XabPR3IcrFBDxDBLuUdjupvhjJUocVubst14ao0ABD6MessG472oAZ/TzcVsyOB+AVkp+djpS5mx2INzAQ5a6up4A/YHK7J5en6b0Y46+lZeVCD2IBLh9xcO8s52dJb7IpStAhy7DjjtkKi6bjq9yCtlgqei2OaaFBW9ZBDrqlyhAoGBAOTgYsQ9U8+kOTd0W519gZMuYp9Mek5kqE2BxLK11ftJVoBz2rxdGvl6B8XbSjTfcYLyhs0lXJKoFbtB8QrSLdXO2o7TgEvDGOpjHEz4x2Uh8tLU/XwbIiXDvnewGl3orriFNgnz3HW5JDOdTVd2OOFjg7ELri+zx5eb8whcRIxnAoGBALe2GwiejpHaJDIeK4ISBA8iYgvbB6vIdB8eBeOf2S7sXU+r35nEnlias+C4schilYwwPiVtyjcOWGm2VatiJGuZ/jGqQ0iVcpnt5HaqjQvSqJiXtbQnOe+10mHJdDxCveknMqjALmpP488IfQcGV2VvxPkFPJdtOwsaddHIHjknAoGBAIaoNbO7WToLJtankNdB5iBP5BpRBoxk0Fh5ht6V+QVVCp2cjA7SwHITB8uyzx/4bnJaelDsMGDgn5iCnWx+aBUpFJF/gjYQ3PHZyebHX5jytkiwo0qHNDn/xmnopDqoEVPim/6TCRwCB3iOjdhtZ93DjNF3S84o+b8LM5uxnWr1AoGAcYGGenDczajmLEEPyLGw6FjqE0ElIDId7Qvzv4wH+EH59TvQT4V4AG61LOdwkMq4c4FrJF0NT68BWW9axyVAM2tV7wGvyKztvcWKHveJZgCmQoGZttF1rnG8psZ9lq32AJRDbJgxFWZ+7m/kL+7vGLFSFjnyEe1fSaDzosXuRokCgYBs/7I2We1oCHWQp3xx3aq5n+CyyZli5+vh2GvQEQmkraEpQOEx6f0rfBgrYB7KSdNz5j+Olxk3i5xZFa1i/C3M4KVoBUjp07sQWOmDic8nS3cZ3tkasZRsQe8BzJ+STDmz11pxZ/DVtrGIy5kgsK7hl5lYMZ0LYAkuhWBKydCPcA==")!
        guard let privateKey = SecKeyCreateWithData(keyData as NSData,
                                                    [
                                                        kSecAttrKeyType: kSecAttrKeyTypeRSA,
                                                        kSecAttrKeyClass: kSecAttrKeyClassPrivate
                                                    ] as NSDictionary,
                                                    &error) else {
            XCTFail(error!.takeRetainedValue().localizedDescription)
            return
        }
        guard let plainText = SecKeyCreateDecryptedData(privateKey,
                                                        .rsaEncryptionOAEPSHA256,
                                                        cipherText as CFData,
                                                        &error) else {
            XCTFail(error!.takeRetainedValue().localizedDescription)
            return
        }
        XCTAssertEqual((plainText as Data).asBytes, payload.asBytes)
    }

}
