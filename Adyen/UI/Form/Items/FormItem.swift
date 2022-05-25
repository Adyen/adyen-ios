//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public protocol Hidable {

    var isHidden: AdyenObservable<Bool> { get }
}

/// An item in a form.
@_spi(AdyenInternal)
public protocol FormItem: AnyObject {
    
    /// An identifier for the `FormItem`,
    /// that  is set to the `FormItemView.accessibilityIdentifier` when the corresponding `FormItemView` is created.
    var identifier: String? { get set }

    /// The list of sub-items.
    var subitems: [FormItem] { get }
    
    /// Builds the corresponding `AnyFormItemView`.
    func build(with builder: FormItemViewBuilder) -> AnyFormItemView
}

@_spi(AdyenInternal)
public extension FormItem {
    
    /// The flat list of all sub-items.
    var flatSubitems: [FormItem] {
        [self] + subitems.flatMap(\.flatSubitems)
    }
    
}

/// A validatable form item.
@_spi(AdyenInternal)
public protocol ValidatableFormItem: FormItem {
    
    /// A message that is displayed when validation fails.
    var validationFailureMessage: String? { get set }
    
    /// Returns a boolean value indicating if the item value is valid.
    ///
    /// - Returns: A boolean value indicating if the given value is valid.
    func isValid() -> Bool
    
}

/// A form item that requires keyboard input or otherwise custom input view.
@_spi(AdyenInternal)
public protocol InputViewRequiringFormItem: FormItem {}

/// Delegate to the view all events that requires change in corespondent FormView changes.
internal protocol SelfRenderingFormItemDelegate: AnyObject {

    /// Notify delegate that items have changed.
    func didUpdateItems(_ items: [FormItem])

}

internal protocol CompoundFormItem {
    var delegate: SelfRenderingFormItemDelegate? { get set }
}

@_spi(AdyenInternal)
extension Hidable {

    public var isVisible: Bool {
        get {
            !self.isHidden.wrappedValue
        }

        set {
            self.isHidden.wrappedValue = !newValue
        }
    }

}
