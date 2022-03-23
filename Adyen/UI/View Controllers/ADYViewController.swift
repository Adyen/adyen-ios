//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// :nodoc:
/// `ADYViewController` serves as a height-aware `UIViewController`
public final class ADYViewController: UIViewController {
    
    private lazy var scrollView = UIScrollView()
    
    /// :nodoc:
    private let contentView: UIView
    
    /// Initializes the `ADYViewController` instance with given view and an optional title
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
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }
    
    private func buildUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.adyen.anchor(inside: view.safeAreaLayoutGuide)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.adyen.anchor(inside: scrollView)
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    override public var preferredContentSize: CGSize {
        get {
            contentView.adyen.minimalSize
        }

        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assertionFailure(message: """
        PreferredContentSize is overridden for this view controller.
        getter - returns minimum possible content size.
        setter - no implemented.
        """) }
    }
}
