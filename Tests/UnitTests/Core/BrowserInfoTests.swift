//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Testing

/// Making this test serialized as BrowserInfo deals with some static vars and hence cannot be run in parallel.
@Suite(.serialized)
struct BrowserInfoTests {

    @Test func browserInfoInitialize() async {
        let browserInfo = await BrowserInfo.initialize()
        #expect(browserInfo?.userAgent != nil)
    }
    
    @Test func paymentComponentDataBrowserInfo() async {
        let data = PaymentComponentData(paymentMethodDetails: InstantPaymentDetails(type: .payPal), amount: nil, order: nil)

        var updatedPaymentComponentData: PaymentComponentData? = nil
        await confirmation("onImageLoaded called") { confirm in
            await withCheckedContinuation { continuation in
                data.dataByAddingBrowserInfo {
                    updatedPaymentComponentData = $0
                    confirm()
                    continuation.resume()
                }
            }
        }

        #expect(updatedPaymentComponentData?.browserInfo?.userAgent != nil)
    }
}
