//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif
import UIKit

/// A component that provides a form for ACH Direct Debit payment.
public final class ACHDirectDebitComponent: PaymentComponent, PresentableComponent, Localizable, LoadingComponent, PublicKeyConsumer {
    
    private enum ViewIdentifier {
        static let headerItem = "headerItem"
        static let holderNameItem = "holderNameItem"
        static let bankAccountNumberItem = "bankAccountNumberItem"
        static let bankRoutingNumberItem = "bankRoutingNumberItem"
        static let billingAddressItem = "billingAddressItem"
        static let payButtonItem = "payButtonItem"
    }
    
    /// :nodoc:
    public let apiContext: APIContext
    
    /// :nodoc:
    public var paymentMethod: PaymentMethod {
        achDirectDebitPaymentMethod
    }

    /// :nodoc:
    public weak var delegate: PaymentComponentDelegate?
    
    /// Component configuration
    public let configuration: Configuration

    /// :nodoc:
    public lazy var viewController: UIViewController = SecuredViewController(child: formViewController, style: style)

    /// :nodoc:
    public var localizationParameters: LocalizationParameters?

    /// Describes the component's UI style.
    public let style: FormComponentStyle

    /// :nodoc:
    public let requiresModalPresentation: Bool = true

    /// :nodoc:
    public let shopperInformation: PrefilledShopperInformation?
    
    /// :nodoc:
    public let publicKeyProvider: AnyPublicKeyProvider
    
    /// :nodoc:
    private var defaultCountryCode: String {
        payment?.countryCode ?? configuration.billingAddressCountryCodes.first ?? "US"
    }
    
    private let achDirectDebitPaymentMethod: ACHDirectDebitPaymentMethod

    // MARK: - Init
    
    /// Initializes the ACH Direct Debit component.
    /// - Parameters:
    ///   - configuration: Configuration for the component.
    ///   - paymentMethod: The ACH Direct Debit payment method.
    ///   - apiContext: The component's API context.
    ///   - shopperInformation: The shopper's information.
    ///   - localizationParameters: The localization parameters.
    ///   - style: The component's style.
    public convenience init(configuration: Configuration,
                            paymentMethod: ACHDirectDebitPaymentMethod,
                            apiContext: APIContext,
                            shopperInformation: PrefilledShopperInformation? = nil,
                            localizationParameters: LocalizationParameters? = nil,
                            style: FormComponentStyle) {
        self.init(configuration: configuration,
                  paymentMethod: paymentMethod,
                  apiContext: apiContext,
                  publicKeyProvider: PublicKeyProvider(apiContext: apiContext),
                  shopperInformation: shopperInformation,
                  localizationParameters: localizationParameters,
                  style: style)
    }
    
    /// :nodoc:
    internal init(configuration: Configuration,
                  paymentMethod: ACHDirectDebitPaymentMethod,
                  apiContext: APIContext,
                  publicKeyProvider: AnyPublicKeyProvider,
                  shopperInformation: PrefilledShopperInformation? = nil,
                  localizationParameters: LocalizationParameters? = nil,
                  style: FormComponentStyle) {
        self.configuration = configuration
        self.achDirectDebitPaymentMethod = paymentMethod
        self.apiContext = apiContext
        self.publicKeyProvider = publicKeyProvider
        self.localizationParameters = localizationParameters
        self.shopperInformation = shopperInformation
        self.style = style
    }
    
    /// :nodoc:
    public func stopLoading() {
        payButton.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }
    
    private func startLoading() {
        payButton.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false
    }
    
    private func didSelectSubmitButton() {
        guard formViewController.validate() else { return }
        
        startLoading()
        
        fetchCardPublicKey(notifyingDelegateOnFailure: true) { [weak self] publicKey in
            self?.submitEncryptedData(publicKey: publicKey)
        }
    }
    
    private func submitEncryptedData(publicKey: String) {
        do {
            let encryptedBankAccountNumber = try BankDetailsEncryptor.encrypt(accountNumber: bankAccountNumberItem.value,
                                                                              with: publicKey)
            let encryptedBankRoutingNumber = try BankDetailsEncryptor.encrypt(routingNumber: bankRoutingNumberItem.value,
                                                                              with: publicKey)
            
            let details = ACHDirectDebitDetails(paymentMethod: achDirectDebitPaymentMethod,
                                                holderName: holderNameItem.value,
                                                encryptedBankAccountNumber: encryptedBankAccountNumber,
                                                encryptedBankRoutingNumber: encryptedBankRoutingNumber,
                                                billingAddress: billingAddressItem.value)
            
            submit(data: PaymentComponentData(paymentMethodDetails: details, amount: payment?.amount, order: order))
        } catch {
            delegate?.didFail(with: error, from: self)
        }
    }
    
    // MARK: - Form Items
    
