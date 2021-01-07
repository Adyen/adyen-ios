//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Displays a form for the user to enter details.
/// :nodoc:
internal final class FormView: UIScrollView {
    
    /// Initializes the form view.
    internal init() {
        super.init(frame: .zero)
        
        preservesSuperviewLayoutMargins = true
        addSubview(stackView)
        
        configureConstraints()
    }
    
    /// :nodoc:
    @available(*, unavailable)
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override internal var intrinsicContentSize: CGSize {
        let targetSize = CGSize(width: self.superview?.bounds.width ?? UIScreen.main.bounds.width,
                                height: UIView.layoutFittingCompressedSize.height)
        return stackView.systemLayoutSizeFitting(targetSize,
                                                 withHorizontalFittingPriority: .required,
                                                 verticalFittingPriority: .fittingSizeLevel)
    }
    
    // MARK: - Item Views
    
    /// Appends an item view to the stack of item views.
    ///
    /// - Parameter itemView: The item view to append.
    internal func appendItemView(_ itemView: UIView) {
        stackView.addArrangedSubview(itemView)
    }
    
    override internal var contentOffset: CGPoint {
        get {
            super.contentOffset
        }
        
        set {
            let noNeedToScroll = contentSize.height <= frame.size.height
            super.contentOffset = noNeedToScroll ? .zero : newValue
        }
    }
    
    // MARK: - Stack View
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.preservesSuperviewLayoutMargins = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Layout

    private func configureConstraints() {
        stackView.adyen.anchore(inside: self)
        stackView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
}
