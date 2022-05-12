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
    
    /// Initializes the `ADYViewController` instance with given view and an optional title
    /// - Parameters:
    ///   - view: The instance of UIView to be displayed
    ///   - title: The title of the `ADYViewController`
    public init(view: UIView, title: String? = nil) {
        self.contentView = view
        super.init(nibName: nil, bundle: Bundle(for: ADYViewController.self))
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
            view.adyen.minimalSize
        }

        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assertionFailure(message: """
        PreferredContentSize is overridden for this view controller.
        getter - returns minimum possible content size.
        setter - no implemented.
        """) }
    }
}
