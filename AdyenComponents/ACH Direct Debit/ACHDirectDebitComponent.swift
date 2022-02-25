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
public final class ACHDirectDebitComponent: PaymentComponent, PresentableComponent, LoadingComponent, PublicKeyConsumer {
    
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
    public lazy var viewController: UIViewController = SecuredViewController(child: formViewController,
                                                                             style: configuration.style)

    /// :nodoc:
    public let requiresModalPresentation: Bool = true
    
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
    ///   - apiContext: The component's API context.
    ///   - paymentMethod: The ACH Direct Debit payment method.
    ///   - configuration: Configuration for the component.
    public convenience init(apiContext: APIContext,
                            paymentMethod: ACHDirectDebitPaymentMethod,
                            configuration: Configuration = .init()) {
        self.init(apiContext: apiContext,
                  paymentMethod: paymentMethod,
                  configuration: configuration,
                  publicKeyProvider: PublicKeyProvider(apiContext: apiContext))
    }
    
    /// :nodoc:
    internal init(apiContext: APIContext,
                  paymentMethod: ACHDirectDebitPaymentMethod,
                  configuration: Configuration = .init(),
                  publicKeyProvider: AnyPublicKeyProvider) {
        self.apiContext = apiContext
        self.achDirectDebitPaymentMethod = paymentMethod
        self.configuration = configuration
        self.publicKeyProvider = publicKeyProvider
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
            
            submit(data: PaymentComponentData(paymentMethodDetails: details, amount: amountToPay, order: order))
        } catch {
            delegate?.didFail(with: error, from: self)
        }
    }
    
    // MARK: - Form Items
    
    internal lazy var headerItem: FormLabelItem = {
        let item = FormLabelItem(text: localizedString(.achBankAccountTitle, configuration.localizationParameters),
                                 style: configuration.style.sectionHeader)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                      postfix: ViewIdentifier.headerItem)
        return item
    }()
    
    internal lazy var holderNameItem: FormTextInputItem = {
        let textItem = FormTextInputItem(style: configuration.style.textField)

        let localizedTitle = localizedString(.achAccountHolderNameFieldTitle, configuration.localizationParameters)
        textItem.title = localizedTitle
        textItem.placeholder = localizedTitle

        textItem.validator = LengthValidator(minimumLength: 1, maximumLength: 70)

        textItem.validationFailureMessage = localizedString(.achAccountHolderNameFieldInvalid, configuration.localizationParameters)

        textItem.autocapitalizationType = .words

        textItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                          postfix: ViewIdentifier.holderNameItem)
        return textItem
    }()
    
    internal lazy var bankAccountNumberItem: FormTextInputItem = {
        let textItem = FormTextInputItem(style: configuration.style.textField)

        let localizedTitle = localizedString(.achAccountNumberFieldTitle, configuration.localizationParameters)
        textItem.title = localizedTitle
        textItem.placeholder = localizedTitle

        textItem.validator = NumericStringValidator(minimumLength: 4, maximumLength: 17)
        textItem.formatter = NumericFormatter()

        textItem.validationFailureMessage = localizedString(.achAccountNumberFieldInvalid, configuration.localizationParameters)

        textItem.autocapitalizationType = .none
        textItem.keyboardType = .numberPad

        textItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                          postfix: ViewIdentifier.bankAccountNumberItem)
        return textItem
    }()
    
    internal lazy var bankRoutingNumberItem: FormTextInputItem = {
        let textItem = FormTextInputItem(style: configuration.style.textField)

        let localizedTitle = localizedString(.achAccountLocationFieldTitle, configuration.localizationParameters)
        textItem.title = localizedTitle
        textItem.placeholder = localizedTitle

        textItem.validator = NumericStringValidator(minimumLength: 9, maximumLength: 9)
        textItem.formatter = NumericFormatter()

        textItem.validationFailureMessage = localizedString(.achAccountLocationFieldInvalid, configuration.localizationParameters)

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
        if let prefillCountryCode = configuration.shopperInformation?.billingAddress?.country,
           configuration.billingAddressCountryCodes.contains(prefillCountryCode) {
            initialCountry = prefillCountryCode
        }
        let item = FormAddressItem(initialCountry: initialCountry,
                                   style: configuration.style.addressStyle,
                                   localizationParameters: configuration.localizationParameters,
                                   identifier: identifier,
                                   supportedCountryCodes: configuration.billingAddressCountryCodes)
        configuration.shopperInformation?.billingAddress.map { item.value = $0 }
        item.style.backgroundColor = UIColor.Adyen.lightGray
        return item
    }()
    
    internal lazy var payButton: FormButtonItem = {
        let item = FormButtonItem(style: configuration.style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                      postfix: ViewIdentifier.payButtonItem)
        item.title = localizedString(.confirmPurchase, configuration.localizationParameters)
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        return item
    }()
    
    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: configuration.style)
        formViewController.localizationParameters = configuration.localizationParameters
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
    public struct Configuration: AnyPersonalInformationConfiguration {

        /// Describes the component's UI style.
        public var style: FormComponentStyle

        /// The shopper's information to be prefilled.
        public var shopperInformation: PrefilledShopperInformation?
        
        /// :nodoc:
        public var localizationParameters: LocalizationParameters?
        
        /// Determines whether the billing address should be displayed or not.
        /// Defaults to `true`.
        public var showsBillingAddress: Bool
        
        /// List of ISO country codes that is supported for the billing address.
        /// Defaults to ["US", "PR"].
        public var billingAddressCountryCodes: [String]
        
        /// Initializes the configuration for ACH Direct Debit Component.
        /// - Parameters:
        ///   - style: The UI style of the component.
        ///   - shopperInformation: The shopper's information to be prefilled.
        ///   - localizationParameters: Localization parameters.
        ///   - showsBillingAddress: Determines whether the billing address should be displayed or not.
        ///   Defaults to `true`.
        ///   - billingAddressCountryCodes: ISO country codes that is supported for the billing address.
        ///   Defaults to ["US", "PR"].
        public init(style: FormComponentStyle = FormComponentStyle(),
                    shopperInformation: PrefilledShopperInformation? = nil,
                    localizationParameters: LocalizationParameters? = nil,
                    showsBillingAddress: Bool = true,
                    billingAddressCountryCodes: [String] = ["US", "PR"]) {
            self.style = style
            self.shopperInformation = shopperInformation
            self.localizationParameters = localizationParameters
            self.showsBillingAddress = showsBillingAddress
            self.billingAddressCountryCodes = billingAddressCountryCodes
        }
    }
}
