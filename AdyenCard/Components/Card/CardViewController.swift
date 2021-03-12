//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif

internal class CardViewController: FormViewController, Observer {

    private let configuration: CardComponent.Configuration
    private let formStyle: FormComponentStyle
    private let payment: Payment?
    private let environment: Environment
    private let supportedCardTypes: [CardType]
    private let scope: String

    private let maxCardsVisible = 4
    private let publicBinLenght = 6
    private let throttler = Throttler(minimumDelay: 0.5)

    private var topCardTypes: [CardType] {
        Array(supportedCardTypes.prefix(maxCardsVisible))
    }

    // MARK: Init view controller

    internal init(configuration: CardComponent.Configuration,
                  formStyle: FormComponentStyle,
                  payment: Payment?,
                  environment: Environment,
                  supportedCardTypes: [CardType],
                  scope: String) {
        self.configuration = configuration
        self.formStyle = formStyle
        self.payment = payment
        self.environment = environment
        self.supportedCardTypes = supportedCardTypes
        self.scope = scope
        super.init(style: formStyle)
    }

    override internal func viewDidLoad() {
        append(numberItem)
        numberItem.showLogos(for: topCardTypes)

        if configuration.showsSecurityCodeField {
            let splitTextItem = FormSplitItem(items: [expiryDateItem, securityCodeItem], style: formStyle.textField)
            append(splitTextItem)
        } else {
            append(expiryDateItem)
        }

        if configuration.showsHolderNameField {
            append(holderNameItem)
        }

        if configuration.showsStorePaymentMethodField {
            append(storeDetailsItem)
        }

        append(button.withPadding(padding: .init(top: 8, left: 0, bottom: -16, right: 0)))

        super.viewDidLoad()
    }

    // MARK: Public methods

    public weak var cardDelegate: CardViewControllerDelegate?

    public var card: Card {
        Card(number: numberItem.value,
             securityCode: configuration.showsSecurityCodeField ? securityCodeItem.nonEmptyValue : nil,
             expiryMonth: expiryDateItem.value[0...1],
             expiryYear: "20" + expiryDateItem.value[2...3],
             holder: configuration.showsHolderNameField ? holderNameItem.nonEmptyValue : nil)
    }

    public var storePayment: Bool {
        configuration.showsStorePaymentMethodField ? storeDetailsItem.value : false
    }

    /// :nodoc:
    public func stopLoading() {
        button.showsActivityIndicator = false
        view.isUserInteractionEnabled = true
    }

    /// :nodoc:
    public func startLoading() {
        button.showsActivityIndicator = true
        view.isUserInteractionEnabled = false
    }

    public func update(binInfo: BinLookupResponse) {
        self.securityCodeItem.update(cardBrands: binInfo.brands ?? [])

        guard let brands = binInfo.brands else { return }
        self.numberItem.showLogos(for: brands.isEmpty ? self.topCardTypes : brands.map(\.type))
    }

    // MARK: Items

    internal lazy var numberItem: FormCardNumberItem = {
        let item = FormCardNumberItem(supportedCardTypes: supportedCardTypes,
                                      environment: environment,
                                      style: formStyle.textField,
                                      localizationParameters: localizationParameters)

        observe(item.$binValue) { [weak self] in self?.didReceived(bin: $0) }

        item.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "numberItem")
        return item
    }()

    internal lazy var expiryDateItem: FormTextInputItem = {
        let expiryDateItem = FormTextInputItem(style: formStyle.textField)
        expiryDateItem.title = ADYLocalizedString("adyen.card.expiryItem.title", localizationParameters)
        expiryDateItem.placeholder = ADYLocalizedString("adyen.card.expiryItem.placeholder", localizationParameters)
        expiryDateItem.formatter = CardExpiryDateFormatter()
        expiryDateItem.validator = CardExpiryDateValidator()
        expiryDateItem.validationFailureMessage = ADYLocalizedString("adyen.card.expiryItem.invalid", localizationParameters)
        expiryDateItem.keyboardType = .numberPad
        expiryDateItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "expiryDateItem")

        return expiryDateItem
    }()

    internal lazy var securityCodeItem: FormCardSecurityCodeItem = {
        let securityCodeItem = FormCardSecurityCodeItem(environment: environment,
                                                        style: formStyle.textField,
                                                        localizationParameters: localizationParameters)
        securityCodeItem.localizationParameters = self.localizationParameters
        securityCodeItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "securityCodeItem")
        return securityCodeItem
    }()

    internal lazy var holderNameItem: FormTextInputItem = {
        let holderNameItem = FormTextInputItem(style: formStyle.textField)
        holderNameItem.title = ADYLocalizedString("adyen.card.nameItem.title", localizationParameters)
        holderNameItem.placeholder = ADYLocalizedString("adyen.card.nameItem.placeholder", localizationParameters)
        holderNameItem.validator = LengthValidator(minimumLength: 2)
        holderNameItem.validationFailureMessage = ADYLocalizedString("adyen.card.nameItem.invalid", localizationParameters)
        holderNameItem.autocapitalizationType = .words
        holderNameItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "holderNameItem")

        return holderNameItem
    }()

    internal lazy var storeDetailsItem: FormSwitchItem = {
        let storeDetailsItem = FormSwitchItem(style: formStyle.switch)
        storeDetailsItem.title = ADYLocalizedString("adyen.card.storeDetailsButton", localizationParameters)
        storeDetailsItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "storeDetailsItem")

        return storeDetailsItem
    }()

    internal lazy var button: FormButtonItem = {
        let item = FormButtonItem(style: formStyle.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "payButtonItem")
        item.title = ADYLocalizedSubmitButtonTitle(with: payment?.amount,
                                                   style: .immediate,
                                                   localizationParameters)
        item.buttonSelectionHandler = { [weak self] in
            self?.cardDelegate?.didSelectSubmitButton()
        }
        return item
    }()

    private func didReceived(bin: String) {
        self.securityCodeItem.selectedCard = supportedCardTypes.adyen.type(forCardNumber: bin)
        self.cardDelegate?.didChangeBIN(String(bin.prefix(publicBinLenght)))

        throttler.throttle { [weak self] in self?.cardDelegate?.didChangeBIN(bin) }
    }
    
}

internal protocol CardViewControllerDelegate: AnyObject {

    func didSelectSubmitButton()

    func didChangeBIN(_ value: String)

}

private extension FormValueItem where ValueType == String {
    var nonEmptyValue: String? {
        self.value.isEmpty ? nil : self.value
    }
}
