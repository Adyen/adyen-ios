//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// The interface of the delegate of a value item view.
/// :nodoc:
public protocol FormValueItemViewDelegate: FormItemViewDelegate {
    
    /// Invoked when the value of the item in an item view changed.
    ///
    /// - Parameter itemView: The item view in which the value changed.
    func didChangeValue<T: FormValueItem>(in itemView: FormValueItemView<T>)
    
}

/// A view representing a value item.
/// :nodoc:
open class FormValueItemView<ItemType: FormValueItem>: FormItemView<ItemType>, AnyFormValueItemView {
    
    /// Initializes the value item view.
    ///
    /// - Parameter item: The item represented by the view.
    public required init(item: ItemType) {
        super.init(item: item)
        
        addSubview(separatorView)
        configureSeparatorView()
        
        tintColor = item.style.tintColor
        backgroundColor = item.style.backgroundColor

        gestureRecognizers = [UITapGestureRecognizer(target: self, action: #selector(becomeFirstResponder))]
    }
    
    private var valueDelegate: FormValueItemViewDelegate? {
        delegate as? FormValueItemViewDelegate
    }
    
    /// :nodoc:
    override open func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        bringSubviewToFront(separatorView)
    }
    
    // MARK: - Editing
    
    /// Indicates if the item is currently being edited.
    open var isEditing = false {
        didSet {
            if let parentItemView = parentItemView as? AnyFormValueItemView {
                parentItemView.isEditing = isEditing
            }
            
            if isEditing != oldValue {
                Self.cancelPreviousPerformRequests(withTarget: self)
                perform(#selector(didChangeEditingStatus), with: nil, afterDelay: 0.1)
            }
        }
    }
    
    @objc internal func didChangeEditingStatus() {
        guard showsSeparator else { return }
        isEditing ? highlightSeparatorView(color: tintColor) : unhighlightSeparatorView()
    }
    
    // MARK: - Validation
    
    /// Subclasses can override this method to stay notified
    /// when form value item view should performe UI mutations based on a validation status.
    open func validate() {}
    
    // MARK: - Separator View
    
    /// Indicates if the separator should be shown.
    public var showsSeparator = true {
        didSet {
            separatorView.isHidden = !showsSeparator
        }
    }
    
    internal lazy var separatorView: UIView = {
        let separatorView = UIView()
        separatorView.backgroundColor = item.style.separatorColor ?? UIColor.Adyen.componentSeparator
        separatorView.isUserInteractionEnabled = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        return separatorView
    }()
    
    internal func highlightSeparatorView(color: UIColor) {
        let transitionView = UIView()
        transitionView.backgroundColor = color
        transitionView.frame = separatorView.frame
        transitionView.frame.size.width = 0.0
        addSubview(transitionView)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseInOut], animations: {
            transitionView.frame = self.separatorView.frame
        }, completion: { _ in
            self.separatorView.backgroundColor = color
            transitionView.removeFromSuperview()
        })
    }
    
    internal func unhighlightSeparatorView() {
        let transitionView = UIView()
        transitionView.backgroundColor = tintColor
        transitionView.frame = separatorView.frame
        addSubview(transitionView)
        
        separatorView.backgroundColor = item.style.separatorColor ?? UIColor.Adyen.componentSeparator
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseInOut], animations: {
            transitionView.frame.size.width = 0.0
        }, completion: { _ in
            transitionView.removeFromSuperview()
        })
    }
    
    // MARK: - Layout
    
    /// This method places separatorView at the bottom of a view.
    /// Subclasses can override this method to setup alternative placement for a separatorView.
    /// :nodoc:
    open func configureSeparatorView() {
        let constraints = [
            separatorView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1.0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}

/// A type-erased form value item view.
/// :nodoc:
public protocol AnyFormValueItemView: AnyFormItemView {
    
    /// Indicates if the item is currently being edited.
    var isEditing: Bool { get set }
    
    /// Invoc validation check. Performe all nececery UI transformations based on a validation result.
    func validate()
    
}
