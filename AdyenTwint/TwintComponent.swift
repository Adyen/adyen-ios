//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import TwintSDK

public final class TwintComponent: PaymentComponent,
    PresentableComponent,
    LoadingComponent {

    private enum ViewIdentifier {
        static let storeDetailsItem = "storeDetailsItem"
        static let submitButtonItem = "submitButtonItem"
    }

    /// Configuration for Twint Component.
    public typealias Configuration = TwintComponentConfiguration

    /// The context object for this component.
    @_spi(AdyenInternal)
    public let context: AdyenContext

    /// The payment method object for this component.
    public let paymentMethod: PaymentMethod

    /// The ready to submit payment data.
    public var paymentData: PaymentComponentData {
        let details = TwintDetails(
            type: paymentMethod,
            subType: "sdk"
        )

        let storePaymentMethod = storeDetailsItem.value
        return PaymentComponentData(
            paymentMethodDetails: details,
            amount: context.payment?.amount,
            order: nil,
            storePaymentMethod: storePaymentMethod
        )
    }

    /// Component's configuration
    public var configuration: Configuration

    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?

    // MARK: - Form items

    private lazy var storeDetailsItem: FormToggleItem = {
        let formToggleItem = FormToggleItem(style: configuration.style.toggle)

        let title = localizedString(.cardStoreDetailsButton, configuration.localizationParameters)
        formToggleItem.title = title

        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: ViewIdentifier.storeDetailsItem)
        formToggleItem.identifier = identifier

        return formToggleItem
    }()

    private lazy var submitButtonItem: FormButtonItem = {
        let item = FormButtonItem(style: configuration.style.mainButtonItem)

        let title = localizedString(.continueTitle, configuration.localizationParameters)
        item.title = title

        let identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: ViewIdentifier.submitButtonItem)
        item.identifier = identifier

        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        return item
    }()

    // MARK: - Properties

    private lazy var formViewController: FormViewController = {
        let style = configuration.style
        let localizationParameters = configuration.localizationParameters
        let formViewController = FormViewController(style: style, localizationParameters: localizationParameters)
        formViewController.delegate = self

        let title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
        formViewController.title = title

        if configuration.showsStorePaymentMethodField {
            formViewController.append(storeDetailsItem)
        }

        formViewController.append(FormSpacerItem(numberOfSpaces: 2))
        formViewController.append(submitButtonItem)

        return formViewController
    }()

    public var requiresModalPresentation: Bool = true

    // MARK: - PresentableComponent

    public lazy var viewController: UIViewController = SecuredViewController(
        child: formViewController,
        style: configuration.style
    )

    // MARK: - Initalizers

    /// Initializes the Twint component.
    ///
    /// - Parameter paymentMethod: The Twint  payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The configuration for the component.
    public init(paymentMethod: TwintPaymentMethod,
                context: AdyenContext,
                configuration: TwintComponentConfiguration = .init()) {
        self.paymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
    }

    /// Generate the payment details and invoke PaymentsComponentDelegate method.
    public func initiatePayment() {
        submit(data: paymentData)
    }

    // MARK: - LoadingComponent

    public func stopLoading() {
        submitButtonItem.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
    }

    // MARK: - Private

    private var shouldStorePaymentMethod: Bool {
        guard configuration.showsStorePaymentMethodField else {
            return configuration.storePaymentMethod
        }

        return storeDetailsItem.value
    }

    private func didSelectSubmitButton() {
        guard formViewController.validate() else { return }

        startLoading()
        initiatePayment()
    }

    private func startLoading() {
        submitButtonItem.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false
    }
}

@_spi(AdyenInternal)
extension TwintComponent: PaymentInitiable {}

@_spi(AdyenInternal)
extension TwintComponent: ViewControllerDelegate {}
