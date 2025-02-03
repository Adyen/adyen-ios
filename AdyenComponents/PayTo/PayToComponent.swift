//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A component that provides PayTo flows for PayTo component.
public final class PayToComponent: PaymentComponent,
                                   PresentableComponent {

    private enum ViewIdentifier {
        static let flowSelectionTitleLabelItem = "flowSelectionTitleLabelItem"
        static let flowSelectionItem = "flowSelectionSegmentedControlItem"
        static let continueButtonItem = "continueButton"
    }

    /// Configuration for PayTo Component.
    public typealias Configuration = BasicComponentConfiguration

    /// The context object for this component.
    @_spi(AdyenInternal)
    public var context: AdyenContext

    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?

    /// Component's configuration
    public var configuration: Configuration

    /// The payment method object for this component.
    public var paymentMethod: PaymentMethod { payToPaymentMethod }

    private let payToPaymentMethod: PayToPaymentMethod

    /// The viewController for the component.
    public lazy var viewController: UIViewController = SecuredViewController(
        child: formViewController,
        style: configuration.style
    )

    /// This indicates that `viewController` expected to be presented modally,
    public var requiresModalPresentation: Bool = true

    /// Initializes the PayTo  component.
    ///
    /// - Parameter paymentMethod: The PayTo payment method.
    /// - Parameter context: The context object for this component.
    /// - Parameter configuration: The configuration for the component.
    public init(
        paymentMethod: PayToPaymentMethod,
        context: AdyenContext,
        configuration: Configuration = .init()
    ) {
        self.payToPaymentMethod = paymentMethod
        self.context = context
        self.configuration = configuration
    }

    /// The payment flow selection title  label item.
    internal lazy var flowSelectionTitleLabelItem: FormLabelItem = {
        let item = FormLabelItem(
            text: "How would you like to use Payto?",
            style: configuration.style.footnoteLabel
        )
        item.style.textAlignment = .left
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.flowSelectionTitleLabelItem
        )
        return item
    }()

    /// The segment control item to choose the payTo flow.
    internal lazy var flowSelectionItem: FormSegmentedControlItem = {
        let item = FormSegmentedControlItem(
            items: ["PayID", "BSB"],
            style: configuration.style.segmentedControlStyle,
            identifier: ViewIdentifierBuilder.build(
                scopeInstance: self,
                postfix: ViewIdentifier.flowSelectionItem
            )
        )
        return item
    }()

    /// The continue button item.
    internal lazy var continueButton: FormButtonItem = {
        let item = FormButtonItem(style: configuration.style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(
            scopeInstance: self,
            postfix: ViewIdentifier.continueButtonItem
        )
        item.title = localizedString(.continueTitle, configuration.localizationParameters)
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectContinueButton()
        }
        return item
    }()

    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController(
            scrollEnabled: configuration.showsSubmitButton,
            style: configuration.style,
            localizationParameters: configuration.localizationParameters
        )
        formViewController.title = paymentMethod.displayInformation(using: configuration.localizationParameters).title
        formViewController.append(FormSpacerItem(numberOfSpaces: 1))
        formViewController.append(flowSelectionTitleLabelItem.padding())
        formViewController.append(FormSpacerItem(numberOfSpaces: 1))
        formViewController.append(flowSelectionItem.padding())

        if configuration.showsSubmitButton {
            formViewController.append(FormSpacerItem(numberOfSpaces: 2))
            formViewController.append(continueButton)
        }

        return formViewController
    }()
}

// MARK: - Event Handling

extension PayToComponent {

    private func didSelectContinueButton() {
        // TODO: Implement
    }

}
