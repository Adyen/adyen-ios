//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
#if canImport(AdyenAuthentication)
    import AdyenAuthentication

    @available(iOS 14.0, *)
    final class AuthenticationServiceMock: AuthenticationServiceProtocol {
        var isDeviceSupported: Bool = true
        
        var isRegistration: Bool = true
        
        var onRegister: ((_: RegistrationInput) async throws -> RegistrationOutput)?
        
        func register(with input: RegistrationInput) async throws -> RegistrationOutput {
            if let onRegister = onRegister {
                return try await onRegister(input)
            } else {
                // swiftlint:disable:next line_length
                return try JSONDecoder().decode(RegistrationOutput.self, from: "eyJycElkIjoiQjJOWVNTNTkzMi5jb20uYWR5ZW4uQ2hlY2tvdXREZW1vVUlLaXQiLCJkZXZpY2UiOiJpT1MiLCJhdHRlc3RhdGlvbk9iamVjdCI6Im8yTm1iWFJ2WVhCd2JHVXRZWEJ3WVhSMFpYTjBaMkYwZEZOMGJYU2lZM2cxWTRKWkF1OHdnZ0xyTUlJQ2NxQURBZ0VDQWdZQmd0cWtwZTR3Q2dZSUtvWkl6ajBFQXdJd1R6RWpNQ0VHQTFVRUF3d2FRWEJ3YkdVZ1FYQndJRUYwZEdWemRHRjBhVzl1SUVOQklERXhFekFSQmdOVkJBb01Da0Z3Y0d4bElFbHVZeTR4RXpBUkJnTlZCQWdNQ2tOaGJHbG1iM0p1YVdFd0hoY05Nakl3T0RJMU1UUTFNekU1V2hjTk1qSXdPREk0TVRRMU16RTVXakNCa1RGSk1FY0dBMVVFQXd4QVpHSmhOMll5WkdReU9UQTVNRGMwTnprd04yVTVOREk1T0RKak56UXlZamN5WW1FMFltTmlaREF6TlRJd01EQTFNelpsWm1NME9EVm1OREkwTmpabU1ERWFNQmdHQTFVRUN3d1JRVUZCSUVObGNuUnBabWxqWVhScGIyNHhFekFSQmdOVkJBb01Da0Z3Y0d4bElFbHVZeTR4RXpBUkJnTlZCQWdNQ2tOaGJHbG1iM0p1YVdFd1dUQVRCZ2NxaGtqT1BRSUJCZ2dxaGtqT1BRTUJCd05DQUFUMDdkN1lidGFRM0lVUmtzZjZjNWU5XC9mZGs1TW05TW9BYlwvRzFsVTlTTkhqNGVTXC9OOWVYU3c3b2N2XC95NTdMa3dRWnV0MXZYc3N3dlRMcDg2YlgxSDdvNEgyTUlIek1Bd0dBMVVkRXdFQlwvd1FDTUFBd0RnWURWUjBQQVFIXC9CQVFEQWdUd01JR0FCZ2txaGtpRzkyTmtDQVVFY3pCeHBBTUNBUXFcL2lUQURBZ0VCdjRreEF3SUJBTCtKTWdNQ0FRR1wvaVRNREFnRUJ2NGswS0FRbVFqSk9XVk5UTlRrek1pNWpiMjB1WVdSNVpXNHVRMmhsWTJ0dmRYUkVaVzF2VlVsTGFYU2xCZ1FFYzJ0eklMK0pOZ01DQVFXXC9pVGNEQWdFQXY0azVBd0lCQUwrSk9nTUNBUUF3R3dZSktvWklodmRqWkFnSEJBNHdETCtLZUFnRUJqRTFMalF1TVRBekJna3Foa2lHOTJOa0NBSUVKakFrb1NJRUlIY0h0MjRFUG45RjIrMU00XC9iSmNDV05GR044WjQ1YUJIWm1vSFg0c3BueU1Bb0dDQ3FHU000OUJBTUNBMmNBTUdRQ01GS3U0UXh4NWhza3hwUWdhXC9mXC8zb1pXRnNSMDRza1Z0ZHBMRDM0bnBjRkZUZHluUjJqT2luWlU3U2tlSmRDWkR3SXdDODI3VFpvdDRoYW9nMmxVRkFnTWozYlV4ZTJkQ0lsUTE2MjBEQzZ6R2ZCemtKVjRFeDlcLzU3S3NcLzQ3Z3JNcjlXUUpITUlJQ1F6Q0NBY2lnQXdJQkFnSVFDYnJGNGJ4QUd0blVVNVc4T0JvSVZEQUtCZ2dxaGtqT1BRUURBekJTTVNZd0pBWURWUVFEREIxQmNIQnNaU0JCY0hBZ1FYUjBaWE4wWVhScGIyNGdVbTl2ZENCRFFURVRNQkVHQTFVRUNnd0tRWEJ3YkdVZ1NXNWpMakVUTUJFR0ExVUVDQXdLUTJGc2FXWnZjbTVwWVRBZUZ3MHlNREF6TVRneE9ETTVOVFZhRncwek1EQXpNVE13TURBd01EQmFNRTh4SXpBaEJnTlZCQU1NR2tGd2NHeGxJRUZ3Y0NCQmRIUmxjM1JoZEdsdmJpQkRRU0F4TVJNd0VRWURWUVFLREFwQmNIQnNaU0JKYm1NdU1STXdFUVlEVlFRSURBcERZV3hwWm05eWJtbGhNSFl3RUFZSEtvWkl6ajBDQVFZRks0RUVBQ0lEWWdBRXJsczNvSGROZWJJMWowRG4wZkltSnZIQ1grOFhnQzNxczRKcVdZZFArTkt0RlNWNG1xSm1CQmtTU0xZOHVXY0ducGpUWTcxZU53K1wvb0k0eW5vQnpxWVhuZEc2aldhTDJieW5iTXE5RlhpRVdXTlZucjU0bWZySmhUY0lhWnM2Wm8yWXdaREFTQmdOVkhSTUJBZjhFQ0RBR0FRSFwvQWdFQU1COEdBMVVkSXdRWU1CYUFGS3lSRUZNenZiNW9RZituREtubCt1cmw1WXFoTUIwR0ExVWREZ1FXQkJRKzQxMGNCQm1weWJReCtJUjAxdUhoVjNMam16QU9CZ05WSFE4QkFmOEVCQU1DQVFZd0NnWUlLb1pJemowRUF3TURhUUF3WmdJeEFMdStpSTF6alFVQ3o3ejlabTBKVjFBMXZOYUhMRCtFTUVrbUtlM1IrUlRvZVprY211aTFydmpUcUZRejk3WU5CZ0l4QUtzNDdkRE1nZTBBcEZMRHVrVDVrMk5sVVwvN01LWDh1dE4rZlhyNWFTc3EybVZ4TGdnMzVCRGh2ZUFlN1dKUTV0MmR5WldObGFYQjBXUTVqTUlBR0NTcUdTSWIzRFFFSEFxQ0FNSUFDQVFFeER6QU5CZ2xnaGtnQlpRTUVBZ0VGQURDQUJna3Foa2lHOXcwQkJ3R2dnQ1NBQklJRDZER0NCQjR3TGdJQkFnSUJBUVFtUWpKT1dWTlROVGt6TWk1amIyMHVZV1I1Wlc0dVEyaGxZMnR2ZFhSRVpXMXZWVWxMYVhRd2dnTDVBZ0VEQWdFQkJJSUM3ekNDQXVzd2dnSnlvQU1DQVFJQ0JnR0MycVNsN2pBS0JnZ3Foa2pPUFFRREFqQlBNU013SVFZRFZRUUREQnBCY0hCc1pTQkJjSEFnUVhSMFpYTjBZWFJwYjI0Z1EwRWdNVEVUTUJFR0ExVUVDZ3dLUVhCd2JHVWdTVzVqTGpFVE1CRUdBMVVFQ0F3S1EyRnNhV1p2Y201cFlUQWVGdzB5TWpBNE1qVXhORFV6TVRsYUZ3MHlNakE0TWpneE5EVXpNVGxhTUlHUk1Va3dSd1lEVlFRRERFQmtZbUUzWmpKa1pESTVNRGt3TnpRM09UQTNaVGswTWprNE1tTTNOREppTnpKaVlUUmlZMkprTURNMU1qQXdNRFV6Tm1WbVl6UTROV1kwTWpRMk5tWXdNUm93R0FZRFZRUUxEQkZCUVVFZ1EyVnlkR2xtYVdOaGRHbHZiakVUTUJFR0ExVUVDZ3dLUVhCd2JHVWdTVzVqTGpFVE1CRUdBMVVFQ0F3S1EyRnNhV1p2Y201cFlUQlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDlBd0VIQTBJQUJQVHQzdGh1MXBEY2hSR1N4XC9wemw3Mzk5MlRreWIweWdCdjhiV1ZUMUkwZVBoNUw4MzE1ZExEdWh5XC9cL0xuc3VUQkJtNjNXOWV5ekM5TXVuenB0ZlVmdWpnZll3Z2ZNd0RBWURWUjBUQVFIXC9CQUl3QURBT0JnTlZIUThCQWY4RUJBTUNCUEF3Z1lBR0NTcUdTSWIzWTJRSUJRUnpNSEdrQXdJQkNyK0pNQU1DQVFHXC9pVEVEQWdFQXY0a3lBd0lCQWIrSk13TUNBUUdcL2lUUW9CQ1pDTWs1WlUxTTFPVE15TG1OdmJTNWhaSGxsYmk1RGFHVmphMjkxZEVSbGJXOVZTVXRwZEtVR0JBUnphM01ndjRrMkF3SUJCYitKTndNQ0FRQ1wvaVRrREFnRUF2NGs2QXdJQkFEQWJCZ2txaGtpRzkyTmtDQWNFRGpBTXY0cDRDQVFHTVRVdU5DNHhNRE1HQ1NxR1NJYjNZMlFJQWdRbU1DU2hJZ1FnZHdlM2JnUStmMFhiN1V6ajlzbHdKWTBVWTN4bmpsb0VkbWFnZGZpeW1mSXdDZ1lJS29aSXpqMEVBd0lEWndBd1pBSXdVcTdoREhIbUd5VEdsQ0JyOVwvXC9laGxZV3hIVGl5UlcxMmtzUGZpZWx3VVZOM0tkSGFNNktkbFR0S1I0bDBKa1BBakFMemJ0Tm1pM2lGcWlEYVZRVUNBeVBkdFRGN1owSWlWRFhyYlFNTHJNWjhIT1FsWGdUSDNcL25zcXpcL2p1Q3N5djB3S0FJQkJBSUJBUVFnZmZnNnlMZzczaWs0cThNUDYrbUhuaFNvUUlFbDNCOFgzd1N3dDZMMU1vWXdZQUlCQlFJQkFRUllibTVsZEVKVmNsSlBUMEZ4WTB4MGQxSlROSFI2ZEZOeWNFNW9hbWxGUzA1dk5UZG9OMkY1VFM5dVVEZFNUak5hY2xwbWNDdExTV05rTm13NWJEQXlWWFZtU2tGUGVESTBNbVpKUkcwck1qaDBWbGcyVkdjOVBUQU9BZ0VHQWdFQkJBWkJWRlJGVTFRd0R3SUJCd0lCQVFRSGMyRnVaR0p2ZURBZ0FnRU1BZ0VCQkJnRU9qSXdNakl0TURndE1qWlVNVFE2TlRNNk1Ua3VOelkwV2pBZ0FnRVZBZ0VCQkJneU1ESXlMVEV4TFRJMFZERTBPalV6T2pFNUxqYzJORm9BQUFBQUFBQ2dnRENDQTY0d2dnTlVvQU1DQVFJQ0VBazV0THpwRE1PaGdXVTJOeTltY1VFd0NnWUlLb1pJemowRUF3SXdmREV3TUM0R0ExVUVBd3duUVhCd2JHVWdRWEJ3YkdsallYUnBiMjRnU1c1MFpXZHlZWFJwYjI0Z1EwRWdOU0F0SUVjeE1TWXdKQVlEVlFRTERCMUJjSEJzWlNCRFpYSjBhV1pwWTJGMGFXOXVJRUYxZEdodmNtbDBlVEVUTUJFR0ExVUVDZ3dLUVhCd2JHVWdTVzVqTGpFTE1Ba0dBMVVFQmhNQ1ZWTXdIaGNOTWpJd05ERTVNVE16TXpBeldoY05Nak13TlRFNU1UTXpNekF5V2pCYU1UWXdOQVlEVlFRRERDMUJjSEJzYVdOaGRHbHZiaUJCZEhSbGMzUmhkR2x2YmlCR2NtRjFaQ0JTWldObGFYQjBJRk5wWjI1cGJtY3hFekFSQmdOVkJBb01Da0Z3Y0d4bElFbHVZeTR4Q3pBSkJnTlZCQVlUQWxWVE1Ga3dFd1lIS29aSXpqMENBUVlJS29aSXpqMERBUWNEUWdBRU9kVDVxcHNjeEVYV1c2WVhyUExBaE94dkJ3alZrQlNnNTI3UFBlNDVtYWxNYVwvc0JWUkJWVldSczJvNGo0Q1lCRkFMUWZoTzVWQlwvWXROWlgyQzZUZUtPQ0FkZ3dnZ0hVTUF3R0ExVWRFd0VCXC93UUNNQUF3SHdZRFZSMGpCQmd3Rm9BVTJSZitTMmVRT0V1UzlOdk8xVmVBRkF1UFBja3dRd1lJS3dZQkJRVUhBUUVFTnpBMU1ETUdDQ3NHQVFVRkJ6QUJoaWRvZEhSd09pOHZiMk56Y0M1aGNIQnNaUzVqYjIwdmIyTnpjREF6TFdGaGFXTmhOV2N4TURFd2dnRWNCZ05WSFNBRWdnRVRNSUlCRHpDQ0FRc0dDU3FHU0liM1kyUUZBVENCXC9UQ0J3d1lJS3dZQkJRVUhBZ0l3Z2JZTWdiTlNaV3hwWVc1alpTQnZiaUIwYUdseklHTmxjblJwWm1sallYUmxJR0o1SUdGdWVTQndZWEowZVNCaGMzTjFiV1Z6SUdGalkyVndkR0Z1WTJVZ2IyWWdkR2hsSUhSb1pXNGdZWEJ3YkdsallXSnNaU0J6ZEdGdVpHRnlaQ0IwWlhKdGN5QmhibVFnWTI5dVpHbDBhVzl1Y3lCdlppQjFjMlVzSUdObGNuUnBabWxqWVhSbElIQnZiR2xqZVNCaGJtUWdZMlZ5ZEdsbWFXTmhkR2x2YmlCd2NtRmpkR2xqWlNCemRHRjBaVzFsYm5SekxqQTFCZ2dyQmdFRkJRY0NBUllwYUhSMGNEb3ZMM2QzZHk1aGNIQnNaUzVqYjIwdlkyVnlkR2xtYVdOaGRHVmhkWFJvYjNKcGRIa3dIUVlEVlIwT0JCWUVGUHRuMHcyXC9jN2VTcGlaZFNJMHN3UjJWNG5QNE1BNEdBMVVkRHdFQlwvd1FFQXdJSGdEQVBCZ2txaGtpRzkyTmtEQThFQWdVQU1Bb0dDQ3FHU000OUJBTUNBMGdBTUVVQ0lRQ1VrS0JuTjNQbkwzZ3BObllqdU4xUjE4aWFDZXE3QU9PY2JrVUxCVmdMMEFJZ1J6UWFLOUU4d0ZTb0NqcXF6RHpCUlh3QVZGTVk2ak9OZlczVjlnc3JoeTR3Z2dMNU1JSUNmNkFEQWdFQ0FoQlcrNFBVS1wvK053emVaSTdWYXJtNjlNQW9HQ0NxR1NNNDlCQU1ETUdjeEd6QVpCZ05WQkFNTUVrRndjR3hsSUZKdmIzUWdRMEVnTFNCSE16RW1NQ1FHQTFVRUN3d2RRWEJ3YkdVZ1EyVnlkR2xtYVdOaGRHbHZiaUJCZFhSb2IzSnBkSGt4RXpBUkJnTlZCQW9NQ2tGd2NHeGxJRWx1WXk0eEN6QUpCZ05WQkFZVEFsVlRNQjRYRFRFNU1ETXlNakUzTlRNek0xb1hEVE0wTURNeU1qQXdNREF3TUZvd2ZERXdNQzRHQTFVRUF3d25RWEJ3YkdVZ1FYQndiR2xqWVhScGIyNGdTVzUwWldkeVlYUnBiMjRnUTBFZ05TQXRJRWN4TVNZd0pBWURWUVFMREIxQmNIQnNaU0JEWlhKMGFXWnBZMkYwYVc5dUlFRjFkR2h2Y21sMGVURVRNQkVHQTFVRUNnd0tRWEJ3YkdVZ1NXNWpMakVMTUFrR0ExVUVCaE1DVlZNd1dUQVRCZ2NxaGtqT1BRSUJCZ2dxaGtqT1BRTUJCd05DQUFTU3ptTzlmWWF4cXlnS094emhyXC9zRWxJQ1JyUFl4MzZiTEtEVnZSRXZoSWVWWDNSS05qYnFDZkpXK1NmcStNOHF1elFRWjhTOURKZnIwdnJQTGczNjZvNEgzTUlIME1BOEdBMVVkRXdFQlwvd1FGTUFNQkFmOHdId1lEVlIwakJCZ3dGb0FVdTdEZW9WZ3ppSnFraXBuZXZyM3JyOXJMSktzd1JnWUlLd1lCQlFVSEFRRUVPakE0TURZR0NDc0dBUVVGQnpBQmhpcG9kSFJ3T2k4dmIyTnpjQzVoY0hCc1pTNWpiMjB2YjJOemNEQXpMV0Z3Y0d4bGNtOXZkR05oWnpNd053WURWUjBmQkRBd0xqQXNvQ3FnS0lZbWFIUjBjRG92TDJOeWJDNWhjSEJzWlM1amIyMHZZWEJ3YkdWeWIyOTBZMkZuTXk1amNtd3dIUVlEVlIwT0JCWUVGTmtYXC9rdG5rRGhMa3ZUYnp0VlhnQlFManozSk1BNEdBMVVkRHdFQlwvd1FFQXdJQkJqQVFCZ29xaGtpRzkyTmtCZ0lEQkFJRkFEQUtCZ2dxaGtqT1BRUURBd05vQURCbEFqRUFqVyttbjZIZzVPeGJUbk9La244OWVGT1lqXC9UYUgxZ2V3M1ZLXC9qaW9UQ3FER2hxcURhWmtiZUc1aytqUlZVenRBakJuT3l5MDRlZzNCM2ZMMWV4MnFCbzZWVHNcL05Xckl4ZWFTc09GaHZvQkphZVJmSzZsczRSRUNxc3hoMlRpM2Mwb3dnZ0pETUlJQnlhQURBZ0VDQWdndHhmeUkwc1ZMbFRBS0JnZ3Foa2pPUFFRREF6Qm5NUnN3R1FZRFZRUUREQkpCY0hCc1pTQlNiMjkwSUVOQklDMGdSek14SmpBa0JnTlZCQXNNSFVGd2NHeGxJRU5sY25ScFptbGpZWFJwYjI0Z1FYVjBhRzl5YVhSNU1STXdFUVlEVlFRS0RBcEJjSEJzWlNCSmJtTXVNUXN3Q1FZRFZRUUdFd0pWVXpBZUZ3MHhOREEwTXpBeE9ERTVNRFphRncwek9UQTBNekF4T0RFNU1EWmFNR2N4R3pBWkJnTlZCQU1NRWtGd2NHeGxJRkp2YjNRZ1EwRWdMU0JITXpFbU1DUUdBMVVFQ3d3ZFFYQndiR1VnUTJWeWRHbG1hV05oZEdsdmJpQkJkWFJvYjNKcGRIa3hFekFSQmdOVkJBb01Da0Z3Y0d4bElFbHVZeTR4Q3pBSkJnTlZCQVlUQWxWVE1IWXdFQVlIS29aSXpqMENBUVlGSzRFRUFDSURZZ0FFbU9rdlBVQnlwTzJUSW5LQkV4emRFSlh4eGFOT2Nkd1VGdGtPNWFZRktuZGtlMTlPT05PN0hFUzFmXC9VZnRqSmlYY25waEZ0UE1FOFJXZ0Q5V0ZnTXBmVVBMRTBIUnhOMTJwZVhsMjh4WE8wcm5Yc2dPOWk1Vk5sZW1hUTZVUW94bzBJd1FEQWRCZ05WSFE0RUZnUVV1N0Rlb1ZnemlKcWtpcG5ldnIzcnI5ckxKS3N3RHdZRFZSMFRBUUhcL0JBVXdBd0VCXC96QU9CZ05WSFE4QkFmOEVCQU1DQVFZd0NnWUlLb1pJemowRUF3TURhQUF3WlFJeEFJUHB3Y1FXWGhwZE5Calo3ZVwvMGJBNEFSa3U0MzdKR0VjVVBcL2VaNmpLR21hODdDQTlTYzlaUEdkTGhxMzZvakZRSXdiV2FLRU1yVURkUlB6WTFEUHJTS1k2VXpidU50MmhlM1pCXC9JVXliNWlHSjBPUXNYVzh0UnFBem9HQVBub3JJb0FBQXhnZnd3Z2ZrQ0FRRXdnWkF3ZkRFd01DNEdBMVVFQXd3blFYQndiR1VnUVhCd2JHbGpZWFJwYjI0Z1NXNTBaV2R5WVhScGIyNGdRMEVnTlNBdElFY3hNU1l3SkFZRFZRUUxEQjFCY0hCc1pTQkRaWEowYVdacFkyRjBhVzl1SUVGMWRHaHZjbWwwZVRFVE1CRUdBMVVFQ2d3S1FYQndiR1VnU1c1akxqRUxNQWtHQTFVRUJoTUNWVk1DRUFrNXRMenBETU9oZ1dVMk55OW1jVUV3RFFZSllJWklBV1VEQkFJQkJRQXdDZ1lJS29aSXpqMEVBd0lFUmpCRUFpQXMwTVRSTHcwUTJXb2lXMVgrR0lEVWQzdWFFc0JLOUxhcjJnbmtFcmsydndJZ0FObWY4T2lpbkxKdkw0ZTk4ejFFMUFzSDBVV2l5U2VuSWJHRkw2QU5UbUlBQUFBQUFBQm9ZWFYwYUVSaGRHRllwQzh0d3RUcmlmZFwvaUtMRCtsUm5OS3E1WmFKVjNHbmpFTXZVeUE2N21DbGZRQUFBQUFCaGNIQmhkSFJsYzNSa1pYWmxiRzl3QUNEYnBcL0xkS1FrSFI1QitsQ21DeDBLM0s2Uzh2UU5TQUFVMjc4U0Y5Q1JtOEtVQkFnTW1JQUVoV0NEMDdkN1lidGFRM0lVUmtzZjZjNWU5XC9mZGs1TW05TW9BYlwvRzFsVTlTTkhpSllJRDRlU1wvTjllWFN3N29jdlwveTU3TGt3UVp1dDF2WHNzd3ZUTHA4NmJYMUg3IiwidmVyc2lvbiI6MX0".dataFromBase64URL())
            }
        }
        
        var onAuthenticate: ((_: AuthenticationInput) async throws -> AuthenticationOutput)?
    
        func authenticate(with input: AuthenticationInput) async throws -> AuthenticationOutput {
            if let onAuthenticate = onAuthenticate {
                return try await onAuthenticate(input)
            } else if isRegistration {
                throw AdyenAuthenticationError.noStoredCredentialsMatch(nil)
            } else {
                // swiftlint:disable:next line_length
                return try JSONDecoder().decode(AuthenticationOutput.self, from: "eyJycElkIjoiQjJOWVNTNTkzMi5jb20uYWR5ZW4uQ2hlY2tvdXREZW1vVUlLaXQiLCJ2ZXJzaW9uIjoxLCJkZXZpY2UiOiJpT1MiLCJhc3NlcnRpb25PYmplY3QiOiJvbWx6YVdkdVlYUjFjbVZZUnpCRkFpQmxObG9HV2thc0ZkMDJrK1NTd0hLY0oxWkdrczkxeUZjaG02b2Y3UEdnbEFJaEFKK1prNzFxdkJFaGllR0xqMzFXcG5tckdjWHlZV2VsYUREUnhhV2licGtLY1dGMWRHaGxiblJwWTJGMGIzSkVZWFJoV0NVdkxjTFU2NG4zZjRpaXdcL3BVWnpTcXVXV2lWZHhwNHhETDFNZ091NWdwWDBBQUFBQUIiLCJjcmVkZW50aWFsSWQiOiIyNmZ5M1NrSkIwZVFmcFFwZ3NkQ3R5dWt2TDBEVWdBRk51XC9FaGZRa1p2QT0ifQ".dataFromBase64URL())
            }
        }
    
        func reset() throws {}
    
        func checkSupport() throws -> CheckSupportOutput {
            try JSONDecoder().decode(CheckSupportOutput.self, from: Data(base64Encoded: "eyJkZXZpY2UiOiJpT1MifQ")!)
        }
    
    }

    extension String {
    
        func dataFromBase64URL() throws -> Data {
            var base64 = self
            base64 = base64.replacingOccurrences(of: "-", with: "+")
            base64 = base64.replacingOccurrences(of: "_", with: "/")
            while base64.count % 4 != 0 {
                base64 = base64.appending("=")
            }
            guard let data = Data(base64Encoded: base64) else {
                throw AdyenAuthenticationError.invalidBase64String
            }
            return data
        }
        
        func toBase64URL() -> String {
            var result = self
            result = result.replacingOccurrences(of: "+", with: "-")
            result = result.replacingOccurrences(of: "/", with: "_")
            result = result.replacingOccurrences(of: "=", with: "")
            return result
        }
    }
#endif
