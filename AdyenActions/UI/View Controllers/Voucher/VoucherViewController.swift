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

    internal init(voucherView: UIView) {
        self.voucherView = voucherView
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override internal func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        view.backgroundColor = .clear
    }

    private func buildUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.adyen.anchore(inside: view)

        voucherView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(voucherView)
        voucherView.adyen.anchore(inside: scrollView)
        voucherView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }

    /// :nodoc:
    override internal var preferredContentSize: CGSize {
        get {
            let targetSize = CGSize(width: UIScreen.main.bounds.width,
                                    height: UIView.layoutFittingCompressedSize.height)
            return voucherView.systemLayoutSizeFitting(targetSize,
                                                       withHorizontalFittingPriority: .required,
                                                       verticalFittingPriority: .fittingSizeLevel)
        }

        // swiftlint:disable:next unused_setter_value
        set { assertionFailure("""
        PreferredContentSize is overridden for this view controller.
        getter - returns minimum possible content size.
        setter - no implemented.
        """) }
    }

}
