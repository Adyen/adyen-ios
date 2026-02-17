//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import Foundation
import UIKit

/// A component that presents a single preselected payment method and option to open more payment methods.
internal final class PreselectedPaymentMethodComponent:
    PresentableComponent,
    PaymentMethodAware,
    Localizable,
    Cancellable {
    public lazy var presentationConfiguration: ComponentPresentationConfiguration = .init(preselectedPaymentMethod: .push, paymentMethodList: .push, presentableComponent: self)

    private let title: String
    private let defaultComponent: PaymentComponent

    internal var context: AdyenContext {
        defaultComponent.context
    }

    internal var paymentMethod: PaymentMethod {
        defaultComponent.paymentMethod
    }

    /// Describes the component's UI style.
    internal var style: FormComponentStyle

    /// Call back when the list is dismissed.
    internal var onCancel: (() -> Void)?

    /// Initializes the pre selected payment component.
    /// - Parameter component: The pre-selected component.
    /// - Parameter title: The title.
    /// - Parameter style: The component's UI style.
    /// - Parameter listItemStyle: The list item UI style.
    internal init(
        component: PaymentComponent,
        style: FormComponentStyle,
        title: String
    ) {
        self.title = title
        self.style = style
        self.defaultComponent = component
    }

    // MARK: - Cancellable

    // TODO: Robert: figure out who needs didCancel.
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
        formViewController.title = title
        return formViewController
    }()

    // MARK: - Localization
    
    public var localizationParameters: LocalizationParameters?
    
}

// TODO: Robert: Need to investigate this.
@_spi(AdyenInternal)
extension PreselectedPaymentMethodComponent: TrackableComponent {}
