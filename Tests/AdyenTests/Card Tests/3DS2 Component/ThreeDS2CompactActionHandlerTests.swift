//
//  ThreeDS2CompactActionHandlerTests.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 11/4/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

@testable import Adyen
import Adyen3DS2
@testable import AdyenActions
@testable import AdyenCard
import XCTest

class ThreeDS2CompactActionHandlerTests: XCTestCase {

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

        let fingerprintToken = "eyJkaXJlY3RvcnlTZXJ2ZXJJZCI6IkYwMTMzNzEzMzciLCJkaXJlY3RvcnlTZXJ2ZXJQdWJsaWNLZXkiOiJleUpyZEhraU9pSlNVMEVpTENKbElqb2lRVkZCUWlJc0ltNGlPaUk0VkZCeFprRk9XazR4U1VFemNIRnVNa2RoVVZaaloxZzRMVXBXWjFZME0yZGlXVVJ0WW1kVFkwTjVTa1ZTTjNsUFdFSnFRbVF5YVRCRWNWRkJRV3BWVVZCWFZVeFpVMUZzUkZSS1ltOTFiVkIxYVhWb2VWTXhVSE4yTlRNNFVIQlJSbkV5U2tOYVNFUmthVjg1V1RoVlpHOWhibWxyVTA5NWMyTkhRV3RCVm1KSldIQTVjblZPU20xd1RUQndaMHM1Vkd4SlNXVkhZbEUzWkVKYVIwMU9RVkpMUVhSS2VUWTNkVmx2YlZwWFYwWkJiV3B3TTJkNFNEVnpOemRDUjJ4a2FFOVJVVmxRVEZkeWJEZHlTMHBMUWxVd05tMXRabGt0VUROcGF6azVNbXRQVVRORWFrMDJiSFIyV21OdkxUaEVUMlJDUjBSS1ltZFdSR0ZtYjI5TFVuVk5kMk5VVFhoRGRUUldZV3B5Tm1ReVprcHBWWGxxTlVZemNWQnJZbmc0V0RsNmExYzNVbWx4Vm5vMlNVMXFkRTU0TnpaaWNtZzNhVTlWZDJKaVdtb3hZV0Y2VkcxR1EyeEViMGR5WTJKeE9WODBObmNpZlE9PSIsImRpcmVjdG9yeVNlcnZlclJvb3RDZXJ0aWZpY2F0ZXMiOiJleUFpWVd4bklqb2dJa1ZUTlRFeUlpd2dJbmcxWXlJNklGc2dJazFKU1VNeGVrTkRRV3B0WjBGM1NVSkJaMGxEUlVGQmQwTm5XVWxMYjFwSmVtb3dSVUYzU1hkbldWVjRRM3BCU2tKblRsWkNRVmxVUVdzMVRVMVJjM2REVVZsRVZsRlJTVVJCU2s5VFJFVlRUVUpCUjBFeFZVVkNkM2RLVVZjeGVtUkhWbmxhUjBaMFRWSk5kMFZSV1VSV1VWRkxSRUZ3UWxwSWJHeGlhVUpQVEd4WmRVMVNjM2RIVVZsRVZsRlJURVJDU2tKYVNHeHNZbWxDVVdKSFJqQmFiVGw1WWxOQ1VWTXdhM2hKZWtGb1FtZE9Wa0pCVFUxSGEwWnJaVmRXZFVsR1FuTlpXRkp0WWpOS2RFbEZWa1JSZVVKVFlqSTVNRWxGVGtKTlFqUllSRlJKZVUxRVVYZE9ha0UwVFZSbmVFMVdiMWhFVkVrelRVUlJkMDVVUVRSTlZHZDRUVlp2ZDJSRVJVeE5RV3RIUVRGVlJVSm9UVU5VYTNkNFEzcEJTa0puVGxaQ1FXZE5RV3MxU1UxU1RYZEZVVmxFVmxGUlMwUkJjRUphU0d4c1ltbENUMHhzV1hWTlVuTjNSMUZaUkZaUlVVeEVRa3BDV2toc2JHSnBRbEZpUjBZd1dtMDVlV0pUUWxGVE1HdDRTbXBCYTBKblRsWkNRVTFOU0ZWNFNsWnJWWFZOTUZKVVRXbENSbEV3VFdkVFZ6VXdXbGhLZEZwWFVuQlpXRkpzU1VWT1FrMUpSMkpOUWtGSFFubHhSMU5OTkRsQlowVkhRbE4xUWtKQlFXcEJORWRIUVVGUlFXNUZZbEUwVUdWTlVtUXZTVk5XUzBsU1dEUjJjSFUwTW5oU01HOXJOa1ZNY1RjMWNVRndNRWd3TW1GVU5YbGxhRzAwTVZGVVpWZGtSVEpaTm5CQmFGQlpWa1ZYYzBoT1UwbHRRVTh5TDIweVNHaEdLM1ExTkVKcFkzaGFOUzlXZGswMGRuUXZZblZqZHpWQllYZHpRMmxFV2xnd1VtMHlNbnBQVEVveVJUVlhLMjVRVTFrNGIzZHNNemxFYW13NFoyd3laMEZITUUxRWVrdHhNWFpQU0N0c05tNW9kMDVyZEV4alEzbHVjMlZxV21wQ2EwMUNNRWRCTVZWa1JHZFJWMEpDVTJKSmFuaFJUVGxPTWtkWU1XZEpWV0l2ZEU4clRIbFZVeXRVYWtGbVFtZE9Wa2hUVFVWSFJFRlhaMEpSZEVwRFdFUndjVmRHZEZSUFFrTlJhbG81ZURRMlJFSlBTM0JVUVZOQ1owNVdTRkpOUWtGbU9FVkRSRUZIUVZGSUwwRm5SVUZOUVRSSFFURlZaRVIzUlVJdmQxRkZRWGRKUW1ocVFVdENaMmR4YUd0cVQxQlJVVVJCWjA5Q2FYZEJkMmRaWTBOUlowUk9VMnRMU1dOYVlWQjVRa3MwVWk5cFoyTXdPVTVSWWl0Sk9UTnllblEyVTIxS2RqSnVPQ3MyU0RGdmVXVkJaVVJLZURSMVFXVTNVMnRPV0RGbVpFVkdjSFpMVmpock1EQXdUakJYVjBGS1ZuTXJVRVpUYTNkS1FscHVZbWhKU1hoM1lUbGthamt3V0ZGb056QjVNVEpaV25FeGNITlNURWcySzJ4S2VEQnlRWGhOU0VKTk1HdHFWazFoUTJKRlJYY3lZMlJoYVdJMFVtRlJibnAwVERScU1qWlJZMU15TldscmNXODVla2xQYnowaUlGMGdmUW8uZXlBaVkyVnlkR2xtYVdOaGRHVnpJam9nV3lBaVRVbEpSRGhxUTBOQmRHOURRMUZFVG01WWVXTldSVWwzZFhwQlRrSm5hM0ZvYTJsSE9YY3dRa0ZSYzBaQlJFTkNkV3BGVEUxQmEwZEJNVlZGUW1oTlExUnJkM2hHYWtGVlFtZE9Wa0pCWjAxRVZUVjJZak5LYTB4VmFIWmlSM2hvWW0xUmVFVnFRVkZDWjA1V1FrRmpUVU5WUm5Sak0xSnNZMjFTYUdKVVJWUk5Ra1ZIUVRGVlJVTm5kMHRSVjFJMVdsYzBaMVJwTlZkTWFrVlNUVUU0UjBFeFZVVkRkM2RKVVRKb2JGa3lkSFprV0ZGNFRsUkJla0puVGxaQ1FVMU5URVJPUlZWNlNXZFZNbXgwWkZkNGFHUkhPWGxKUmxwS1ZUQkZaMUpHVFdkUk1sWjVaRWRzYldGWFRtaGtSMVZuVVZoV01HRkhPWGxoV0ZJMVRWTkJkMGhuV1VwTGIxcEphSFpqVGtGUmEwSkdhRVo2WkZoQ2QySXpTakJSUjBaclpWZFdkVXh0VG5aaVZFRmxSbmN3ZUU5RVFUUk5hbU40VFhwUmQwNVVhR0ZHZHpCNVQwUkJORTFxVVhoTmVsRjNUbFJvWVUxSlJ6Wk5VWE4zUTFGWlJGWlJVVWRGZDBwUFZFUkZWMDFDVVVkQk1WVkZRMEYzVGxSdE9YWmpiVkYwVTBjNWMySkhSblZhUkVWVFRVSkJSMEV4VlVWQ2QzZEtVVmN4ZW1SSFZubGFSMFowVFZKTmQwVlJXVVJXVVZGTFJFRndRbHBJYkd4aWFVSlBUR3haZFUxU1JYZEVkMWxFVmxGUlRFUkJhRVJoUjFacVlUSTVNV1JFUlRGTlJFMUhRVEZWUlVGM2QzTk5NRkpVVFdsQ1ZHRlhNVEZpUjBZd1lqTkpaMVpyYkZSUlUwSkZWWGxDUkZwWVNqQmhWMXB3V1RKR01GcFRRa0prV0ZKdllqTktjR1JJYTNoSlJFRmxRbWRyY1docmFVYzVkekJDUTFGRlYwVllUakZqU0VKMlkyNVNRVmxYVWpWYVZ6UjFXVEk1ZEUxSlNVSkpha0ZPUW1kcmNXaHJhVWM1ZHpCQ1FWRkZSa0ZCVDBOQlVUaEJUVWxKUWtOblMwTkJVVVZCZFhBM0syWjBkMWRuUjJSallUWXhjVlpDWXpGQ2RsUnBOVmswTTBKM2FGb3pVMmhLU1d0dFIwbDNaMWxRYzBvNWNISlBZMXBWVm1WSGEwVm9ZelZIV0hjdk9WSk1ZMnhaYldscE1sb3ZURkJGZVhrMlZVbGpVSE5GUm1sa1VucFhURFprT0RSaVpHSTRWRFZwTmtsQlRITklVMmRQWm1OUVR6SkVRMWx2VGpWR0swZ3ZkbFZoY0hkWlIycENORmtyYVhkTlpsRXlaWE5NTTFGRVpFVXJMMjg1TDFvMFRuQm1iemtyWTJZeFJIcGxjRk5YVm5oVWVGSlNhMU5ZTVVjclVYWnJRazB2Y0d4ME5XMDFlQ3RNVlZrd2VqWlZOQ3QxVVhGQ1VWbHphVEJWVURWTmJXSTRSVFpWZDBjeWEyTTROblJ6WlhjMFdVeHhVMk5ZZEZVNVp5OXZPVGxuT1VWcmJrVlRXbTlDT0ZGdGFtZEpNSE5hVVhKRk0wdHZORUV5TDFsRFpUSTFTbWRhTnpGTFl6ZEZMemxJUzFGTE0xWXhkR2xNY25wNGFWTkxNSEU0WWtWT00ycGhZalJ6VVVwWFkzcFNOVTVSU1VSQlVVRkNUVUV3UjBOVGNVZFRTV0l6UkZGRlFrTjNWVUZCTkVsQ1FWRkJiVGh4VDBSQlRrSXpVSEFyT1RoUlpuVlJWVVZVV0dVeFRsSndTblpFYjJONWMyUnZTaXR6ZERoSFdtUmlWMmx1YTA5d04yWnNXVFJZY0VaeU1scEpjVTVJVFhsS2MyWTNPVWxCUzJ4Q1pXOVRXRGQ0VkdacVozSXlPSGRuYTFONWREVlFWMkkzV2tZeldGUXdibWRYYzNoeU1tUjBSamRTZFVGNFVUaEtZbFJ3VUV4a1JWa3hXakp5YUVvMVlYUktkRGRGU2xsRk5rRllTbnBCY2pWVlNqZDViVEJqV1NzNVRrMHpWa0pxVTNCak9XVk1UMDR6Vkd0WldHOVZkakprYlV0MU1VaDZUSFppTVcxRU1HVkllWFZGY2xGUGNtSlVLekZ2UmsxbEwwdG9lbll4TjB4cldEaHFOMDk0VTB0dFVpOUlMMVF5ZVhGbmJYcFBlR2ROTUd4TGVtc3pWMmxSVDI0eGExUlhZVzlZT0VOb1VEWnBVMjFLYTNKM1NWVjVXaXRXTVZWSlVFTlViblJzVVhwRlVVcElPVFpSTlc1WlRsUk1UamhxVm14d05XMXVTMGQwVWtGWWNteDFjbmhNYVRsWk5rVWlMQ0FpVFVsSlIwSlVRME5CS3pKblFYZEpRa0ZuU1VwQlMwOW5hRGh6ZFVWeFpVOU5RVEJIUTFOeFIxTkpZak5FVVVWQ1EzZFZRVTFKUjFsTlVYTjNRMUZaUkZaUlVVZEZkMHBQVkVSRlYwMUNVVWRCTVZWRlEwRjNUbFJ0T1haamJWRjBVMGM1YzJKSFJuVmFSRVZUVFVKQlIwRXhWVVZDZDNkS1VWY3hlbVJIVm5sYVIwWjBUVkpGZDBSM1dVUldVVkZMUkVGb1FscEliR3hpYVVKUFZtcEZaMDFDTkVkQk1WVkZRM2QzV0Uwd1VXZFZNbFpxWkZoS2JFbEVTWFZOUTBKVVlWY3hNV0pIUmpCaU0wbDRTMFJCYlVKblRsWkNRVTFOU0hwT1JVbEdUbXhaTTFaNVdsTkJlVXhxUVdkVk1teDBaRmQ0YUdSSE9YbEpSa3AyWWpOUloxRXdSWGRJYUdOT1RWUnJkMDVxUVRKTlJHdDNUbnBKZWxkb1kwNU5hbXQzVG1wQmVrMUVhM2RPZWtsNlYycERRbTFFUlV4TlFXdEhRVEZWUlVKb1RVTlVhM2Q0Um1wQlZVSm5UbFpDUVdkTlJGVTFkbUl6U210TVZXaDJZa2Q0YUdKdFVYaEZha0ZSUW1kT1ZrSkJZMDFEVlVaMFl6TlNiR050VW1oaVZFVlNUVUU0UjBFeFZVVkRaM2RKVVZkU05WcFhOR2RVYkZsNFNVUkJaVUpuVGxaQ1FYTk5SbnBPUlVsR1RteFpNMVo1V2xOQmVVeHFRV2RWTW14MFpGZDRhR1JIT1hsTlUyZDNTbWRaUkZaUlVVUkVRamg2VWtOQ1ZGcFhUakZqYlZWblRXazBkMGxHVG5CaVdGWnpXVmhTZG1OcFFsTmlNamt3U1VWT1FrMUpTVU5KYWtGT1FtZHJjV2hyYVVjNWR6QkNRVkZGUmtGQlQwTkJaemhCVFVsSlEwTm5TME5CWjBWQmJURnRhRk5FUmxoWlN6QjRSV3AyTHpSQldVdEpTRmR5ZUZJcmJHaFVaVnBpZUc5bWMwcENia2hpUTNsbGJXVXhkek5ZVUhaVlRHcFVlbXQ1ZFRkMVZsbEZXbE15WkVwWVlreHdiMUZ6ZFVwcmNsbEROVTlMV0VZM01rRlhObkp6UnpKeFNrUTFVVmhCZFRkVGFESnZlWFo1U1UxM05taEJha055WjJWVlNXMHdTMlJ1T1VkUVZWTjNWbXhJVjFsd2NtUk1NblZhZUVGRE5sSkJWM0ZGWjNoeGFDdHphVzgxU1VSeEszUkNMMm81WVVSMllWQnNXazVhVlRoaFUxWm5iazlNVGtZNVExbGpZWEF4V0VoaVRVTnNkRWd3VlhjeVRHZFllRzlQZDB0VVpVZFJlREpaVlc1RU5tbzFNVmd3Ym1nME9VcGlXbVV6WTJGUWNraHpTRVF5YUhKM1JXWlBTa1V4YVVwMGNYRnVVVnBxWjBsUVQyY3lhbU53TDFsWVVHdERjRFpMVUZsTVpVWm5PRU5DVlVNelNFbG5ZM1l6TVdKall6STJWa3BDT0daM1NqWmhiSGRvYkVKTlNua3pTek5uVFVvd2FuaFZkMlZRV0dWbVFtNWphVzg1TjBOTk1uaHZSRk5LVkdaWU5YRkpiMlUwYlZKR1QyZ3dRVFJUVm5CSlVGUjFTV0V6TUdWc1dXSXpaMVF4ZVdRdmJXWkhNR05ZT0VwaVlsbHlTbTl0WVRCM01HUnpVbmx5WlRJelJuZzRaV3BKWkhRMVV6Sm9WV0pDYm1zelVUSnhUbVZNTnpRcldXVTJlSGxqT1dkcVYydHhPV3BzTnpkNVJtZGphamhOYldsU1FVTkllVkF6ZEZGVWFrNVpPVzVCZGs1YU0yUnBOME5GVlc1bVpIRTBObXBVYkVWcU1VNHdRelUxVEhZNWIySldORUZGYmk5V1JubEtaa3cxZG1wcU4yRklURVF5YjJoclRHRkdRMGQ2UzJaT1EzTkNjRkZDVWtjMFVtNXFhbXhuV0ZOWGRGaGxhV0pRTjBkTVJraEVZamx3VFRsa2VqSktNaXRGVW10Qk5qTnRVWFpDVjA4MlUzQm5LMU5uWm5WTVltRk5iamg2YWxGT1NGQTRVREowV25aM1ZVOVlLM0kwZDJGTldVeFlXRGRqUTBoa1YxbE1XalEwV2tSdlFUQXJRVUZxUTBWRFFYZEZRVUZoVGxGTlJUUjNTRkZaUkZaU01FOUNRbGxGUmtobGNYaENaVFZTVFVoRk4yaDVWVkpIWW5sS2VIVkxjbXd5ZVUxQ09FZEJNVlZrU1hkUldVMUNZVUZHU0dWeGVFSmxOVkpOU0VVM2FIbFZVa2RpZVVwNGRVdHliREo1VFVGM1IwRXhWV1JGZDFGR1RVRk5Ra0ZtT0hkRVVWbEtTMjlhU1doMlkwNUJVVVZNUWxGQlJHZG5TVUpCUmpsbWR6SjNWWEJ5VjJGMksxbEhUR3hCVUVsTFkwZ3ZSRkJETUcwd2VHNXNWR05sTjJwcFZFUkRiWElyYVU0NE0ya3JSelk0Tldwd2EyWlpVbWhOVkUxdGNDc3hNak5oWmlzclZucFhRbXgwWW1OTFpVa3lhMUZWV1doWVkxbHJWR2MyWlVSclprSjFVVTVXVkVwTlZtbFNZM2cyVjJjNGFrRlFiMDQ0U2xablVtcG1lVGhPY1hNNFlWUXZTU3RLTldKSk5sWTVhRVUwYWtsSFUzQTBRa2RrY0VadFluTjRiRTFRYW5GdE5EWm1ObEJETlVwUmVXWTFUV2h1UmpBcmRuWnNiR0ZwYWxoNWRsVktLekk1WTFsUVQzRlRlbGRPUVhaamREUnVWM1ZhYkdSRWEwdzBkemRsTkZOR1VGVmlSamt5V0RoWVkxaDNOMnAwTDFoa1J6VllTSGxwWjNobk5YRnJTRloyUTJSdlVFeDZPRWhZY0c1R1JHTnFibGhtZG1seVQwMVJhRzlPYlRaWVJXWnZNM1Z5VDBscVREUk1jMkp2UnpBNGMweEpZbGgxV0dGNFJsVk5jV050TjNKM1EwRlFUVVJEY0VOTGJtTkdVSEE0Y0cxVmJrdHhhVGxFZUdaT1JYaDRVbmxhVkRSbldXOXFXR2NyY1V4Q2NqbGpRVk4wYjNscFZrSkRka1kzYTNKbmF6TlBTMUJSWW1wR1Eya3JNRUpUYzNGUVkzYzBlVFpoTVdwUWVuQXlaMHRzV2xoQ2JsUnRZbXh0VlhOdlNYbGlPSEYwZUZCWE1rbFJOVzFsVEdaS1drUmxTMFJaY3l0U1pXZHZTV296YkdKdmEwaGtSM2cxTWlzdk1FZEJSa3BpVkhsaGIzSjFNVTFzU21wdllVaG5WR3haUW01aVJUUXJZblU1TURJMVRFVkhjMlZ5TWpoakx6Qm5WMjlhUzJVeVVuQmlSbG9yWmsxQmVrMTZaamxUVGpkeVEwdzVUemR4YmpCTWVrMWxOSEJOUVVwSU1VWkVRVEU1UVhkUFlWbE1jWGRrYURnNWVFRjBUWGhtVTJnMFdVaFhRMGg2VDFVM1YybHVZazlFV0c5MFMwZHFWVlJGUml0MVdXSTBWREZwZEhOeUx6azVjRUpvWVhNeFFqaFlNVnBXUjNwbmVqVklOU3RQZWtWclUyTlhWVUpOU1RKRmF6aHpRWEVpSUYwZ2ZRby5NSUdHQWtGajh0ZjJqQUdaQ182bGhWdkFuMWNTRUlEdmNSOGZpcWNUblNTT1NYU0Ywb0p2b0JIaDVZTXVMMHhLeW9xRXRkME05dVNZOWNnbkJnalNDakRSWEhvNXBRSkJEZ2ZSWkExWXpBempsbW5qMDBCSzRXNkJXcld3MDF0NWJvZWpOdVYwVzFDTVZ3VVdBdi1kZklvNkNHUkJtUnhYVlRmLVVuaVJvbjJXVHp1MjM4N21aT0EiLCJ0aHJlZURTTWVzc2FnZVZlcnNpb24iOiIyLjIuMCIsInRocmVlRFNTZXJ2ZXJUcmFuc0lEIjoiNjU1YzA2ZGUtYWQzZS00OWQxLTk2NTAtNTliYjZiYWU0MjJkIn0=="

