//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import Testing

struct BrowserInfoTests {

    @Test @MainActor func browserInfoInitialize() async {
        let browserInfo = await BrowserInfo()
        #expect(browserInfo?.userAgent != nil)
        #expect(browserInfo?.webView == nil)
    }
    
    @Test func paymentComponentDataBrowserInfo() async {
        let data = PaymentComponentData(paymentMethodDetails: InstantPaymentDetails(type: .payPal), amount: nil, order: nil)
        let updatedPaymentComponentData = await data.replacing(browserInfo: BrowserInfo())
        #expect(updatedPaymentComponentData.browserInfo?.userAgent != nil)
    }

    @Test func initialization_whenCached() async {
        let mockedCachedUserAgent = "testValue"
        BrowserInfo.cachedUserAgent = mockedCachedUserAgent
        let browserInfo = await BrowserInfo()
        #expect(browserInfo?.userAgent == mockedCachedUserAgent)
    }
}
