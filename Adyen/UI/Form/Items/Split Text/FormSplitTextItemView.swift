//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A view representing a split text item.
internal final class FormSplitTextItemView: FormItemView<FormSplitTextItem> {
    
    /// Initializes the split text item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormSplitTextItem) {
        super.init(item: item)
        
        addSubview(leftItemView)
        addSubview(rightItemView)
        
        configureConstraints()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override var childItemViews: [AnyFormItemView] {
        return [leftItemView, rightItemView]
    }
    
    // MARK: - Text Items
    
    private lazy var leftItemView: FormTextItemView = {
        let leftItemView = FormTextItemView(item: item.leftItem)
        leftItemView.preservesSuperviewLayoutMargins = true
        leftItemView.translatesAutoresizingMaskIntoConstraints = false
        
        return leftItemView
    }()
    
    private lazy var rightItemView: FormTextItemView = {
        let rightItemView = FormTextItemView(item: item.rightItem)
        rightItemView.layoutMargins.left = 0.0 // Remove the default, as the spacing is done with constraints.
        rightItemView.preservesSuperviewLayoutMargins = true
        rightItemView.translatesAutoresizingMaskIntoConstraints = false
        
        return rightItemView
    }()
    
    // MARK: - Layout
    
    private func configureConstraints() {
        let constraints = [
            leftItemView.topAnchor.constraint(equalTo: topAnchor),
            leftItemView.leadingAnchor.constraint(equalTo: leadingAnchor),
            leftItemView.trailingAnchor.constraint(equalTo: centerXAnchor, constant: -8.0),
            leftItemView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            rightItemView.topAnchor.constraint(equalTo: topAnchor),
            rightItemView.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 8.0),
            rightItemView.trailingAnchor.constraint(equalTo: trailingAnchor),
            rightItemView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
