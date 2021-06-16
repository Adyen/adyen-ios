//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import PassKit
import UIKit

internal protocol VoucherViewDelegate: AnyObject {

    func didComplete(presentingViewController: UIViewController)

    func saveAsImage(voucherView: UIView, presentingViewController: UIViewController)
    
    func download(url: URL, voucherView: UIView, presentingViewController: UIViewController)

    func addToAppleWallet(passToken: String, presentingViewController: UIViewController, completion: ((Bool) -> Void)?)
}

internal class AbstractVoucherView: UIView, Localizable {

    internal weak var delegate: VoucherViewDelegate?

    internal struct Model {
        
        internal enum ShareButton {
            
            case saveImage
            
            case download(URL)
            
        }

        internal let separatorModel: VoucherSeparatorView.Model
        
        internal let shareButton: ShareButton

        internal let shareButtonTitle: String

        internal let doneButtonTitle: String

        internal let passToken: String?

        internal let style: Style

        internal struct Style {

            internal let mainButtonStyle: ButtonStyle

            internal let secondaryButtonStyle: ButtonStyle

            internal let backgroundColor: UIColor
        }
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

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 20
        stackView.preservesSuperviewLayoutMargins = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var buttons: [UIView] = {
        var buttons = [UIView]()
        if let passToken = model.passToken {
            buttons.append(appleWalletButton)
        }
        buttons.append(saveButton)
        buttons.append(doneButton)
        return buttons
    }()

    private lazy var appleWalletButton: PKAddPassButton = {
        let button = PKAddPassButton(addPassButtonStyle: .black)
        button.addTarget(self, action: #selector(self.appleWalletButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: "adyen.voucher", postfix: "appleWalletButton")
        
        return button
    }()

    private lazy var saveButton: UIButton = {
        let accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: "adyen.voucher", postfix: "saveButton")

        return createButton(with: model.style.mainButtonStyle,
                            title: model.shareButtonTitle,
                            action: #selector(shareVoucher),
                            accessibilityIdentifier: accessibilityIdentifier)
    }()

    private lazy var doneButton: UIButton = {
        let accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: "adyen.voucher", postfix: "doneButton")

        return createButton(with: model.style.secondaryButtonStyle,
                            title: model.doneButtonTitle,
                            action: #selector(done),
                            accessibilityIdentifier: accessibilityIdentifier)
    }()

    private func createButton(with style: ButtonStyle,
                              title: String,
                              image: UIImage? = nil,
                              action: Selector,
                              accessibilityIdentifier: String) -> UIButton {
        let button = UIButton(style: style)
        button.setTitle(title, for: .normal)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        button.accessibilityIdentifier = accessibilityIdentifier

        return button
    }

    private let model: Model
    
    private lazy var containerView = UIView()
    
    private lazy var loadingView = LoadingView(contentView: containerView)

    internal init(model: Model) {
        self.model = model
        super.init(frame: .zero)
        buildUI()
        backgroundColor = model.style.backgroundColor
    }

    private func buildUI() {
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loadingView)
        loadingView.adyen.anchor(inside: self)
        addVoucherView()
        addButtonsStackView()
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

    override internal func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        updateLayout()
    }

    override internal func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }

    private func updateLayout() {
        saveButton.adyen.round(using: model.style.mainButtonStyle.cornerRounding)
        doneButton.adyen.round(using: model.style.secondaryButtonStyle.cornerRounding)
    }

    private func addVoucherView() {
        voucherView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(voucherView)

        voucherView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        voucherView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20).isActive = true
        voucherView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
    }

    private func addButtonsStackView() {
        containerView.addSubview(buttonsStackView)
        buttonsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 18).isActive = true
        buttonsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18).isActive = true
        buttonsStackView.topAnchor.constraint(equalTo: voucherView.bottomAnchor, constant: 30).isActive = true
        buttonsStackView.bottomAnchor.constraint(equalTo: containerView.layoutMarginsGuide.bottomAnchor, constant: -24).isActive = true
    }

    @objc private func shareVoucher() {
        switch model.shareButton {
        case .saveImage:
            delegate?.saveAsImage(voucherView: voucherView, presentingViewController: fakeViewController)
        case let .download(url):
            delegate?.download(url: url, voucherView: voucherView, presentingViewController: fakeViewController)
        }
    }

    @objc private func appleWalletButtonPressed() {
        guard let passToken = model.passToken else { return }
        loadingView.showsActivityIndicator = true
        delegate?.addToAppleWallet(passToken: passToken, presentingViewController: fakeViewController) { [weak self] _ in
            self?.loadingView.showsActivityIndicator = false
        }
    }

    @objc private func done() {
        delegate?.didComplete(presentingViewController: fakeViewController)
    }

}
