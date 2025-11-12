//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A view representing a value item.
@_spi(AdyenInternal)
open class FormValueItemView<ValueType, Style, ItemType: FormValueItem<ValueType, Style>>:
    FormItemView<ItemType>,
    AnyFormValueItemView {

    // TODO: Pass as a dependency
    private let theme: AdyenTheme = .default

    // MARK: - Title Label

    /// The top label view.
    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.apply(theme.elements.labels.bodyEmphasized)
        titleLabel.text = item.title
        titleLabel.numberOfLines = 0
        titleLabel.isAccessibilityElement = false
        titleLabel.accessibilityIdentifier = item.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "titleLabel") }

        return titleLabel
    }()

    /// Initializes the value item view.
    ///
    /// - Parameter item: The item represented by the view.
    public required init(item: ItemType) {
        super.init(item: item)

        bind(item.$title, to: self.titleLabel, at: \.text)
        
        tintColor = item.style.tintColor
        backgroundColor = item.style.backgroundColor
        gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(becomeFirstResponder))]
    }
    
    override open func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
    }
    
    // MARK: - Editing
    
    /// Indicates if the item is currently being edited.
    open var isEditing = false {
        didSet {
            if let parentItemView = parentItemView as? AnyFormValueItemView {
                parentItemView.isEditing = isEditing
            }
            
            if isEditing != oldValue {
                didChangeEditingStatus()
            }
        }
    }
    
    internal func didChangeEditingStatus() {
        // TODO: Make Following UI in edit mode
        // 1. Change textField border color
        // 2. Show/Hide accessory view
    }

}

/// A type-erased form value item view.
@_spi(AdyenInternal)
public protocol AnyFormValueItemView: AnyFormItemView {
    
    /// Indicates if the item is currently being edited.
    var isEditing: Bool { get set }
}
