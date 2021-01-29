//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import PassKit
import UIKit

internal final class VoucherViewController: UIViewController {

    private let action: DokuIndomaretVoucherAction

    private lazy var scrollView = UIScrollView()

    private lazy var containerView: UIView = {
        DokuIndomaretVoucherView(model: model) { [weak self] in
            guard let image = $0.adyen.snapShot() else { return }
            let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = $0
            self?.present(activityViewController, animated: true, completion: nil)
        }
    }()

    private lazy var model = {
        DokuIndomaretVoucherView.Model(title: "Amount",
                                       subtitle: "IDR 700.000,00",
                                       code: "ADY551915",
                                       expirationTitle: "Expiration",
                                       expirationValue: "17/04/2020",
                                       emailTitle: "E-mail",
                                       emailValue: "joel.vanbodegraven@adyen.com",
                                       voucherSeparator: .init(separatorTitle: "Payment code"))
    }()

    internal init(action: DokuIndomaretVoucherAction) {
        self.action = action
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override internal func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }

    private func buildUI() {
        var guid = view.layoutMarginsGuide
        if #available(iOS 11, *) {
            guid = view.safeAreaLayoutGuide
        }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.adyen.anchore(inside: guid)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(containerView)
        containerView.adyen.anchore(inside: scrollView)
        containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }

    /// :nodoc:
    override internal var preferredContentSize: CGSize {
        get {
            let targetSize = CGSize(width: UIScreen.main.bounds.width,
                                    height: UIView.layoutFittingCompressedSize.height)
            return containerView.systemLayoutSizeFitting(targetSize,
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
