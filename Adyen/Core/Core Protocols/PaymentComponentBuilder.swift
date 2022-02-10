//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Builds a certain `PaymentComponent` based on the concrete `PaymentMethod`.
/// :nodoc:
public protocol PaymentComponentBuilder: APIContextAware {
    
    /// Builds a certain `PaymentComponent` based on a `StoredCardPaymentMethod`.
    func build(paymentMethod: StoredCardPaymentMethod) -> PaymentComponent?
    
    /// Builds a certain `PaymentComponent` based on a `StoredPaymentMethod`.
    func build(paymentMethod: StoredPaymentMethod) -> PaymentComponent?
    
    /// Builds a certain `PaymentComponent` based on a `StoredBCMCPaymentMethod`.
    func build(paymentMethod: StoredBCMCPaymentMethod) -> PaymentComponent?
    
    /// Builds a certain `PaymentComponent` based on a `CardPaymentMethod`.
    func build(paymentMethod: CardPaymentMethod) -> PaymentComponent?
    
    /// Builds a certain `PaymentComponent` based on a `BCMCPaymentMethod`.
    func build(paymentMethod: BCMCPaymentMethod) -> PaymentComponent?
    
    /// Builds a certain `PaymentComponent` based on a `IssuerListPaymentMethod`.
    func build(paymentMethod: IssuerListPaymentMethod) -> PaymentComponent?
    
    /// Builds a certain `PaymentComponent` based on a `SEPADirectDebitPaymentMethod`.
    func build(paymentMethod: SEPADirectDebitPaymentMethod) -> PaymentComponent?

    /// Builds a certain `PaymentComponent` based on a `BACSDirectDebitPaymentMethod`.
    func build(paymentMethod: BACSDirectDebitPaymentMethod) -> PaymentComponent?
    
    /// Builds a certain `PaymentComponent` based on a `ACHDirectDebitPaymentMethod`.
    func build(paymentMethod: ACHDirectDebitPaymentMethod) -> PaymentComponent?
    
    /// Builds a certain `PaymentComponent` based on a `ApplePayPaymentMethod`.
    func build(paymentMethod: ApplePayPaymentMethod) -> PaymentComponent?
    
    /// Builds a certain `PaymentComponent` based on a `WeChatPayPaymentMethod`.
    func build(paymentMethod: WeChatPayPaymentMethod) -> PaymentComponent?
    
    /// Builds a certain `PaymentComponent` based on a `QiwiWalletPaymentMethod`.
    func build(paymentMethod: QiwiWalletPaymentMethod) -> PaymentComponent?
    
    /// Builds a certain `PaymentComponent` based on a `MBWayPaymentMethod`.
    func build(paymentMethod: MBWayPaymentMethod) -> PaymentComponent?

    /// Builds a certain `PaymentComponent` based on a `BLIKPaymentMethod`.
    func build(paymentMethod: BLIKPaymentMethod) -> PaymentComponent?

    /// Builds a certain `PaymentComponent` based on a `DokuWalletPaymentMethod`.
    func build(paymentMethod: DokuPaymentMethod) -> PaymentComponent?

    /// Builds a certain `PaymentComponent` based on a `EContextPaymentMethod`.
    func build(paymentMethod: EContextPaymentMethod) -> PaymentComponent?
    
    /// Builds a certain `PaymentComponent` based on a `GiftCardPaymentMethod`.
    func build(paymentMethod: GiftCardPaymentMethod) -> PaymentComponent?
    
    /// Builds a certain `PaymentComponent` based on a `BoletoPaymentMethod`.
    func build(paymentMethod: BoletoPaymentMethod) -> PaymentComponent?
    
    /// Builds a certain `PaymentComponent` based on a `AffirmPaymentMethod`.
    func build(paymentMethod: AffirmPaymentMethod) -> PaymentComponent?
    
    /// Builds a certain `PaymentComponent` based on a `OXXOPaymentMethod`, as a default case.
    func build(paymentMethod: OXXOPaymentMethod) -> PaymentComponent?
    
    /// Builds a certain `PaymentComponent` based on a `MultibancoPaymentMethod`, as a default case.
    func build(paymentMethod: MultibancoPaymentMethod) -> PaymentComponent?
    
    /// Builds a certain `PaymentComponent` based on any `PaymentMethod`, as a default case.
    func build(paymentMethod: PaymentMethod) -> PaymentComponent?
    
}