        fingerprintAction = ThreeDS2FingerprintAction(fingerprintToken: fingerprintToken,
                                                      authorisationToken: "AuthToken",
                                                      paymentData: "paymentData")

        let challengeToken = "eyJhY3NSZWZlcmVuY2VOdW1iZXIiOiJBRFlFTi1BQ1MtU0lNVUxBVE9SIiwiYWNzU2lnbmVkQ29udGVudCI6ImV5SmhiR2NpT2lKUVV6STFOaUlzSW5nMVl5STZXeUpOU1VsRU0wUkRRMEZ6VVVORFVVUlVTbTlUVkd4WVdDOVBWRUZPUW1kcmNXaHJhVWM1ZHpCQ1FWRnpSa0ZFUTBKMWFrVk1UVUZyUjBFeFZVVkNhRTFEVkd0M2VFWnFRVlZDWjA1V1FrRm5UVVJWTlhaaU0wcHJURlZvZG1KSGVHaGliVkY0UldwQlVVSm5UbFpDUVdOTlExVkdkR016VW14amJWSm9ZbFJGVkUxQ1JVZEJNVlZGUTJkM1MxRlhValZhVnpSblZHazFWMHhxUlZKTlFUaEhRVEZWUlVOM2QwbFJNbWhzV1RKMGRtUllVWGhPVkVGNlFtZE9Wa0pCVFUxTVJFNUZWWHBKWjFVeWJIUmtWM2hvWkVjNWVVbEdXa3BWTUVWblVrWk5aMUV5Vm5sa1IyeHRZVmRPYUdSSFZXZFJXRll3WVVjNWVXRllValZOVTBGM1NHZFpTa3R2V2tsb2RtTk9RVkZyUWtab1JucGtXRUozWWpOS01GRkhSbXRsVjFaMVRHMU9kbUpVUVdWR2R6QjRUMFJCTkUxcVkzaE5lbEY2VFZSU1lVWjNNSGxQUkVFMFRXcFJlRTE2VVhwTlZGSmhUVWxIYTAxUmMzZERVVmxFVmxGUlIwVjNTazlVUkVWWFRVSlJSMEV4VlVWRFFYZE9WRzA1ZG1OdFVYUlRSemx6WWtkR2RWcEVSVk5OUWtGSFFURlZSVUozZDBwUlZ6RjZaRWRXZVZwSFJuUk5VazEzUlZGWlJGWlJVVXRFUVhCQ1draHNiR0pwUWs5TWJGbDFUVkpGZDBSM1dVUldVVkZNUkVGb1JHRkhWbXBoTWpreFpFUkZaazFDTUVkQk1WVkZRWGQzVjAwd1VsUk5hVUpVWVZjeE1XSkhSakJpTTBsblZtdHNWRkZUUWtWVmVrVm5UVUkwUjBOVGNVZFRTV0l6UkZGRlNrRlNXVkpqTTFaM1kwYzVlV1JGUW1oYVNHeHNZbWsxYW1JeU1IZG5aMFZwVFVFd1IwTlRjVWRUU1dJelJGRkZRa0ZSVlVGQk5FbENSSGRCZDJkblJVdEJiMGxDUVZGRFl5OVhkMDQyWm5ZeFlVbDFhM3BOYUZkaFVtUmFaMFE1VUd0MU5XRjVUV1ZoYld4T1J6UjBWV3d5VXpZM1RFdEVPVUpTZVdOb1FYWnZOVUVyUld0bU1raExVakpZVkdWeFQyWkhabTlNUkVseE1reFhSemxIYTB0eVJ5OUxRblF2UVZCRU1YaENhR2R0U0c1ck5GbHFjRUZXYmxBMFptRktUSFJTY1dGUVJVVk9Uemd3YldONldXeGhkemhaYW5SUk5ubElXRkJOTkU5UEwyWjZOMlkxT0ZGbGNFaGhkVTFhY0hwNmVrMHJSRzl0VkRCTU1VaENiRmhVZUZwbmRWWkRNQzkxWlVSTlkxTlJUV1k0VDNKV1lreFVkek5rUW5sRU9GZDVOWGQ0UVdkUmRsWXZSR1pFZVZGWVdqZExRMVptWmpsMVpWRllia1J1VDNsR01FNWhMMEpKVlcxcWVtaDJTbTlHWTFnMlV5ODRXVXcyZG1KcE0yNWtZWGxMV1d0dWREVnZjVEpvVmtkbWFGb3JhRFUzZVZvM1pubFdaa0l3YzJGUWFGRnJNMGMyU2pCUEswcHNNbFZYT0ZGMlFUWXdWamg2TkdaQlowMUNRVUZGZDBSUldVcExiMXBKYUhaalRrRlJSVXhDVVVGRVoyZEZRa0ZIVVV4alVHOVFORGhCWVVOeVVXSnhlaXQyUmxBME1tbHliMkpHVUdaeGNGVnJaRlkyUVV4TmVFcENZMk4yU0RsQ2JscG5WbEo2TDNGT1RsTTJSVWcyYkhadlpsa3diRWhUZFV0a2EwSjRMMUJXT0VwT2NHUm9iV012WVVORlMzZG1jV2wwVm5ad016bEVSemxOVWtwVk1YbzNiWFF2VWxKSVNtbFZSREZHTVZGUmVHSlRPR1JNYlc5MFNHWk5TV2xWZHk5elVYSldabVZFTmxCTVVEbHFRM2t2VldsMWQyVkhZM05pYUZFemJ6QklRV2N4ZGtsMlRVSldTREppY0N0bWJEQmlRWEU1VEdzMFdYaEJNRVJ2UzJOSVlsaG1RMFZLYnpkUEwzUkxXV3hhWjFwck5WTmtTMUZsY0VOaFZGRXpOaTlXYjFSeWJIcEpNRTl3VlVjeGRISkZPV1ZWTVN0Sk5reHFNVTlsWlhsa1pqVTVablpZUVdSb0wyaGtaR2hMVkRSblNuSjJka1ppTUhjMGVscHBXSFY2VmxwUVMxQXdkbmxyUVc0NUswazJRVkl5VWtzNFlVRTBORzlLUVV3emQwZ3hTVUU5SWl3aVRVbEpSRGhxUTBOQmRHOURRMUZFVG01WWVXTldSVWwzZFhwQlRrSm5hM0ZvYTJsSE9YY3dRa0ZSYzBaQlJFTkNkV3BGVEUxQmEwZEJNVlZGUW1oTlExUnJkM2hHYWtGVlFtZE9Wa0pCWjAxRVZUVjJZak5LYTB4VmFIWmlSM2hvWW0xUmVFVnFRVkZDWjA1V1FrRmpUVU5WUm5Sak0xSnNZMjFTYUdKVVJWUk5Ra1ZIUVRGVlJVTm5kMHRSVjFJMVdsYzBaMVJwTlZkTWFrVlNUVUU0UjBFeFZVVkRkM2RKVVRKb2JGa3lkSFprV0ZGNFRsUkJla0puVGxaQ1FVMU5URVJPUlZWNlNXZFZNbXgwWkZkNGFHUkhPWGxKUmxwS1ZUQkZaMUpHVFdkUk1sWjVaRWRzYldGWFRtaGtSMVZuVVZoV01HRkhPWGxoV0ZJMVRWTkJkMGhuV1VwTGIxcEphSFpqVGtGUmEwSkdhRVo2WkZoQ2QySXpTakJSUjBaclpWZFdkVXh0VG5aaVZFRmxSbmN3ZUU5RVFUUk5hbU40VFhwUmQwNVVhR0ZHZHpCNVQwUkJORTFxVVhoTmVsRjNUbFJvWVUxSlJ6Wk5VWE4zUTFGWlJGWlJVVWRGZDBwUFZFUkZWMDFDVVVkQk1WVkZRMEYzVGxSdE9YWmpiVkYwVTBjNWMySkhSblZhUkVWVFRVSkJSMEV4VlVWQ2QzZEtVVmN4ZW1SSFZubGFSMFowVFZKTmQwVlJXVVJXVVZGTFJFRndRbHBJYkd4aWFVSlBUR3haZFUxU1JYZEVkMWxFVmxGUlRFUkJhRVJoUjFacVlUSTVNV1JFUlRGTlJFMUhRVEZWUlVGM2QzTk5NRkpVVFdsQ1ZHRlhNVEZpUjBZd1lqTkpaMVpyYkZSUlUwSkZWWGxDUkZwWVNqQmhWMXB3V1RKR01GcFRRa0prV0ZKdllqTktjR1JJYTNoSlJFRmxRbWRyY1docmFVYzVkekJDUTFGRlYwVllUakZqU0VKMlkyNVNRVmxYVWpWYVZ6UjFXVEk1ZEUxSlNVSkpha0ZPUW1kcmNXaHJhVWM1ZHpCQ1FWRkZSa0ZCVDBOQlVUaEJUVWxKUWtOblMwTkJVVVZCZFhBM0syWjBkMWRuUjJSallUWXhjVlpDWXpGQ2RsUnBOVmswTTBKM2FGb3pVMmhLU1d0dFIwbDNaMWxRYzBvNWNISlBZMXBWVm1WSGEwVm9ZelZIV0hjdk9WSk1ZMnhaYldscE1sb3ZURkJGZVhrMlZVbGpVSE5GUm1sa1VucFhURFprT0RSaVpHSTRWRFZwTmtsQlRITklVMmRQWm1OUVR6SkVRMWx2VGpWR0swZ3ZkbFZoY0hkWlIycENORmtyYVhkTlpsRXlaWE5NTTFGRVpFVXJMMjg1TDFvMFRuQm1iemtyWTJZeFJIcGxjRk5YVm5oVWVGSlNhMU5ZTVVjclVYWnJRazB2Y0d4ME5XMDFlQ3RNVlZrd2VqWlZOQ3QxVVhGQ1VWbHphVEJWVURWTmJXSTRSVFpWZDBjeWEyTTROblJ6WlhjMFdVeHhVMk5ZZEZVNVp5OXZPVGxuT1VWcmJrVlRXbTlDT0ZGdGFtZEpNSE5hVVhKRk0wdHZORUV5TDFsRFpUSTFTbWRhTnpGTFl6ZEZMemxJUzFGTE0xWXhkR2xNY25wNGFWTkxNSEU0WWtWT00ycGhZalJ6VVVwWFkzcFNOVTVSU1VSQlVVRkNUVUV3UjBOVGNVZFRTV0l6UkZGRlFrTjNWVUZCTkVsQ1FWRkJiVGh4VDBSQlRrSXpVSEFyT1RoUlpuVlJWVVZVV0dVeFRsSndTblpFYjJONWMyUnZTaXR6ZERoSFdtUmlWMmx1YTA5d04yWnNXVFJZY0VaeU1scEpjVTVJVFhsS2MyWTNPVWxCUzJ4Q1pXOVRXRGQ0VkdacVozSXlPSGRuYTFONWREVlFWMkkzV2tZeldGUXdibWRYYzNoeU1tUjBSamRTZFVGNFVUaEtZbFJ3VUV4a1JWa3hXakp5YUVvMVlYUktkRGRGU2xsRk5rRllTbnBCY2pWVlNqZDViVEJqV1NzNVRrMHpWa0pxVTNCak9XVk1UMDR6Vkd0WldHOVZkakprYlV0MU1VaDZUSFppTVcxRU1HVkllWFZGY2xGUGNtSlVLekZ2UmsxbEwwdG9lbll4TjB4cldEaHFOMDk0VTB0dFVpOUlMMVF5ZVhGbmJYcFBlR2ROTUd4TGVtc3pWMmxSVDI0eGExUlhZVzlZT0VOb1VEWnBVMjFLYTNKM1NWVjVXaXRXTVZWSlVFTlViblJzVVhwRlVVcElPVFpSTlc1WlRsUk1UamhxVm14d05XMXVTMGQwVWtGWWNteDFjbmhNYVRsWk5rVWlYWDAuZXlKaFkzTkZjR2hsYlZCMVlrdGxlU0k2ZXlKamNuWWlPaUpRTFRJMU5pSXNJbXQwZVNJNklrVkRJaXdpZUNJNkltZEpNRWRCU1V4Q1pIVTNWRFV6WVd0eVJtMU5lVWRqYzBZemJqVmtUemROYlhkT1FraExWelZUVmpBaUxDSjVJam9pVTB4WFgzaFRabVo2YkZCWGNraEZWa2t6TUVSSVRWODBaV2RXZDNRelRsRnhaVlZFTjI1TlJuQndjeUo5TENKelpHdEZjR2hsYlZCMVlrdGxlU0k2ZXlKamNuWWlPaUpRTFRJMU5pSXNJbXQwZVNJNklrVkRJaXdpZUNJNklrWjNSV0ZzWms5NlFXWXRialpFTkZGMlJGcEdkbWhTYURWbk5GQkhabTQ1VjNwRVZ6VlJORk15TVVVaUxDSjVJam9pUmtjMGIwMVdOMnR1Y1RKWVJURkdUVGxQTTNveFNVcE9NbE14T0VKT1FVMHRka3RIVFd4M2NtTlRXU0o5TENKaFkzTlZVa3dpT2lKb2RIUndjenBjTDF3dmNHRnNMWFJsYzNRdVlXUjVaVzR1WTI5dFhDOTBhSEpsWldSek1uTnBiWFZzWVhSdmNsd3ZjMlZ5ZG1salpYTmNMMVJvY21WbFJGTXlVMmx0ZFd4aGRHOXlYQzkyTVZ3dmFHRnVaR3hsWEM4eU5HVmxOekkwTWkweFpEZzFMVFE0WkdNdE9ERXpZaTAzTURoaE5UWXdabVZpWlRVaWZRLlQzSlJRSDhSWTA3Ni1rUEJEaXUtT2VGUktwS3JfS19fdEJ1TGxydlJ5aWxzcnEwcDZ3NUxwYzZJNVcwcTVXUDBuTmFSYTZUV1gxZlVzWDZGV2FuTktjMldzNFZiTTN6ODkzcGNEU1JlVlhZWnd5azladnNpaFE3MDNCMmhPM1Btdk8zT1BPRVNaLXFEYUlyREtGRUdQR1JCdXBCWFRWZVFoU2R1SU85alR6TERlbk1kZ0QyUUM1T0FHdVNMRUo3SjhWcWIzSG1XSThsZkktY1BDdjFKSkRjdjExYnZkRk5ULVY3NUhPTEY2M3ZYZjdSTGFlNUtsVDBqUm0xb3c0MVMwb1N3eWs3UGN5MG83cDRLSjYtbEZoZG9zZkRUYlBZenlWSmtId19HQnZjOE01ZTZBXzNxR21tYm1iOW9pQmRYLW1oS0lzRGtWQjhtbkJuR0p3NFFjQSIsImFjc1RyYW5zSUQiOiIyNGVlNzI0Mi0xZDg1LTQ4ZGMtODEzYi03MDhhNTYwZmViZTUiLCJhY3NVUkwiOiJodHRwczpcL1wvcGFsLXRlc3QuYWR5ZW4uY29tXC90aHJlZWRzMnNpbXVsYXRvclwvc2VydmljZXNcL1RocmVlRFMyU2ltdWxhdG9yXC92MVwvaGFuZGxlXC8yNGVlNzI0Mi0xZDg1LTQ4ZGMtODEzYi03MDhhNTYwZmViZTUiLCJtZXNzYWdlVmVyc2lvbiI6IjIuMS4wIiwidGhyZWVEU1NlcnZlclRyYW5zSUQiOiI3YjI2MGQ3My03MTY0LTQxY2QtYTcwYy04YWE4ZDFhMWM5YTIifQ=="
        challengeAction = ThreeDS2ChallengeAction(challengeToken: challengeToken, authorisationToken: "authToken", paymentData: "paymentData")
    }

    func testWrappedComponent() {
        let sut = ThreeDS2CompactActionHandler(apiContext: Dummy.context, appearanceConfiguration: ADYAppearanceConfiguration())
        XCTAssertEqual(sut.wrappedComponent.apiContext.clientKey, Dummy.context.clientKey)
        XCTAssertEqual(sut.wrappedComponent.apiContext.environment.baseURL, Dummy.context.environment.baseURL)

        sut._isDropIn = false
        XCTAssertEqual(sut.wrappedComponent._isDropIn, false)

        sut._isDropIn = true
        XCTAssertEqual(sut.wrappedComponent._isDropIn, true)
    }

    func testFingerprintFlowInvalidFingerprintToken() throws {
        let submitter = AnyThreeDS2FingerprintSubmitterMock()

        let mockedDetails = ThreeDS2Details.completed(ThreeDSResult(payload: "payload"))
        submitter.mockedResult = .success(.details(mockedDetails))

        let service = AnyADYServiceMock()
        service.authenticationRequestParameters = authenticationRequestParameters

        let fingerprintAction = ThreeDS2FingerprintAction(fingerprintToken: "Invalid-token",
                                                          authorisationToken: "AuthToken",
                                                          paymentData: "paymentData")

        let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")
        let sut = ThreeDS2CompactActionHandler(apiContext: Dummy.context, fingerprintSubmitter: submitter, service: service)
        sut.handle(fingerprintAction) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(error):
                let decodingError = error as? DecodingError
                switch decodingError {
                case .dataCorrupted?: ()
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
        let sut = ThreeDS2CompactActionHandler(apiContext: Dummy.context, service: service)
        sut.transaction = transaction
        sut.handle(challengeAction) { challengeResult in
            switch challengeResult {
            case let .success(result):
                switch result {
                case let .details(details):
                    XCTAssertTrue(details is ThreeDS2Details)
                    let details = details as! ThreeDS2Details
                    switch details {
                    case let .completed(result):
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
        let submitter = AnyThreeDS2FingerprintSubmitterMock()

        let service = AnyADYServiceMock()
        service.authenticationRequestParameters = authenticationRequestParameters
        let mockedTransaction = AnyADYTransactionMock(parameters: authenticationRequestParameters)
        service.mockedTransaction = mockedTransaction

        mockedTransaction.onPerformChallenge = { parameters, completion in
            completion(nil, Dummy.error)
        }

        let sut = ThreeDS2CompactActionHandler(apiContext: Dummy.context, fingerprintSubmitter: submitter, service: service)
        sut.transaction = mockedTransaction

        let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")
        sut.handle(challengeAction) { result in
            switch result {
            case let .success(actionHandlerResult):
                switch actionHandlerResult {
                case let .details(additionalDetails as ThreeDS2Details):
                    switch additionalDetails {
                    case let .completed(threeDSResult):
                        struct Payload: Codable {
                            let threeDS2SDKError: String
                            let transStatus: String?
                        }
                        // Check if there is a threeDS2SDKError in the payload.
                        let payload: Payload? = try? Coder.decodeBase64(threeDSResult.payload)
                        XCTAssertNotNil(payload?.threeDS2SDKError)
                        XCTAssertEqual(payload?.transStatus, "U")
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

    func testChallengeFlowInvalidChallengeToken() throws {
        let submitter = AnyThreeDS2FingerprintSubmitterMock()
        let mockedAction = ThreeDS2ChallengeAction(challengeToken: "Invalid-token", authorisationToken: "AuthToken", paymentData: "paymentData")

        let service = AnyADYServiceMock()
        service.authenticationRequestParameters = authenticationRequestParameters
        let mockedTransaction = AnyADYTransactionMock(parameters: authenticationRequestParameters)
        service.mockedTransaction = mockedTransaction

        mockedTransaction.onPerformChallenge = { parameters, completion in
            completion(nil, Dummy.error)
        }

        let sut = ThreeDS2CompactActionHandler(apiContext: Dummy.context, fingerprintSubmitter: submitter, service: service)
        sut.transaction = mockedTransaction

        let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")
        sut.handle(mockedAction) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(error):
                let decodingError = error as? DecodingError
                switch decodingError {
                case .dataCorrupted?: ()
                default:
                    XCTFail()
                }
            }
            resultExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testChallengeFlowMissingTransaction() throws {
        let submitter = AnyThreeDS2FingerprintSubmitterMock()

        let service = AnyADYServiceMock()

        let sut = ThreeDS2CompactActionHandler(apiContext: Dummy.context, fingerprintSubmitter: submitter, service: service)

        let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")
        sut.handle(challengeAction) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(error):
                let componentError = error as? ThreeDS2Component.Error
                switch componentError {
                case .missingTransaction?: ()
                default:
                    XCTFail()
                }
            }
            resultExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFingerprintFlowInvalidEphemeralPublicKey() throws {
        let submitter = AnyThreeDS2FingerprintSubmitterMock()

        let mockedDetails = ThreeDS2Details.completed(ThreeDSResult(payload: "payload"))
        submitter.mockedResult = .success(.details(mockedDetails))

        let service = AnyADYServiceMock()
        service.authenticationRequestParameters = AuthenticationRequestParametersMock(deviceInformation: "device_info",
                                                                                      sdkApplicationIdentifier: "sdkApplicationIdentifier",
                                                                                      sdkTransactionIdentifier: "sdkTransactionIdentifier",
                                                                                      sdkReferenceNumber: "sdkReferenceNumber",
                                                                                      sdkEphemeralPublicKey: "invalid-key",
                                                                                      messageVersion: "messageVersion")

        let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")
        let sut = ThreeDS2CompactActionHandler(apiContext: Dummy.context, fingerprintSubmitter: submitter, service: service)
        sut.handle(fingerprintAction) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(error):
                let decodingError = error as? DecodingError
                switch decodingError {
                case .dataCorrupted?: ()
                default:
                    XCTFail()
                }
            }
            resultExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testFingerprintFlowFrictionless() throws {
        let submitter = AnyThreeDS2FingerprintSubmitterMock()

        let mockedDetails = ThreeDS2Details.completed(ThreeDSResult(payload: "payload"))
        submitter.mockedResult = .success(.details(mockedDetails))

        let service = AnyADYServiceMock()
        service.authenticationRequestParameters = authenticationRequestParameters

        let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")
        let sut = ThreeDS2CompactActionHandler(apiContext: Dummy.context, fingerprintSubmitter: submitter, service: service)
        sut.handle(fingerprintAction) { result in
            switch result {
            case let .success(result):
                switch result {
                case let .details(details):
                    XCTAssertTrue(details is ThreeDS2Details)
                    let details = details as! ThreeDS2Details
                    switch details {
                    case let .completed(threeDSResult):
                        XCTAssertEqual(threeDSResult.payload, "payload")
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

    func testFingerprintFlow3DS1Fallback() throws {
        let submitter = AnyThreeDS2FingerprintSubmitterMock()

        let redirectAction = RedirectAction(url: URL(string: "https://www.adyen.com")!, paymentData: "data")
        submitter.mockedResult = .success(.action(.redirect(redirectAction)))

        let service = AnyADYServiceMock()
        service.authenticationRequestParameters = authenticationRequestParameters

        let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")
        let sut = ThreeDS2CompactActionHandler(apiContext: Dummy.context, fingerprintSubmitter: submitter, service: service)
        sut.handle(fingerprintAction) { result in
            switch result {
            case let .success(result):
                switch result {
                case let .action(action):
                    switch action {
                    case let .redirect(resultRedirectAction):
                        XCTAssertEqual(resultRedirectAction, redirectAction)
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

    func testFingerprintFlowSubmitterFailure() throws {
        let submitter = AnyThreeDS2FingerprintSubmitterMock()

        submitter.mockedResult = .failure(Dummy.error)

        let service = AnyADYServiceMock()
        service.authenticationRequestParameters = authenticationRequestParameters

        let resultExpectation = expectation(description: "Expect ThreeDS2ActionHandler completion closure to be called.")
        let sut = ThreeDS2CompactActionHandler(apiContext: Dummy.context, fingerprintSubmitter: submitter, service: service)
        sut.handle(fingerprintAction) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(error):
                XCTAssertEqual(error as? Dummy, Dummy.error)
            }

            resultExpectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

}
