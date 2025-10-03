//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol PaymentComponentRouting {
    func submit(_ data: PaymentComponentData, from component: any PaymentComponent)
    func fail(with error: any Error, from component: any PaymentComponent)
    func cancel(component: any PaymentComponent)
}
