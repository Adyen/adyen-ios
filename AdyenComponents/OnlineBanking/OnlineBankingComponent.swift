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
                                           ComponentLoader,
                                           PaymentAware {

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

    private var selectedIssuer: Issuer

    // MARK: - Items

    private var tAndcLink: String {
        return paymentMethod.type == .onlineBankingCZ ? "https://static.payu.com/sites/terms/files/payu_privacy_policy_cs.pdf" : "https://static.payu.com/sites/terms/files/payu_privacy_policy_sk.pdf"
    }

    /// The terms and condition message item.
    // swiftlint:disable line_length
    internal lazy var tAndcLabelItem: FormAttributedLabelItem = .init(tAndCText: "By clicking continue you agree with the #terms and conditions#",
                                                                      link: tAndcLink,
                                                                      style: configuration.style.footnoteLabel,
                                                                      identifier: ViewIdentifierBuilder.build(scopeInstance: "AdyenDropIn.OnlineBankingComponent", postfix: "OnlineBankingTAndCLabel"))

    /// The continue button item.
    internal lazy var continueButton: FormButtonItem = {
        let item = FormButtonItem(style: configuration.style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: "AdyenDropIn.OnlineBankingComponent", postfix: "continueButtonItem")
        item.title = localizedString(.continueTitle, configuration.localizationParameters)
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectContinueButton()
        }
        return item
    }()

    /// The Issuer List item.
    internal lazy var issuerListItem: FormIssuersPickerItem = {
        let defaultIssuer = onlineBankingPaymentMethod.issuers[0]

        let issuerListPickerItem: [IssuerPickerItem] = onlineBankingPaymentMethod.issuers.map({
            return IssuerPickerItem(identifier: $0.identifier, element: $0)
        })
        let issuerPickerItem = FormIssuersPickerItem(preselectedValue: issuerListPickerItem[0],
                                        selectableValues: issuerListPickerItem,
                                        style: configuration.style.textField)
        issuerPickerItem.title = localizedString(.selectFieldTitle, configuration.localizationParameters)
        issuerPickerItem.identifier = ViewIdentifierBuilder.build(scopeInstance: "AdyenDropIn.OnlineBankingComponent", postfix: "issuersList")
        _ = issuerPickerItem.publisher.addEventHandler({ issuerPickerITem in
            self.selectedIssuer = issuerPickerITem.element
        })
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
        self.selectedIssuer = onlineBankingPaymentMethod.issuers[0]
    }

    public func stopLoading() {
        continueButton.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }

    public func startLoading(for component: PaymentComponent) {
        continueButton.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false
    }

    // MARK: - Private

    private func didSelectContinueButton() {
        guard formViewController.validate() else { return }

        let details = OnlineBankingDetails(paymentMethod: paymentMethod,
                                           issuer: selectedIssuer.identifier)
        continueButton.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false

        submit(data: PaymentComponentData(paymentMethodDetails: details, amount: payment?.amount, order: order))
    }

    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(style: configuration.style)
        formViewController.localizationParameters = configuration.localizationParameters
        formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
        formViewController.append(FormSpacerItem(numberOfSpaces: 2))
        formViewController.append(issuerListItem)
        formViewController.append(FormSpacerItem(numberOfSpaces: 4))
        formViewController.append(continueButton)
        formViewController.append(FormSpacerItem())
        formViewController.append(tAndcLabelItem.addingDefaultMargins())
        formViewController.append(FormSpacerItem(numberOfSpaces: 2))

        return formViewController
    }()

}

@_spi(AdyenInternal)
extension OnlineBankingComponent: AdyenObserver {}
