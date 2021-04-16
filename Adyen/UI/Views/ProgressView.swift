//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// :nodoc:
public final class ProgressView: UIProgressView {
    
    /// :nodoc:
    private let style: ProgressViewStyle
    
    /// Initializes the progress view
    ///
    /// - Parameter style: The `ProgressView` UI style
    /// - Parameter observedProgress: Optional object to use for updating the progress view
    public init(style: ProgressViewStyle, observedProgress: Progress? = nil) {
        self.style = style
        super.init(frame: .zero)
        
        super.observedProgress = observedProgress
        
        isAccessibilityElement = false
        translatesAutoresizingMaskIntoConstraints = false
        applyStyle()
    }
    
    /// :nodoc:
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// :nodoc:
    private func applyStyle() {
        backgroundColor = style.backgroundColor
        progressTintColor = style.progressTintColor
        trackTintColor = style.trackTintColor
    }
    
}
