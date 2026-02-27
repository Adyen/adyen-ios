//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif
import UIKit

/// A component that provides a form for ACH Direct Debit payment.
package final class ACHDirectDebitComponent: PaymentComponent,
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
    package let context: AdyenContext

    package var paymentMethod: PaymentMethod {
        achDirectDebitPaymentMethod
    }

    package weak var delegate: PaymentComponentDelegate? {
        didSet {
            if let storePaymentMethodAware = delegate as? StorePaymentMethodFieldAware,
               storePaymentMethodAware.isSession {
                configuration.showStorePaymentMethodField = storePaymentMethodAware.showStorePaymentMethodField ?? false
            }
        }
    }
    
    /// Component configuration
    package var configuration: ACHDirectDebitComponentConfiguration

    package lazy var viewController: UIViewController = SecuredViewController(
        child: formViewController,
        style: configuration.style
    )
    
    package let publicKeyProvider: AnyPublicKeyProvider

    package let publicKey: PublicKeyFetchingProgramFlow

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
    package convenience init(
        paymentMethod: ACHDirectDebitPaymentMethod,
        context: AdyenContext,
        publicKey: PublicKeyFetchingProgramFlow,
        configuration: ACHDirectDebitComponentConfiguration = .init()
    ) {
        self.init(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration,
            publicKey: publicKey,
            publicKeyProvider: PublicKeyProvider(apiContext: context.apiContext)
        )
    }
    
    internal init(
        paymentMethod: ACHDirectDebitPaymentMethod,
        context: AdyenContext,
        configuration: ACHDirectDebitComponentConfiguration = .init(),
        publicKey: PublicKeyFetchingProgramFlow,
        publicKeyProvider: AnyPublicKeyProvider
    ) {
        self.configuration = configuration
        self.achDirectDebitPaymentMethod = paymentMethod
        self.context = context
        self.publicKey = publicKey
        self.configuration = configuration
        self.publicKeyProvider = publicKeyProvider
    }
    
    package func stopLoading() {
        payButton.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }
    
    private func startLoading() {
        payButton.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false
    }

    private func didSelectSubmitButton() {
        guard validate() else { return }
        
        startLoading()
        switch publicKey {
        case let .prefetched(publicKey):
            submitEncryptedData(publicKey: publicKey)

        case .notFetched:
            fetchCardPublicKey(notifyingDelegateOnFailure: true) { [weak self] publicKey in
                self?.submitEncryptedData(publicKey: publicKey)
            }
        }
    }
    
    private func submitEncryptedData(publicKey: String) {
        do {
            let encryptedBankAccountNumber = try BankDetailsEncryptor.encrypt(
                accountNumber: bankAccountNumberItem.value,
                with: publicKey
            )
            let encryptedBankRoutingNumber = try BankDetailsEncryptor.encrypt(
                routingNumber: bankRoutingNumberItem.value,
                with: publicKey
            )
            
            let details = ACHDirectDebitDetails(
                paymentMethod: achDirectDebitPaymentMethod,
                holderName: holderNameItem.value,
                encryptedBankAccountNumber: encryptedBankAccountNumber,
                encryptedBankRoutingNumber: encryptedBankRoutingNumber,
                billingAddress: billingAddressItem.value
            )
            
            submit(data: PaymentComponentData(
                paymentMethodDetails: details,
                amount: payment?.amount,
                order: order,
                storePaymentMethod: storePayment
            ))
        } catch {
            delegate?.didFail(with: error, from: self)
        }
    }
    
    private var storePayment: Bool? {
        configuration.showStorePaymentMethodField ? storeDetailsItem.value : nil
    }
    
    // MARK: - Form Items
    
    internal lazy var headerItem: FormLabelItem = {
        let item = FormLabelItem(
            text: localizedString(.achBankAccountTitle, configuration.localizationParameters),
            style: configuration.style.sectionHeader
        )
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.headerItem
        )
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

        textItem.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.holderNameItem
        )
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

        textItem.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.bankAccountNumberItem
        )
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

        textItem.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.bankRoutingNumberItem
        )
        return textItem
    }()
    
    internal lazy var storeDetailsItem: FormToggleItem = {
        let storeDetailsItem = FormToggleItem(style: configuration.style.toggle)
        storeDetailsItem.title = localizedString(.cardStoreDetailsButton, configuration.localizationParameters)
        storeDetailsItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: ViewIdentifier.storeDetailsItem)
        
        return storeDetailsItem
    }()
    
    internal lazy var billingAddressItem: FormAddressPickerItem = {
        let identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.billingAddressItem
        )

        var initialCountry = defaultCountryCode
        
        if
            let prefillCountryCode = configuration.shopperInformation?.billingAddress?.country,
            configuration.billingAddressCountryCodes.contains(prefillCountryCode) {
            initialCountry = prefillCountryCode
        }
        
        let prefillAddress = configuration.shopperInformation?.billingAddress
        
        return FormAddressPickerItem(
            for: .billing,
            initialCountry: initialCountry,
            supportedCountryCodes: configuration.billingAddressCountryCodes,
            prefillAddress: prefillAddress,
            theme: configuration.theme,
            style: configuration.style,
            localizationParameters: configuration.localizationParameters,
            identifier: identifier,
            presenter: self
        )
    }()
    
    internal lazy var payButton: FormButtonItem = {
        let item = FormButtonItem(style: configuration.style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.payButtonItem
        )
        item.title = localizedSubmitButtonTitle(
            with: payment?.amount,
            style: .immediate,
            configuration.localizationParameters
        )
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        return item
    }()

    // MARK: - Private
    
    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(
            scrollEnabled: configuration.showsSubmitButton,
            localizationParameters: configuration.localizationParameters,
            theme: configuration.theme
        )
        formViewController.delegate = self

        formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title

        formViewController.append(FormSpacerItem())
        formViewController.append(headerItem.padding())
        formViewController.append(FormSpacerItem())
        formViewController.append(holderNameItem)
        formViewController.append(bankAccountNumberItem)
        formViewController.append(bankRoutingNumberItem)
        formViewController.append(FormSpacerItem())
        
        if configuration.showBillingAddress {
            formViewController.append(billingAddressItem.withSectionHeader(
                title: localizedString(.billingAddressSectionTitle, configuration.localizationParameters),
                subtitle: nil // TODO: Add subtitle localization key
            ))
        }
        if configuration.showStorePaymentMethodField {
            formViewController.append(storeDetailsItem)
        }
        
        if configuration.showsSubmitButton {
            formViewController.append(FormSpacerItem(numberOfSpaces: 2))
            formViewController.append(payButton)
        }

        return formViewController
    }()
}

extension ACHDirectDebitComponent: TrackableComponent {}

extension ACHDirectDebitComponent: ViewControllerDelegate {

    package func viewDidLoad(viewController: UIViewController) {
        sendInitialAnalytics()
        sendDidLoadEvent()
        switch publicKey {
        case .prefetched:
            break
        case .notFetched:
            // just cache the public key value
            fetchCardPublicKey(notifyingDelegateOnFailure: false)
        }
    }
}

extension ACHDirectDebitComponent: ViewControllerPresenter {
    
    package func presentViewController(_ viewController: UIViewController, animated: Bool) {
        self.viewController.presentViewController(viewController, animated: animated)
    }
    
    package func dismissViewController(animated: Bool) {
        self.viewController.dismissViewController(animated: animated)
    }
}

extension ACHDirectDebitComponent: PublicKeyConsumer {}

// MARK: - SubmitCustomizable

extension ACHDirectDebitComponent: SubmittableComponent {

    package func submit() {
        didSelectSubmitButton()
    }

    package func validate() -> Bool {
        formViewController.validate()
    }
}
