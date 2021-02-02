//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal class AbstractVoucherView: UIView, Localizable {

    internal var localizationParameters: LocalizationParameters?

    internal weak var presenter: UIViewController?

    /// Ugly hack to work around the following bug
    /// https://stackoverflow.com/questions/59413850/uiactivityviewcontroller-dismissing-current-view-controller-after-sharing-file
    private lazy var fakeViewController: UIViewController = {
        let viewController = UIViewController()
        presenter?.addChild(viewController)
        presenter?.view.insertSubview(viewController.view, at: 0)
        viewController.view.frame = .zero
        viewController.didMove(toParent: presenter)
        return viewController
    }()

    private lazy var voucherView: BaseVoucherView = {
        let topView = createTopView()
        let bottomView = createBottomView()

        return BaseVoucherView(topView: topView, bottomView: bottomView)
    }()

    private let model: VoucherSeparatorView.Model

    internal init(model: VoucherSeparatorView.Model = VoucherSeparatorView.Model()) {
        self.model = model
        super.init(frame: .zero)
        addVoucherView()
        addShareButton()
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func createTopView() -> UIView {
        fatalError("This is an abstract class that needs to be subclassed.")
    }

    internal func createBottomView() -> UIView {
        fatalError("This is an abstract class that needs to be subclassed.")
    }

    private func addVoucherView() {
        voucherView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(voucherView)

        voucherView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        voucherView.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        voucherView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
    }

    private func addShareButton() {
        let saveButton = UIButton()
        saveButton.setTitle("save", for: .normal)
        saveButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: -2, bottom: 8, right: 8)
        saveButton.titleEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: -2)
        saveButton.setImage(UIImage(named: "share",
                                    in: Bundle.actionsInternalResources,
                                    compatibleWith: nil), for: .normal)

        saveButton.layer.backgroundColor = UIColor(red: 0, green: 0.478, blue: 1, alpha: 1).cgColor
        saveButton.layer.cornerRadius = 8

        addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 18).isActive = true
        saveButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -18).isActive = true
        saveButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60).isActive = true
        saveButton.topAnchor.constraint(equalTo: voucherView.bottomAnchor, constant: 30).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.addTarget(self, action: #selector(shareVoucher), for: .touchUpInside)
    }

    @objc private func shareVoucher() {
        guard let image = voucherView.adyen.snapShot() else { return }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = voucherView
        fakeViewController.present(activityViewController, animated: true, completion: nil)
    }

}