    internal lazy var headerItem: FormLabelItem = {
        let item = FormLabelItem(text: localizedString(.achBankAccountTitle, localizationParameters),
                                 style: style.sectionHeader)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                      postfix: ViewIdentifier.headerItem)
        return item
    }()
    
    internal lazy var holderNameItem: FormTextInputItem = {
        let textItem = FormTextInputItem(style: style.textField)

        let localizedTitle = localizedString(.achAccountHolderNameFieldTitle, localizationParameters)
        textItem.title = localizedTitle
        textItem.placeholder = localizedTitle

        textItem.validator = LengthValidator(minimumLength: 1, maximumLength: 70)

        textItem.validationFailureMessage = localizedString(.achAccountHolderNameFieldInvalid, localizationParameters)

        textItem.autocapitalizationType = .words

        textItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                          postfix: ViewIdentifier.holderNameItem)
        return textItem
    }()
    
    internal lazy var bankAccountNumberItem: FormTextInputItem = {
        let textItem = FormTextInputItem(style: style.textField)

        let localizedTitle = localizedString(.achAccountNumberFieldTitle, localizationParameters)
        textItem.title = localizedTitle
        textItem.placeholder = localizedTitle

        textItem.validator = NumericStringValidator(minimumLength: 4, maximumLength: 17)
        textItem.formatter = NumericFormatter()

        textItem.validationFailureMessage = localizedString(.achAccountNumberFieldInvalid, localizationParameters)

        textItem.autocapitalizationType = .none
        textItem.keyboardType = .numberPad

        textItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                          postfix: ViewIdentifier.bankAccountNumberItem)
        return textItem
    }()
    
    internal lazy var bankRoutingNumberItem: FormTextInputItem = {
        let textItem = FormTextInputItem(style: style.textField)

        let localizedTitle = localizedString(.achAccountLocationFieldTitle, localizationParameters)
        textItem.title = localizedTitle
        textItem.placeholder = localizedTitle

        textItem.validator = NumericStringValidator(minimumLength: 9, maximumLength: 9)
        textItem.formatter = NumericFormatter()

        textItem.validationFailureMessage = localizedString(.achAccountLocationFieldInvalid, localizationParameters)

        textItem.autocapitalizationType = .none
        textItem.keyboardType = .numberPad

        textItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                          postfix: ViewIdentifier.bankRoutingNumberItem)
        return textItem
    }()
    
    internal lazy var billingAddressItem: FormAddressItem = {
        let identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                     postfix: ViewIdentifier.billingAddressItem)

        var initialCountry = defaultCountryCode
        if let prefillCountryCode = shopperInformation?.billingAddress?.country,
           configuration.billingAddressCountryCodes.contains(prefillCountryCode) {
            initialCountry = prefillCountryCode
        }
        let item = FormAddressItem(initialCountry: initialCountry,
                                   style: style.addressStyle,
                                   localizationParameters: localizationParameters,
                                   identifier: identifier,
                                   supportedCountryCodes: configuration.billingAddressCountryCodes)
        shopperInformation?.billingAddress.map { item.value = $0 }
        item.style.backgroundColor = UIColor.Adyen.lightGray
        return item
    }()
    
    internal lazy var payButton: FormButtonItem = {
        let item = FormButtonItem(style: style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                      postfix: ViewIdentifier.payButtonItem)
        item.title = localizedString(.confirmPurchase, localizationParameters)
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        return item
    }()
    
    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: style)
        formViewController.localizationParameters = localizationParameters
        formViewController.delegate = self

        formViewController.title = paymentMethod.name.uppercased()

        formViewController.append(FormSpacerItem())
        formViewController.append(headerItem.addingDefaultMargins())
        formViewController.append(FormSpacerItem())
        formViewController.append(holderNameItem)
        formViewController.append(bankAccountNumberItem)
        formViewController.append(bankRoutingNumberItem)
        formViewController.append(FormSpacerItem())
        if configuration.showsBillingAddress {
            formViewController.append(billingAddressItem)
        }
        formViewController.append(FormSpacerItem(numberOfSpaces: 2))
        formViewController.append(payButton)

        return formViewController
    }()
}

/// :nodoc:
extension ACHDirectDebitComponent: TrackableComponent {
    
    /// :nodoc:
    public func viewDidLoad(viewController: UIViewController) {
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, context: apiContext)
        // just cache the public key value
        fetchCardPublicKey(notifyingDelegateOnFailure: false)
    }
}

extension ACHDirectDebitComponent {
    
    /// Configuration for the ACH Direct Debit Component
    public struct Configuration {
        
        /// Determines whether the billing address should be displayed or not.
        /// Defaults to `true`.
        public var showsBillingAddress: Bool
        
        /// List of ISO country codes that is supported for the billing address.
        /// Defaults to ["US", "PR"].
        public var billingAddressCountryCodes: [String]
        
        /// Initializes the configuration for ACH Direct Debit Component.
        /// - Parameters:
        ///   - showsBillingAddress: Determines whether the billing address should be displayed or not.
        ///   Defaults to `true`.
        ///   - billingAddressCountryCodes: ISO country codes that is supported for the billing address.
        ///   Defaults to ["US", "PR"].
        public init(showsBillingAddress: Bool = true,
                    billingAddressCountryCodes: [String] = ["US", "PR"]) {
            self.showsBillingAddress = showsBillingAddress
            self.billingAddressCountryCodes = billingAddressCountryCodes
        }
    }
}
