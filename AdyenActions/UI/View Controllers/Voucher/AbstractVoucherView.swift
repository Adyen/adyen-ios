//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal class AbstractVoucherView: UIView, Localizable {

    internal struct Model {

        internal let separatorModel: VoucherSeparatorView.Model

        internal let mainButtonStyle: ButtonStyle
    }

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

    private lazy var voucherView: VoucherCardView = {
        let topView = createTopView()
        let bottomView = createBottomView()

        return VoucherCardView(model: model.separatorModel,
                               topView: topView,
                               bottomView: bottomView)
    }()

    private lazy var saveButton: UIButton = {
        let saveButton = UIButton()
        let titleStyle = model.mainButtonStyle.title
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = titleStyle.font
        saveButton.setTitleColor(titleStyle.color, for: .normal)
        saveButton.imageEdgeInsets = UIEdgeInsets(top: 8, left: -2, bottom: 8, right: 8)
        saveButton.titleEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: -2)
        saveButton.setImage(UIImage(named: "share",
                                    in: Bundle.actionsInternalResources,
                                    compatibleWith: nil), for: .normal)
        saveButton.layer.borderWidth = model.mainButtonStyle.borderWidth
        saveButton.layer.borderColor = model.mainButtonStyle.borderColor?.cgColor
        saveButton.layer.backgroundColor = model.mainButtonStyle.backgroundColor.cgColor
        saveButton.adyen.round(using: model.mainButtonStyle.cornerRounding)
        saveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        saveButton.addTarget(self, action: #selector(shareVoucher), for: .touchUpInside)
        saveButton.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: "adyen.voucher", postfix: "saveButton")

        return saveButton
    }()

    private let model: Model

    internal init(model: Model) {
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

    override internal func layoutSubviews() {
        super.layoutSubviews()
        saveButton.adyen.round(using: model.mainButtonStyle.cornerRounding)
    }

    private func addVoucherView() {
        voucherView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(voucherView)

        voucherView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        voucherView.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        voucherView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
    }

    private func addShareButton() {
        addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 18).isActive = true
        saveButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -18).isActive = true
        saveButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60).isActive = true
        saveButton.topAnchor.constraint(equalTo: voucherView.bottomAnchor, constant: 30).isActive = true
    }

    @objc private func shareVoucher() {
        guard let image = voucherView.adyen.snapShot() else { return }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = voucherView
        fakeViewController.present(activityViewController, animated: true, completion: nil)
    }

}
