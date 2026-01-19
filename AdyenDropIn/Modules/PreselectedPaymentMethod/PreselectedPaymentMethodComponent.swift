//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import Foundation
import UIKit

/// Defines the methods a delegate of the preselected payment method component should implement.
internal protocol PreselectedPaymentMethodComponentDelegate: AnyObject {
    
    /// Invoked when user decided to change payment method.
    func didRequestAllPaymentMethods()
    
    /// Invoked when user decided to proceed with stored payment method.
    func didProceed(with component: PaymentComponent)
}

/// A component that presents a single preselected payment method and option to open more payment methods.
internal final class PreselectedPaymentMethodComponent: ComponentLoader,
    PresentableComponent,
    PaymentMethodAware,
    Localizable,
    Cancellable {
    
    private let title: String
    private let defaultComponent: PaymentComponent
    
    internal var apiContext: APIContext { defaultComponent.context.apiContext }

    internal var context: AdyenContext { defaultComponent.context }

    internal var paymentMethod: PaymentMethod { defaultComponent.paymentMethod }
    
    /// Delegate actions.
    internal weak var delegate: PreselectedPaymentMethodComponentDelegate?
    
    /// Describes the component's UI style.
    internal var style: FormComponentStyle
    
    /// Describes the list item's UI style.
    internal let listItemStyle: ListItemStyle

    /// Call back when the list is dismissed.
    internal var onCancel: (() -> Void)?
    
    /// Callback for when the component is loaded on display.
    internal var onDidLoad: (() -> Void)?
    
    /// Initializes the pre selected payment component.
    /// - Parameter component: The pre-selected component.
    /// - Parameter title: The title.
    /// - Parameter style: The component's UI style.
    /// - Parameter listItemStyle: The list item UI style.
    internal init(
        component: PaymentComponent,
        title: String,
        style: FormComponentStyle,
        listItemStyle: ListItemStyle
    ) {
        self.title = title
        self.style = style
        self.listItemStyle = listItemStyle
        self.defaultComponent = component
    }

    // MARK: - Cancellable

    internal func didCancel() {
        onCancel?()
    }
    
    // MARK: - View Controller
    
    public lazy var viewController: UIViewController = {
        let formViewController = FormViewController(
            scrollEnabled: true,
            style: style,
            localizationParameters: localizationParameters
        )
        formViewController.delegate = self
        
        formViewController.append(cardImageItem)
        formViewController.append(titleItem)
        formViewController.append(subtitleItem)
        formViewController.append(FormSpacerItem())
        formViewController.append(submitButtonItem)
        formViewController.append(openAllButtonItem)
        formViewController.append(FormSpacerItem(numberOfSpaces: 2))
        
        formViewController.title = title
        return formViewController
    }()
    
    private lazy var cardImageItem: FormCardImageItem = {
        let paymentMethod = defaultComponent.paymentMethod
        let displayInformation = paymentMethod.displayInformation(using: localizationParameters)
        let imageURL = LogoURLProvider.logoURL(
            withName: displayInformation.logoName,
            environment: context.apiContext.environment,
            size: .large
        )
        let item = FormCardImageItem(
            imageURL: imageURL,
            size: CGSize(width: 150, height: 94),
            cornerRadius: 5
        )
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "cardImage")
        return item
    }()
    
    private lazy var titleItem: FormLabelItem = {
        let paymentMethod = defaultComponent.paymentMethod
        let displayInformation = paymentMethod.displayInformation(using: localizationParameters)
        let item = FormLabelItem(
            text: displayInformation.title,
            identifier: ViewIdentifierBuilder.build(scopeInstance: self, postfix: "title"),
            labelStyle: AdyenLabelStyles.default.title.textAlignment(.center)
        )
        return item
    }()
    
    private lazy var subtitleItem: FormLabelItem = {
        let paymentMethod = defaultComponent.paymentMethod
        let displayInformation = paymentMethod.displayInformation(using: localizationParameters)
        let amount = defaultComponent.context.payment?.amount
        let formattedAmount = amount.map { AmountFormatter.formatted(amount: $0.value, currencyCode: $0.currencyCode) } ?? ""

        // TODO: Need to construct this from Localization variable substitution
        let subtitleText = "Use your \(displayInformation.title) to pay \(formattedAmount)"

        let item = FormLabelItem(
            text: subtitleText,
            identifier: ViewIdentifierBuilder.build(scopeInstance: self, postfix: "subtitle"),
            labelStyle: AdyenLabelStyles.default.subtitle.textAlignment(.center)
        )

        return item
    }()
    
    private lazy var submitButtonItem: FormButtonItem = {
        let component = self.defaultComponent
        let item = FormButtonItem(style: style.mainButtonItem)
        item.title = localizedSubmitButtonTitle(
            with: component.context.payment?.amount,
            style: .immediate,
            localizationParameters
        )
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "submitButton")

        item.buttonSelectionHandler = { [weak self] in
            self?.delegate?.didProceed(with: component)
        }
        return item
    }()
    
    private lazy var openAllButtonItem: FormButtonItem = {
        let item = FormButtonItem(style: style.secondaryButtonItem)
        item.title = localizedString(.dropInPreselectedOpenAllTitle, localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "openAllButton")
        item.buttonSelectionHandler = { [weak self] in
            self?.delegate?.didRequestAllPaymentMethods()
        }
        return item
    }()

    private lazy var footnoteItem: FormLabelItem? = {
        guard let footnoteText = paymentMethod
            .displayInformation(using: localizationParameters)
            .footnoteText else { return nil }
        let item = FormLabelItem(text: footnoteText, style: style.footnoteLabel)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "footnote")
        return item
    }()
    
    public func startLoading(for component: PaymentComponent) {
        guard component === defaultComponent else { return }
        submitButtonItem.showsActivityIndicator = true
        openAllButtonItem.enabled = false
    }
    
    internal func stopLoading() {
        submitButtonItem.showsActivityIndicator = false
        openAllButtonItem.enabled = true
    }
    
    // MARK: - Localization
    
    public var localizationParameters: LocalizationParameters?
    
}

extension PreselectedPaymentMethodComponent: ViewControllerDelegate {
    func viewDidLoad(viewController: UIViewController) {
        onDidLoad?()
    }
}

@_spi(AdyenInternal)
extension PreselectedPaymentMethodComponent: TrackableComponent {}
