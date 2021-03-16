//
//  ThreeDS2ClassicActionHandlerTests.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 11/27/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@testable import Adyen
import Adyen3DS2
@testable import AdyenActions
@testable import AdyenCard
import XCTest

class ThreeDS2ClassicActionHandlerTests: XCTestCase {

    var authenticationRequestParameters: AnyAuthenticationRequestParameters!

    var fingerprintAction: ThreeDS2FingerprintAction!

    var challengeAction: ThreeDS2ChallengeAction!

    override func setUp() {
        super.setUp()

        let sdkPublicKey = "{\"y\":\"zv0kz1SKfNvT3ql75L217de6ZszxfLA8LUKOIKe5Zf4\",\"x\":\"3b3mPfWhuOxwOWydLejS3DJEUPiMVFxtzGCV6906rfc\",\"kty\":\"EC\",\"crv\":\"P-256\"}"
        authenticationRequestParameters = AuthenticationRequestParametersMock(deviceInformation: "device_info",
                                                                              sdkApplicationIdentifier: "sdkApplicationIdentifier",
                                                                              sdkTransactionIdentifier: "sdkTransactionIdentifier",
                                                                              sdkReferenceNumber: "sdkReferenceNumber",
                                                                              sdkEphemeralPublicKey: sdkPublicKey,
                                                                              messageVersion: "messageVersion")

        let token = "eyJkaXJlY3RvcnlTZXJ2ZXJJZCI6IkYwMTMzNzEzMzciLCJkaXJlY3RvcnlTZXJ2ZXJQdWJsaWNLZXkiOiJleUpyZEhraU9pSlNVMEVpTENKbElqb2lRVkZCUWlJc0ltNGlPaUk0VkZCeFprRk9XazR4U1VFemNIRnVNa2RoVVZaaloxZzRMVXBXWjFZME0yZGlXVVJ0WW1kVFkwTjVTa1ZTTjNsUFdFSnFRbVF5YVRCRWNWRkJRV3BWVVZCWFZVeFpVMUZzUkZSS1ltOTFiVkIxYVhWb2VWTXhVSE4yTlRNNFVIQlJSbkV5U2tOYVNFUmthVjg1V1RoVlpHOWhibWxyVTA5NWMyTkhRV3RCVm1KSldIQTVjblZPU20xd1RUQndaMHM1Vkd4SlNXVkhZbEUzWkVKYVIwMU9RVkpMUVhSS2VUWTNkVmx2YlZwWFYwWkJiV3B3TTJkNFNEVnpOemRDUjJ4a2FFOVJVVmxRVEZkeWJEZHlTMHBMUWxVd05tMXRabGt0VUROcGF6azVNbXRQVVRORWFrMDJiSFIyV21OdkxUaEVUMlJDUjBSS1ltZFdSR0ZtYjI5TFVuVk5kMk5VVFhoRGRUUldZV3B5Tm1ReVprcHBWWGxxTlVZemNWQnJZbmc0V0RsNmExYzNVbWx4Vm5vMlNVMXFkRTU0TnpaaWNtZzNhVTlWZDJKaVdtb3hZV0Y2VkcxR1EyeEViMGR5WTJKeE9WODBObmNpZlE9PSIsInRocmVlRFNNZXNzYWdlVmVyc2lvbiI6IjIuMS4wIiwidGhyZWVEU1NlcnZlclRyYW5zSUQiOiI4ODcxOTY2Mi1jMzJmLTRiNjctYTRmNy1lMWM1YzU2ZTY0YjUifQ=="

        fingerprintAction = ThreeDS2FingerprintAction(fingerprintToken: token,
                                                      authorisationToken: "AuthToken",
                                                      paymentData: "paymentData")

        let challengeToken = "eyJhY3NSZWZlcmVuY2VOdW1iZXIiOiJBRFlFTi1BQ1MtU0lNVUxBVE9SIiwiYWNzU2lnbmVkQ29udGVudCI6ImV5SmhiR2NpT2lKUVV6STFOaUlzSW5nMVl5STZXeUpOU1VsRU0wUkRRMEZ6VVVORFVVUlVTbTlUVkd4WVdDOVBWRUZPUW1kcmNXaHJhVWM1ZHpCQ1FWRnpSa0ZFUTBKMWFrVk1UVUZyUjBFeFZVVkNhRTFEVkd0M2VFWnFRVlZDWjA1V1FrRm5UVVJWTlhaaU0wcHJURlZvZG1KSGVHaGliVkY0UldwQlVVSm5UbFpDUVdOTlExVkdkR016VW14amJWSm9ZbFJGVkUxQ1JVZEJNVlZGUTJkM1MxRlhValZhVnpSblZHazFWMHhxUlZKTlFUaEhRVEZWUlVOM2QwbFJNbWhzV1RKMGRtUllVWGhPVkVGNlFtZE9Wa0pCVFUxTVJFNUZWWHBKWjFVeWJIUmtWM2hvWkVjNWVVbEdXa3BWTUVWblVrWk5aMUV5Vm5sa1IyeHRZVmRPYUdSSFZXZFJXRll3WVVjNWVXRllValZOVTBGM1NHZFpTa3R2V2tsb2RtTk9RVkZyUWtab1JucGtXRUozWWpOS01GRkhSbXRsVjFaMVRHMU9kbUpVUVdWR2R6QjRUMFJCTkUxcVkzaE5lbEY2VFZSU1lVWjNNSGxQUkVFMFRXcFJlRTE2VVhwTlZGSmhUVWxIYTAxUmMzZERVVmxFVmxGUlIwVjNTazlVUkVWWFRVSlJSMEV4VlVWRFFYZE9WRzA1ZG1OdFVYUlRSemx6WWtkR2RWcEVSVk5OUWtGSFFURlZSVUozZDBwUlZ6RjZaRWRXZVZwSFJuUk5VazEzUlZGWlJGWlJVVXRFUVhCQ1draHNiR0pwUWs5TWJGbDFUVkpGZDBSM1dVUldVVkZNUkVGb1JHRkhWbXBoTWpreFpFUkZaazFDTUVkQk1WVkZRWGQzVjAwd1VsUk5hVUpVWVZjeE1XSkhSakJpTTBsblZtdHNWRkZUUWtWVmVrVm5UVUkwUjBOVGNVZFRTV0l6UkZGRlNrRlNXVkpqTTFaM1kwYzVlV1JGUW1oYVNHeHNZbWsxYW1JeU1IZG5aMFZwVFVFd1IwTlRjVWRUU1dJelJGRkZRa0ZSVlVGQk5FbENSSGRCZDJkblJVdEJiMGxDUVZGRFl5OVhkMDQyWm5ZeFlVbDFhM3BOYUZkaFVtUmFaMFE1VUd0MU5XRjVUV1ZoYld4T1J6UjBWV3d5VXpZM1RFdEVPVUpTZVdOb1FYWnZOVUVyUld0bU1raExVakpZVkdWeFQyWkhabTlNUkVseE1reFhSemxIYTB0eVJ5OUxRblF2UVZCRU1YaENhR2R0U0c1ck5GbHFjRUZXYmxBMFptRktUSFJTY1dGUVJVVk9Uemd3YldONldXeGhkemhaYW5SUk5ubElXRkJOTkU5UEwyWjZOMlkxT0ZGbGNFaGhkVTFhY0hwNmVrMHJSRzl0VkRCTU1VaENiRmhVZUZwbmRWWkRNQzkxWlVSTlkxTlJUV1k0VDNKV1lreFVkek5rUW5sRU9GZDVOWGQ0UVdkUmRsWXZSR1pFZVZGWVdqZExRMVptWmpsMVpWRllia1J1VDNsR01FNWhMMEpKVlcxcWVtaDJTbTlHWTFnMlV5ODRXVXcyZG1KcE0yNWtZWGxMV1d0dWREVnZjVEpvVmtkbWFGb3JhRFUzZVZvM1pubFdaa0l3YzJGUWFGRnJNMGMyU2pCUEswcHNNbFZYT0ZGMlFUWXdWamg2TkdaQlowMUNRVUZGZDBSUldVcExiMXBKYUhaalRrRlJSVXhDVVVGRVoyZEZRa0ZIVVV4alVHOVFORGhCWVVOeVVXSnhlaXQyUmxBME1tbHliMkpHVUdaeGNGVnJaRlkyUVV4TmVFcENZMk4yU0RsQ2JscG5WbEo2TDNGT1RsTTJSVWcyYkhadlpsa3diRWhUZFV0a2EwSjRMMUJXT0VwT2NHUm9iV012WVVORlMzZG1jV2wwVm5ad016bEVSemxOVWtwVk1YbzNiWFF2VWxKSVNtbFZSREZHTVZGUmVHSlRPR1JNYlc5MFNHWk5TV2xWZHk5elVYSldabVZFTmxCTVVEbHFRM2t2VldsMWQyVkhZM05pYUZFemJ6QklRV2N4ZGtsMlRVSldTREppY0N0bWJEQmlRWEU1VEdzMFdYaEJNRVJ2UzJOSVlsaG1RMFZLYnpkUEwzUkxXV3hhWjFwck5WTmtTMUZsY0VOaFZGRXpOaTlXYjFSeWJIcEpNRTl3VlVjeGRISkZPV1ZWTVN0Sk5reHFNVTlsWlhsa1pqVTVablpZUVdSb0wyaGtaR2hMVkRSblNuSjJka1ppTUhjMGVscHBXSFY2VmxwUVMxQXdkbmxyUVc0NUswazJRVkl5VWtzNFlVRTBORzlLUVV3emQwZ3hTVUU5SWl3aVRVbEpSRGhxUTBOQmRHOURRMUZFVG01WWVXTldSVWwzZFhwQlRrSm5hM0ZvYTJsSE9YY3dRa0ZSYzBaQlJFTkNkV3BGVEUxQmEwZEJNVlZGUW1oTlExUnJkM2hHYWtGVlFtZE9Wa0pCWjAxRVZUVjJZak5LYTB4VmFIWmlSM2hvWW0xUmVFVnFRVkZDWjA1V1FrRmpUVU5WUm5Sak0xSnNZMjFTYUdKVVJWUk5Ra1ZIUVRGVlJVTm5kMHRSVjFJMVdsYzBaMVJwTlZkTWFrVlNUVUU0UjBFeFZVVkRkM2RKVVRKb2JGa3lkSFprV0ZGNFRsUkJla0puVGxaQ1FVMU5URVJPUlZWNlNXZFZNbXgwWkZkNGFHUkhPWGxKUmxwS1ZUQkZaMUpHVFdkUk1sWjVaRWRzYldGWFRtaGtSMVZuVVZoV01HRkhPWGxoV0ZJMVRWTkJkMGhuV1VwTGIxcEphSFpqVGtGUmEwSkdhRVo2WkZoQ2QySXpTakJSUjBaclpWZFdkVXh0VG5aaVZFRmxSbmN3ZUU5RVFUUk5hbU40VFhwUmQwNVVhR0ZHZHpCNVQwUkJORTFxVVhoTmVsRjNUbFJvWVUxSlJ6Wk5VWE4zUTFGWlJGWlJVVWRGZDBwUFZFUkZWMDFDVVVkQk1WVkZRMEYzVGxSdE9YWmpiVkYwVTBjNWMySkhSblZhUkVWVFRVSkJSMEV4VlVWQ2QzZEtVVmN4ZW1SSFZubGFSMFowVFZKTmQwVlJXVVJXVVZGTFJFRndRbHBJYkd4aWFVSlBUR3haZFUxU1JYZEVkMWxFVmxGUlRFUkJhRVJoUjFacVlUSTVNV1JFUlRGTlJFMUhRVEZWUlVGM2QzTk5NRkpVVFdsQ1ZHRlhNVEZpUjBZd1lqTkpaMVpyYkZSUlUwSkZWWGxDUkZwWVNqQmhWMXB3V1RKR01GcFRRa0prV0ZKdllqTktjR1JJYTNoSlJFRmxRbWRyY1docmFVYzVkekJDUTFGRlYwVllUakZqU0VKMlkyNVNRVmxYVWpWYVZ6UjFXVEk1ZEUxSlNVSkpha0ZPUW1kcmNXaHJhVWM1ZHpCQ1FWRkZSa0ZCVDBOQlVUaEJUVWxKUWtOblMwTkJVVVZCZFhBM0syWjBkMWRuUjJSallUWXhjVlpDWXpGQ2RsUnBOVmswTTBKM2FGb3pVMmhLU1d0dFIwbDNaMWxRYzBvNWNISlBZMXBWVm1WSGEwVm9ZelZIV0hjdk9WSk1ZMnhaYldscE1sb3ZURkJGZVhrMlZVbGpVSE5GUm1sa1VucFhURFprT0RSaVpHSTRWRFZwTmtsQlRITklVMmRQWm1OUVR6SkVRMWx2VGpWR0swZ3ZkbFZoY0hkWlIycENORmtyYVhkTlpsRXlaWE5NTTFGRVpFVXJMMjg1TDFvMFRuQm1iemtyWTJZeFJIcGxjRk5YVm5oVWVGSlNhMU5ZTVVjclVYWnJRazB2Y0d4ME5XMDFlQ3RNVlZrd2VqWlZOQ3QxVVhGQ1VWbHphVEJWVURWTmJXSTRSVFpWZDBjeWEyTTROblJ6WlhjMFdVeHhVMk5ZZEZVNVp5OXZPVGxuT1VWcmJrVlRXbTlDT0ZGdGFtZEpNSE5hVVhKRk0wdHZORUV5TDFsRFpUSTFTbWRhTnpGTFl6ZEZMemxJUzFGTE0xWXhkR2xNY25wNGFWTkxNSEU0WWtWT00ycGhZalJ6VVVwWFkzcFNOVTVSU1VSQlVVRkNUVUV3UjBOVGNVZFRTV0l6UkZGRlFrTjNWVUZCTkVsQ1FWRkJiVGh4VDBSQlRrSXpVSEFyT1RoUlpuVlJWVVZVV0dVeFRsSndTblpFYjJONWMyUnZTaXR6ZERoSFdtUmlWMmx1YTA5d04yWnNXVFJZY0VaeU1scEpjVTVJVFhsS2MyWTNPVWxCUzJ4Q1pXOVRXRGQ0VkdacVozSXlPSGRuYTFONWREVlFWMkkzV2tZeldGUXdibWRYYzNoeU1tUjBSamRTZFVGNFVUaEtZbFJ3VUV4a1JWa3hXakp5YUVvMVlYUktkRGRGU2xsRk5rRllTbnBCY2pWVlNqZDViVEJqV1NzNVRrMHpWa0pxVTNCak9XVk1UMDR6Vkd0WldHOVZkakprYlV0MU1VaDZUSFppTVcxRU1HVkllWFZGY2xGUGNtSlVLekZ2UmsxbEwwdG9lbll4TjB4cldEaHFOMDk0VTB0dFVpOUlMMVF5ZVhGbmJYcFBlR2ROTUd4TGVtc3pWMmxSVDI0eGExUlhZVzlZT0VOb1VEWnBVMjFLYTNKM1NWVjVXaXRXTVZWSlVFTlViblJzVVhwRlVVcElPVFpSTlc1WlRsUk1UamhxVm14d05XMXVTMGQwVWtGWWNteDFjbmhNYVRsWk5rVWlYWDAuZXlKaFkzTkZjR2hsYlZCMVlrdGxlU0k2ZXlKamNuWWlPaUpRTFRJMU5pSXNJbXQwZVNJNklrVkRJaXdpZUNJNkltZEpNRWRCU1V4Q1pIVTNWRFV6WVd0eVJtMU5lVWRqYzBZemJqVmtUemROYlhkT1FraExWelZUVmpBaUxDSjVJam9pVTB4WFgzaFRabVo2YkZCWGNraEZWa2t6TUVSSVRWODBaV2RXZDNRelRsRnhaVlZFTjI1TlJuQndjeUo5TENKelpHdEZjR2hsYlZCMVlrdGxlU0k2ZXlKamNuWWlPaUpRTFRJMU5pSXNJbXQwZVNJNklrVkRJaXdpZUNJNklrWjNSV0ZzWms5NlFXWXRialpFTkZGMlJGcEdkbWhTYURWbk5GQkhabTQ1VjNwRVZ6VlJORk15TVVVaUxDSjVJam9pUmtjMGIwMVdOMnR1Y1RKWVJURkdUVGxQTTNveFNVcE9NbE14T0VKT1FVMHRka3RIVFd4M2NtTlRXU0o5TENKaFkzTlZVa3dpT2lKb2RIUndjenBjTDF3dmNHRnNMWFJsYzNRdVlXUjVaVzR1WTI5dFhDOTBhSEpsWldSek1uTnBiWFZzWVhSdmNsd3ZjMlZ5ZG1salpYTmNMMVJvY21WbFJGTXlVMmx0ZFd4aGRHOXlYQzkyTVZ3dmFHRnVaR3hsWEM4eU5HVmxOekkwTWkweFpEZzFMVFE0WkdNdE9ERXpZaTAzTURoaE5UWXdabVZpWlRVaWZRLlQzSlJRSDhSWTA3Ni1rUEJEaXUtT2VGUktwS3JfS19fdEJ1TGxydlJ5aWxzcnEwcDZ3NUxwYzZJNVcwcTVXUDBuTmFSYTZUV1gxZlVzWDZGV2FuTktjMldzNFZiTTN6ODkzcGNEU1JlVlhZWnd5azladnNpaFE3MDNCMmhPM1Btdk8zT1BPRVNaLXFEYUlyREtGRUdQR1JCdXBCWFRWZVFoU2R1SU85alR6TERlbk1kZ0QyUUM1T0FHdVNMRUo3SjhWcWIzSG1XSThsZkktY1BDdjFKSkRjdjExYnZkRk5ULVY3NUhPTEY2M3ZYZjdSTGFlNUtsVDBqUm0xb3c0MVMwb1N3eWs3UGN5MG83cDRLSjYtbEZoZG9zZkRUYlBZenlWSmtId19HQnZjOE01ZTZBXzNxR21tYm1iOW9pQmRYLW1oS0lzRGtWQjhtbkJuR0p3NFFjQSIsImFjc1RyYW5zSUQiOiIyNGVlNzI0Mi0xZDg1LTQ4ZGMtODEzYi03MDhhNTYwZmViZTUiLCJhY3NVUkwiOiJodHRwczpcL1wvcGFsLXRlc3QuYWR5ZW4uY29tXC90aHJlZWRzMnNpbXVsYXRvclwvc2VydmljZXNcL1RocmVlRFMyU2ltdWxhdG9yXC92MVwvaGFuZGxlXC8yNGVlNzI0Mi0xZDg1LTQ4ZGMtODEzYi03MDhhNTYwZmViZTUiLCJtZXNzYWdlVmVyc2lvbiI6IjIuMS4wIiwidGhyZWVEU1NlcnZlclRyYW5zSUQiOiI3YjI2MGQ3My03MTY0LTQxY2QtYTcwYy04YWE4ZDFhMWM5YTIifQ=="
        challengeAction = ThreeDS2ChallengeAction(challengeToken: challengeToken, authorisationToken: "authToken", paymentData: "paymentData")
    }

