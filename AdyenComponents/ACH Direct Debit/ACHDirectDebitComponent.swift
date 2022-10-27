//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif
import UIKit

/// A component that provides a form for ACH Direct Debit payment.
public final class ACHDirectDebitComponent: PaymentComponent,
    PaymentAware,
    PresentableComponent,
    LoadingComponent {
    
    private enum ViewIdentifier {
        static let headerItem = "headerItem"
        static let holderNameItem = "holderNameItem"
        static let bankAccountNumberItem = "bankAccountNumberItem"
        static let bankRoutingNumberItem = "bankRoutingNumberItem"
        static let billingAddressItem = "billingAddressItem"
        static let storeDetailsItem = "storeDetailsItem"
        static let payButtonItem = "payButtonItem"
    }
    
    /// The context object for this component.
    @_spi(AdyenInternal)
    public let context: AdyenContext
    
    public var paymentMethod: PaymentMethod {
        achDirectDebitPaymentMethod
    }

    public weak var delegate: PaymentComponentDelegate? {
        didSet {
            if let storePaymentMethodAware = delegate as? StorePaymentMethodFieldAware,
               storePaymentMethodAware.isSession {
                configuration.showsStorePaymentMethodField = storePaymentMethodAware.showStorePaymentMethodField ?? false
            }
        }
    }
    
    /// Component configuration
    public var configuration: Configuration

    public lazy var viewController: UIViewController = SecuredViewController(child: formViewController,
                                                                             style: configuration.style)

    public let requiresModalPresentation: Bool = true
    
    @_spi(AdyenInternal)
    public let publicKeyProvider: AnyPublicKeyProvider
    
    private var defaultCountryCode: String {
        payment?.countryCode ?? configuration.billingAddressCountryCodes.first ?? "US"
    }
    
    private let achDirectDebitPaymentMethod: ACHDirectDebitPaymentMethod

    // MARK: - Init
    
    /// Initializes the ACH Direct Debit component.
    /// - Parameters:
    ///   - paymentMethod: The ACH Direct Debit payment method.
    ///   - context: The context object for this component.
    ///   - configuration: Configuration for the component.
    public convenience init(paymentMethod: ACHDirectDebitPaymentMethod,
                            context: AdyenContext,
                            configuration: Configuration = .init()) {
        self.init(paymentMethod: paymentMethod,
                  context: context,
                  configuration: configuration,
                  publicKeyProvider: PublicKeyProvider(apiContext: context.apiContext))
    }
    
    internal init(paymentMethod: ACHDirectDebitPaymentMethod,
                  context: AdyenContext,
                  configuration: Configuration = .init(),
                  publicKeyProvider: AnyPublicKeyProvider) {
        self.configuration = configuration
        self.achDirectDebitPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
        self.publicKeyProvider = publicKeyProvider
    }
    
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
            
            submit(data: PaymentComponentData(paymentMethodDetails: details,
                                              amount: payment?.amount,
                                              order: order,
                                              storePaymentMethod: storePayment))
        } catch {
            delegate?.didFail(with: error, from: self)
        }
    }
    
    private var storePayment: Bool? {
        configuration.showsStorePaymentMethodField ? storeDetailsItem.value : nil
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
    
    internal lazy var storeDetailsItem: FormToggleItem = {
        let storeDetailsItem = FormToggleItem(style: configuration.style.toggle)
        storeDetailsItem.title = localizedString(.cardStoreDetailsButton, configuration.localizationParameters)
        storeDetailsItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: ViewIdentifier.storeDetailsItem)
        
        return storeDetailsItem
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
                                   supportedCountryCodes: configuration.billingAddressCountryCodes,
                                   addressViewModelBuilder: DefaultAddressViewModelBuilder())
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

    // MARK: - Private
    
    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: configuration.style)
        formViewController.localizationParameters = configuration.localizationParameters
        formViewController.delegate = self

        formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title

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
        if configuration.showsStorePaymentMethodField {
            formViewController.append(storeDetailsItem)
        }
        
        formViewController.append(FormSpacerItem(numberOfSpaces: 2))
        formViewController.append(payButton)

        return formViewController
    }()
}

@_spi(AdyenInternal)
extension ACHDirectDebitComponent: TrackableComponent {}

@_spi(AdyenInternal)
extension ACHDirectDebitComponent: ViewControllerDelegate {

    public func viewDidLoad(viewController: UIViewController) {
        Analytics.sendEvent(component: paymentMethod.type.rawValue,
                            flavor: _isDropIn ? .dropin : .components,
                            context: context.apiContext)
        // just cache the public key value
        fetchCardPublicKey(notifyingDelegateOnFailure: false)
    }

    /// :nodoc:
    public func viewWillAppear(viewController: UIViewController) {
        sendTelemetryEvent()
    }
}

extension ACHDirectDebitComponent {
    
    /// Configuration for the ACH Direct Debit Component
    public struct Configuration: AnyPersonalInformationConfiguration {

        /// Describes the component's UI style.
        public var style: FormComponentStyle

        /// The shopper's information to be prefilled.
        public var shopperInformation: PrefilledShopperInformation?
        
        public var localizationParameters: LocalizationParameters?
        
        /// Indicates if the field for storing the card payment method should be displayed in the form. Defaults to `true`.
        public var showsStorePaymentMethodField: Bool
        
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
                    showsStorePaymentMethodField: Bool = true,
                    showsBillingAddress: Bool = true,
                    billingAddressCountryCodes: [String] = ["US", "PR"]) {
            self.style = style
            self.shopperInformation = shopperInformation
            self.localizationParameters = localizationParameters
            self.showsStorePaymentMethodField = showsStorePaymentMethodField
            self.showsBillingAddress = showsBillingAddress
            self.billingAddressCountryCodes = billingAddressCountryCodes
        }
    }
}

@_spi(AdyenInternal)
extension ACHDirectDebitComponent: PublicKeyConsumer {}
