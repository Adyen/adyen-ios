//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// :nodoc:
/// `ADYViewController` serves as a height-aware `UIViewController`
public final class ADYViewController: UIViewController {
    
    /// :nodoc:
    private let contentView: UIView
    
    /// Initializes the `ADYViewController` instance with given view and an optinal title
    /// - Parameters:
    ///   - view: The instance of UIView to be displayed
    ///   - title: The title of the `ADYViewController`
    public init(view: UIView, title: String? = nil) {
        self.contentView = view
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func loadView() {
        self.view = contentView
    }
    
    override public var preferredContentSize: CGSize {
        get {
            let targetSize = CGSize(width: UIScreen.main.bounds.width,
                                    height: UIView.layoutFittingCompressedSize.height)
            return view.systemLayoutSizeFitting(
                targetSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
        }

        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assert(message: """
        PreferredContentSize is overridden for this view controller.
        getter - returns minimum possible content size.
        setter - no implemented.
        """) }
    }
}