    func testWrappedComponent() {
        let sut = ThreeDS2ClassicActionHandler(appearanceConfiguration: ADYAppearanceConfiguration())
        sut.clientKey = Dummy.dummyClientKey
        XCTAssertEqual(sut.wrappedComponent.clientKey, Dummy.dummyClientKey)

        sut.environment = .live
        XCTAssertEqual(sut.wrappedComponent.environment.baseURL, Environment.live.baseURL)

        sut._isDropIn = false
        XCTAssertEqual(sut.wrappedComponent._isDropIn, false)

        sut._isDropIn = true
        XCTAssertEqual(sut.wrappedComponent._isDropIn, true)
    }

    func testFingerprintFlowSuccess() throws {
        
        let service = AnyADYServiceMock()
        service.authenticationRequestParameters = authenticationRequestParameters
        
        let fingerprint = try ThreeDS2Component.Fingerprint(
            authenticationRequestParameters: authenticationRequestParameters
        )
        let expectedFingerprint = try Coder.encodeBase64(fingerprint)
        
        let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")
        let sut = ThreeDS2ClassicActionHandler(service: service)
        sut.handle(fingerprintAction) { fingerprintResult in
            switch fingerprintResult {
            case let .success(result):
                switch result {
                case let .details(details):
                    XCTAssertTrue(details is ThreeDS2Details)
                    let details = details as! ThreeDS2Details
                    switch details {
                    case let .fingerprint(fingerprint):
                        XCTAssertEqual(fingerprint, expectedFingerprint)
                    default:
                        XCTFail()
                    }
                default:
                    XCTFail()
                }
            case .failure:
                XCTFail()
            }
            resultExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testInvalidFingerprintToken() throws {
        let submitter = AnyThreeDS2FingerprintSubmitterMock()

        let mockedDetails = ThreeDS2Details.completed(ThreeDSResult(payload: "payload"))
        submitter.mockedResult = .success(.details(mockedDetails))

        let service = AnyADYServiceMock()
        service.authenticationRequestParameters = authenticationRequestParameters

        let fingerprintAction = ThreeDS2FingerprintAction(fingerprintToken: "Invalid-token",
                                                          authorisationToken: "AuthToken",
                                                          paymentData: "paymentData")

        let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")
        let sut = ThreeDS2ClassicActionHandler(service: service)
        sut.handle(fingerprintAction) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(error):
                let decodingError = error as! DecodingError
                switch decodingError {
                case .dataCorrupted: ()
                default:
                    XCTFail()
                }
            }
            resultExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testChallengeFlowSuccess() throws {

        let service = AnyADYServiceMock()
        service.authenticationRequestParameters = authenticationRequestParameters

        let transaction = AnyADYTransactionMock(parameters: authenticationRequestParameters)
        transaction.onPerformChallenge = { params, completion in
            completion(AnyChallengeResultMock(sdkTransactionIdentifier: "sdkTxId", transactionStatus: "Y"), nil)
        }
        service.mockedTransaction = transaction

        let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")
        let sut = ThreeDS2ClassicActionHandler(service: service)
        sut.transaction = transaction
        sut.handle(challengeAction) { challengeResult in
            switch challengeResult {
            case let .success(result):
                switch result {
                case let .details(details):
                    XCTAssertTrue(details is ThreeDS2Details)
                    let details = details as! ThreeDS2Details
                    switch details {
                    case let .challengeResult(result):
                        let data = Data(base64Encoded: result.payload)
                        let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: String]
                        XCTAssertEqual(json?["transStatus"], "Y")
                        XCTAssertEqual(json?["authorisationToken"], "authToken")
                    default:
                        XCTFail()
                    }
                default:
                    XCTFail()
                }
            case .failure:
                XCTFail()
            }
            resultExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testChallengeFlowFailure() throws {

        let service = AnyADYServiceMock()
        service.authenticationRequestParameters = authenticationRequestParameters
        let mockedTransaction = AnyADYTransactionMock(parameters: authenticationRequestParameters)
        service.mockedTransaction = mockedTransaction

        mockedTransaction.onPerformChallenge = { parameters, completion in
            completion(nil, Dummy.dummyError)
        }

        let sut = ThreeDS2ClassicActionHandler(service: service)
        sut.transaction = mockedTransaction

        let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")

        sut.handle(challengeAction) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(error):
                let error = error as! Dummy
                XCTAssertEqual(error, Dummy.dummyError)
            }
            resultExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testChallengeFlowMissingTransaction() throws {
        let service = AnyADYServiceMock()

        let sut = ThreeDS2ClassicActionHandler(service: service)

        let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")
        sut.handle(challengeAction) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(error):
                let error = error as! ThreeDS2ComponentError
                switch error {
                case .missingTransaction: ()
                default:
                    XCTFail()
                }
            }
            resultExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testInvalidChallengeToken() throws {

        let service = AnyADYServiceMock()
        service.authenticationRequestParameters = authenticationRequestParameters
        let mockedTransaction = AnyADYTransactionMock(parameters: authenticationRequestParameters)
        service.mockedTransaction = mockedTransaction

        mockedTransaction.onPerformChallenge = { parameters, completion in
            XCTFail()
        }

        let sut = ThreeDS2ClassicActionHandler(service: service)
        sut.transaction = mockedTransaction

        let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")

        let challengeAction = ThreeDS2ChallengeAction(challengeToken: "Invalid-token", authorisationToken: "AuthToken", paymentData: "paymentData")
        sut.handle(challengeAction) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(error):
                let error = error as! DecodingError
                switch error {
                case .dataCorrupted: ()
                default:
                    XCTFail()
                }
            }
            resultExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

}
