//
// Copyright (c) 2019 Adyen B.V.
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
        
        configureConstraints()
    }
    
    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var valueDelegate: FormValueItemViewDelegate? {
        return delegate as? FormValueItemViewDelegate
    }
    
    // MARK: - Editing
    
    /// Indicates if the item is currently being edited.
    public var isEditing = false {
        didSet {
            if let parentItemView = parentItemView as? AnyFormValueItemView {
                parentItemView.isEditing = isEditing
            } else if showsSeparator, isEditing != oldValue {
                isEditing ? highlightSeparatorView() : unhighlightSeparatorView()
            }
        }
    }
    
    // MARK: - Separator View
    
    /// Indicates if the separator should be shown.
    public var showsSeparator = true {
        didSet {
            separatorView.isHidden = !showsSeparator
        }
    }
    
    private lazy var separatorView: UIView = {
        let separatorView = UIView()
        separatorView.backgroundColor = separatorColor
        separatorView.isUserInteractionEnabled = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        return separatorView
    }()
    
    private let separatorColor = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.9176470588, alpha: 1)
    
    private func highlightSeparatorView() {
        let transitionView = UIView()
        transitionView.backgroundColor = tintColor
        transitionView.frame = separatorView.frame
        transitionView.frame.size.width = 0.0
        addSubview(transitionView)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseInOut], animations: {
            transitionView.frame = self.separatorView.frame
        }, completion: { _ in
            self.separatorView.backgroundColor = self.tintColor
            
            transitionView.removeFromSuperview()
        })
    }
    
    private func unhighlightSeparatorView() {
        let transitionView = UIView()
        transitionView.backgroundColor = tintColor
        transitionView.frame = separatorView.frame
        addSubview(transitionView)
        
        separatorView.backgroundColor = separatorColor
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.curveEaseInOut], animations: {
            transitionView.frame.size.width = 0.0
        }, completion: { _ in
            transitionView.removeFromSuperview()
        })
    }
    
    // MARK: - Layout
    
    private func configureConstraints() {
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
    
}
