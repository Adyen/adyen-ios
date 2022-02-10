//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A payment method wrapper, with custom `DisplayInformation`.
/// :nodoc:
public struct CustomDisplayablePaymentMethod: PaymentMethod {

    /// :nodoc:
    public var type: String {
        paymentMethod.type
    }

    /// :nodoc:
    public var name: String {
        paymentMethod.name
    }

    /// :nodoc:
    public let paymentMethod: PaymentMethod

    /// :nodoc:
    private let customDisplayInformation: DisplayInformation

    /// :nodoc:
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        paymentMethod.buildComponent(using: builder)
    }

    /// :nodoc:
    public var displayInformation: DisplayInformation {
        localizedDisplayInformation(using: nil)
    }

    /// :nodoc:
    public func localizedDisplayInformation(using parameters: LocalizationParameters?) -> DisplayInformation {
        customDisplayInformation
    }

    /// :nodoc:
    public init(paymentMethod: PaymentMethod, displayInformation: DisplayInformation) {
        self.paymentMethod = paymentMethod
        self.customDisplayInformation = displayInformation
    }

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        fatalError("This class should never be decoded.")
    }

    // MARK: - Decoding
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
}
