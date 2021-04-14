//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A payment method thats to be shown as preselected payment method that is ready to be submitted.
/// :nodoc:
public struct PreselectedPaymentMethod: PaymentMethod {

    /// :nodoc:
    public let type: String

    /// :nodoc:
    public let name: String

    /// :nodoc:
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? { nil }

    /// :nodoc:
    public var displayInformation: DisplayInformation {
        localizedDisplayInformation(using: nil)
    }

    /// :nodoc:
    public func localizedDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        customDisplayInformation ?? DisplayInformation(title: name, subtitle: nil, logoName: type)
    }

    /// :nodoc:
    public init(paymentMethod: PaymentMethod, displayInformation: DisplayInformation) {
        self.type = paymentMethod.type
        self.name = paymentMethod.name
        self.customDisplayInformation = displayInformation
    }

    /// :nodoc:
    private var customDisplayInformation: DisplayInformation?

    // MARK: - Decoding
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
}
