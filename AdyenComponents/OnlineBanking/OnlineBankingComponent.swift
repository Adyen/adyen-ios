//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A component that provides a form for Online Banking payment.
public final class OnlineBankingComponent: PaymentComponent,
    PresentableComponent,
    LoadingComponent,
    PaymentAware {

    private enum ViewIdentifier {
        static let termsAndConditionsLabelItem = "OnlineBankingTermsAndConditionLabel"
        static let continueButtonItem = "continueButton"
        static let issuerListItem = "issuersList"
    }

    private enum TermsAndConditionsURL {
        static let onlineBankingCZ = "https://static.payu.com/sites/terms/files/payu_privacy_policy_cs.pdf"
        static let onlineBankingSK = "https://static.payu.com/sites/terms/files/payu_privacy_policy_sk.pdf"
    }

    /// Configuration for Online Banking Component.
    public typealias Configuration = BasicComponentConfiguration

    /// The context object for this component.
    @_spi(AdyenInternal)
    public var context: AdyenContext

    public var paymentMethod: PaymentMethod { onlineBankingPaymentMethod }

    public weak var delegate: PaymentComponentDelegate?

    public lazy var viewController: UIViewController = SecuredViewController(child: formViewController,
                                                                             style: configuration.style)

    public var requiresModalPresentation: Bool = true

    /// Component's configuration
    public var configuration: Configuration

    private let onlineBankingPaymentMethod: OnlineBankingPaymentMethod

    // MARK: - Items

    private var termsAndConditionsLink: String {
        paymentMethod.type == .onlineBankingCZ ? TermsAndConditionsURL.onlineBankingCZ : TermsAndConditionsURL.onlineBankingSK
    }

    /// The terms and condition message item.
    internal lazy var termsAndConditionsLabelItem: FormAttributedLabelItem = .init(
        originalText:
        localizedString(.onlineBankingTermsAndConditions,
                        configuration.localizationParameters),
        link: termsAndConditionsLink,
        style: configuration.style.footnoteLabel,
        linkTextStyle: configuration.style.linkTextLabel,
        identifier: ViewIdentifierBuilder.build(scopeInstance: self,
                                                postfix: ViewIdentifier.termsAndConditionsLabelItem)
    )

    /// The continue button item.
    internal lazy var continueButton: FormButtonItem = {
        let item = FormButtonItem(style: configuration.style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                      postfix: ViewIdentifier.continueButtonItem)
        item.title = localizedString(.continueTitle, configuration.localizationParameters)
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectContinueButton()
        }
        return item
    }()

    /// The Issuer List item.
    internal lazy var issuerListPickerItem: FormIssuersPickerItem = {
        let issuerListPickerItems: [IssuerPickerItem] = onlineBankingPaymentMethod.issuers.map {
            IssuerPickerItem(identifier: $0.identifier, element: $0)
        }

        AdyenAssertion.assert(message: "Issuer list should not be empty", condition: issuerListPickerItems.count <= 0)

        let issuerPickerItem = FormIssuersPickerItem(preselectedValue: issuerListPickerItems[0],
                                                     selectableValues: issuerListPickerItems,
                                                     style: configuration.style.textField)
        issuerPickerItem.title = localizedString(.selectFieldTitle, configuration.localizationParameters)
        issuerPickerItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                                  postfix: ViewIdentifier.issuerListItem)
        return issuerPickerItem
    }()

    /// Initializes the Online Banking component.
    ///
    /// - Parameter paymentMethod: The Online Banking payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The configuration for the component.
    public init(paymentMethod: OnlineBankingPaymentMethod,
                context: AdyenContext,
                configuration: Configuration = .init()) {
        self.onlineBankingPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
    }

    public func stopLoading() {
        continueButton.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }

    // MARK: - Private

    private func didSelectContinueButton() {
        guard formViewController.validate() else { return }

        let details = OnlineBankingDetails(paymentMethod: paymentMethod,
                                           issuer: issuerListPickerItem.value.identifier)
        continueButton.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false

        submit(data: PaymentComponentData(paymentMethodDetails: details, amount: payment?.amount, order: order))
    }

    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: configuration.style)
        formViewController.localizationParameters = configuration.localizationParameters
        formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
        formViewController.append(FormSpacerItem(numberOfSpaces: 2))
        formViewController.append(issuerListPickerItem)
        formViewController.append(FormSpacerItem(numberOfSpaces: 4))
        formViewController.append(termsAndConditionsLabelItem.addingDefaultMargins())
        formViewController.append(FormSpacerItem())
        formViewController.append(continueButton)
        formViewController.append(FormSpacerItem(numberOfSpaces: 2))

        return formViewController
    }()

}

@_spi(AdyenInternal)
extension OnlineBankingComponent: AdyenObserver {}
