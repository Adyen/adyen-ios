//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

package final class PaymentButtonViewController: FormViewController {

    private let amount: Amount?

    /// A Boolean value that determines whether the payment button is displayed. Defaults to `true`.
    private let showsSubmitButton: Bool

    /// Called when the payment button is tapped.
    package var onSubmit: (() -> Void)?

    /// Initializes the `PaymentButtonViewController`.
    ///
    /// - Parameters:
    ///   - amount: The amount to display on the payment button.
    ///   - localizationParameters: The localization parameters.
    ///   - theme: The checkout theme to apply.
    ///   - showsSubmitButton: Boolean value that determines whether the payment button is displayed.
    ///   Defaults to `true`.
    package init(
        amount: Amount?,
        localizationParameters: LocalizationParameters? = nil,
        theme: CheckoutTheme = .init(),
        showsSubmitButton: Bool = true
    ) {
        self.amount = amount
        self.showsSubmitButton = showsSubmitButton
        super.init(
            scrollEnabled: false,
            localizationParameters: localizationParameters,
            theme: theme
        )
    }

    @available(*, unavailable)
    package required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override package func viewDidLoad() {
        super.viewDidLoad()
        // TODO: - Implement analytics on this screen
        
        if showsSubmitButton {
            append(payButtonItem)
        }
    }

    /// Shows the loading indicator on the payment button and disables interaction.
    package func startLoading() {
        payButtonItem.showsActivityIndicator = true
        view.isUserInteractionEnabled = false
    }

    /// Hides the loading indicator on the payment button and restores interaction.
    package func stopLoading() {
        payButtonItem.showsActivityIndicator = false
        view.isUserInteractionEnabled = true
    }

    private lazy var payButtonItem: FormButtonItem = {
        let item = FormButtonItem()
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "payButtonItem")
        item.title = AmountAwarePaymentStringsPolicy.payButtonTitle(
            with: amount,
            style: .immediate,
            localizationParameters: localizationParameters
        )
        item.buttonSelectionHandler = { [weak self] in
            self?.onSubmit?()
        }
        return item
    }()
}
