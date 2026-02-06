//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

/// A UI-focused observable that publishes on every value set, not just when the value changes.
///
/// Unlike `AdyenObservable`, this variant fires the observer callback on every assignment,
/// even if the new value equals the old value. This is useful in UI contexts where setting
/// a value represents an intent to update the UI, regardless of whether the underlying
/// value actually changed.
///
/// Example: Resetting validation state should always update the UI, even if the validation
/// state was already in the "no error" state.
@propertyWrapper
public final class AdyenUIObservable<ValueType: Equatable>: AdyenObservable<ValueType> {

    /// Required for @propertyWrapper - delegates to parent's wrappedValue
    override public var wrappedValue: ValueType {
        didSet {
            publish(wrappedValue)
        }
    }

    override public var projectedValue: AdyenObservable<ValueType> {
        self
    }
}
