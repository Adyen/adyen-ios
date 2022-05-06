//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal final class VoucherViewController: UIViewController {

    private lazy var scrollView = UIScrollView()

    private let voucherView: UIView

    private let style: ViewStyle

    internal init(voucherView: UIView, style: ViewStyle) {
        self.voucherView = voucherView
        self.style = style
        super.init(nibName: nil, bundle: Bundle(for: VoucherViewController.self))
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override internal func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        view.backgroundColor = style.backgroundColor
    }

    private func buildUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.adyen.anchor(inside: view.safeAreaLayoutGuide)

        voucherView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(voucherView)
        voucherView.adyen.anchor(inside: scrollView)
        voucherView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }

    /// :nodoc:
    override internal var preferredContentSize: CGSize {
        get {
            voucherView.adyen.minimalSize
        }

        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assertionFailure(message: """
        PreferredContentSize is overridden for this view controller.
        getter - returns minimum possible content size.
        setter - no implemented.
        """) }
    }

}
