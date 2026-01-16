//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenUI

internal protocol PreselectedPaymentMethodViewModelProtocol {
    var paymentMethodView: UIViewController { get }
    func cancel()
}

internal class PreselectedPaymentMethodViewModel: PreselectedPaymentMethodViewModelProtocol, PreselectedPaymentMethodComponentDelegate {

    // MARK: - Properties

    internal weak var router: PreselectedPaymentMethodRouting?
    private let component: PaymentComponent
    
    internal var paymentMethod: PaymentMethod { component.paymentMethod }
    internal var apiContext: APIContext { component.context.apiContext }
    internal var context: AdyenContext { component.context }
    
    internal let style: FormComponentStyle
    internal let listItemStyle: ListItemStyle
    internal var localizationParameters: LocalizationParameters?
    internal let title: String
    
    private let preselectedPaymentMethodComponent: PreselectedPaymentMethodComponent
    private var dropInFlowManager: DropInFlowManaging

    // MARK: - Initializers

    internal init(
        component: PaymentComponent,
        title: String,
        configuration: DropInComponent.Configuration,
        dropInFlowManager: DropInFlowManaging
    ) {
        self.component = component
        self.dropInFlowManager = dropInFlowManager
        self.style = configuration.style.formComponent
        self.listItemStyle = configuration.style.listComponent.listItem
        self.localizationParameters = configuration.localizationParameters
        self.title = title
        self.preselectedPaymentMethodComponent = PreselectedPaymentMethodComponent(
            component: component,
            title: title,
            style: self.style,
            listItemStyle: self.listItemStyle
        )
        // TODO: - Localization parameters need to be moved to configuration level.
        self.preselectedPaymentMethodComponent.localizationParameters = configuration.localizationParameters
        self.preselectedPaymentMethodComponent.delegate = self
    }

    // MARK: - PreselectedPaymentMethodViewModelProtocol

    internal var paymentMethodView: UIViewController {
        preselectedPaymentMethodComponent.viewController
    }

    internal func cancel() {
        dropInFlowManager.cancel(component: component)

        stopLoading()
        router?.dismiss(completion: nil)
    }

    // MARK: - PreselectedPaymentMethodComponentDelegate

    internal func didRequestAllPaymentMethods() {
        router?.presentPaymentMethodList()
    }

    internal func didProceed(with component: any PaymentComponent) {
        startPaymentFlow(for: component)
    }

    // MARK: - Form Item Factories

    internal func makeListItem() -> ListItem {
        let displayInformation = paymentMethod.displayInformation(using: localizationParameters)
        let imageURL = LogoURLProvider.logoURL(
            withName: displayInformation.logoName,
            environment: context.apiContext.environment
        )
        return ListItem(
            title: displayInformation.title,
            subtitle: displayInformation.subtitle,
            icon: .init(url: imageURL),
            style: listItemStyle,
            identifier: ViewIdentifierBuilder.build(scopeInstance: "preselectedPaymentMethod", postfix: "defaultComponent"),
            accessibilityLabel: displayInformation.accessibilityLabel
        )
    }

    internal func makeSubmitButtonItem() -> FormButtonItem {
        let item = FormButtonItem(style: style.mainButtonItem)
        item.title = localizedSubmitButtonTitle(
            with: context.payment?.amount,
            style: .immediate,
            localizationParameters
        )
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: "preselectedPaymentMethod", postfix: "submitButton")
        item.buttonSelectionHandler = { [weak self] in
            guard let self else { return }
            self.didProceed(with: self.component)
        }
        return item
    }

    internal func makeOpenAllButtonItem() -> FormButtonItem {
        let item = FormButtonItem(style: style.secondaryButtonItem)
        item.title = localizedString(.dropInPreselectedOpenAllTitle, localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: "preselectedPaymentMethod", postfix: "openAllButton")
        item.buttonSelectionHandler = { [weak self] in
            self?.didRequestAllPaymentMethods()
        }
        return item
    }

    internal func makeSeparatorItem() -> FormSeparatorItem {
        let separator = FormSeparatorItem(color: style.separatorColor ?? UIColor.Adyen.componentSeparator)
        separator.identifier = ViewIdentifierBuilder.build(scopeInstance: "preselectedPaymentMethod", postfix: "separator")
        return separator
    }

    internal func makeFootnoteItem() -> FormLabelItem? {
        guard let footnoteText = paymentMethod
            .displayInformation(using: localizationParameters)
            .footnoteText else { return nil }
        let item = FormLabelItem(text: footnoteText, style: style.footnoteLabel)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: "preselectedPaymentMethod", postfix: "footnote")
        return item
    }

    // MARK: - Private

    private func startPaymentFlow(for component: PaymentComponent) {
        startLoading(for: component)
        
        switch component {
        case let component as PresentableComponent:
            router?.present(paymentComponent: component) { [weak self] in
                self?.stopLoading()
            }
        case let component as PaymentInitiable:
            (component as? PaymentComponent)?.delegate = self
            component.initiatePayment()
        default:
            break
        }
    }
    
    private func startLoading(for component: PaymentComponent) {
        preselectedPaymentMethodComponent.startLoading(for: component)
    }
    
    private func stopLoading() {
        preselectedPaymentMethodComponent.stopLoading()
    }
}

// MARK: - PaymentComponentDelegate

extension PreselectedPaymentMethodViewModel: PaymentComponentDelegate {
    
    internal func didSubmit(
        _ data: PaymentComponentData,
        from component: any PaymentComponent
    ) {
        dropInFlowManager.submit(data, from: component, actionPresenter: self)
    }
    
    internal func didFail(
        with error: any Error,
        from component: any PaymentComponent
    ) {
        if case ComponentError.cancelled = error {
            cancel()
        } else {
            dropInFlowManager.fail(with: error, from: component)
        }
    }
}

// MARK: - ActionPresenter

extension PreselectedPaymentMethodViewModel: ActionPresenter {

    internal func present(actionComponent: any PresentableComponent) {
        router?.present(actionComponent: actionComponent) { [weak self] in
            self?.stopLoading()
        }
    }

    internal func didCancel(actionComponent: any ActionComponent) {
        stopLoading()
    }
}
