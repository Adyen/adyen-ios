//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import SafariServices
import UIKit

class PaymentConfirmationViewController: CheckoutViewController, SFSafariViewControllerDelegate {
    
    // MARK: - Object Lifecycle
    
    init(withPaymentMethod method: PaymentMethod, paymentController: PaymentController) {
        paymentMethod = method
        self.paymentController = paymentController
        
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRequestToShowExternalPaymentDetailsFlow), name: PaymentRequestManager.didRequestExternalPaymentCompletionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishPaymentRequest), name: PaymentRequestManager.didFinishRequestNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.view.backgroundColor = Theme.headerFooterBackgroundColor
        view.backgroundColor = Theme.headerFooterBackgroundColor
        
        navigationBar.title = "checkout"
        navigationBar.buttonType = .dismiss(target: self, action: #selector(close))
        
        var frame = subheaderLabel.frame
        frame.origin.y = navigationBar.frame.maxY
        subheaderLabel.frame = frame
        view.addSubview(subheaderLabel)
        
        frame = paymentMethodView.frame
        frame.origin.y = subheaderLabel.frame.maxY
        paymentMethodView.frame = frame
        view.addSubview(paymentMethodView)
        
        frame = paymentButtonView.frame
        frame.origin.y = paymentMethodView.frame.maxY
        paymentButtonView.frame = frame
        view.addSubview(paymentButtonView)
        
        paymentButton.frame = paymentButtonPreferredFrame
        
        preferredContentSize = CGSize(width: view.bounds.width, height: frame.maxY)
        navigationController?.preferredContentSize = preferredContentSize
    }
    
    // MARK: - SFSafariViewController
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // If this is called, that means user clicked Done instead of going through the flow.
        // So just reset the state.
        animateLoadingIndicatorIntoPaymentButton()
    }
    
    // MARK: - Private
    
    private var paymentMethod: PaymentMethod
    private var paymentController: PaymentController
    
    private lazy var subheaderLabel: UILabel = {
        var frame = self.view.bounds
        frame.size.height = Theme.headerFooterHeight
        let label = UILabel(frame: frame)
        label.text = "Your selected payment method"
        label.font = Theme.standardFontSmall
        label.textAlignment = .center
        label.textColor = Theme.standardTextColor
        label.backgroundColor = Theme.headerFooterBackgroundColor
        label.autoresizingMask = .flexibleWidth
        return label
    }()
    
    private var subtitle: String? {
        if paymentMethod.type == "card" {
            return PaymentRequestManager.shared.blockedOutCardNumber
        }
        
        return nil
    }
    
    private lazy var paymentMethodView: UIView = {
        var frame = self.view.bounds
        frame.size.height = 70.0
        
        let paymentMethodView = UIView(frame: frame)
        paymentMethodView.backgroundColor = UIColor.white
        
        frame = CGRect.zero
        let margin: CGFloat = 26.0
        
        if let logoURL = paymentMethod.logoURL, let icon = PaymentMethodImageCache.shared.confirmationIcon(from: logoURL) {
            let iconImageView = UIImageView(image: icon)
            iconImageView.contentMode = .center
            iconImageView.sizeToFit()
            
            frame.size = iconImageView.frame.size
            frame.origin.x = margin
            frame.origin.y = paymentMethodView.bounds.size.height / 2.0 - frame.size.height / 2.0
            iconImageView.frame = frame
            iconImageView.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            paymentMethodView.addSubview(iconImageView)
            
            frame.origin.x = frame.maxX + 30.0
        }
        
        let titleLabel = UILabel(frame: .zero)
        titleLabel.textColor = Theme.primaryColor
        titleLabel.font = Theme.standardFontSmall
        titleLabel.text = self.paymentMethod.name
        titleLabel.sizeToFit()
        
        frame.origin.y = 0
        frame.size.width = titleLabel.frame.width
        
        paymentMethodView.addSubview(titleLabel)
        
        if let subtitle = self.subtitle {
            let subtitleLabel = UILabel(frame: .zero)
            subtitleLabel.textColor = Theme.secondaryColor
            subtitleLabel.font = Theme.standardFontSmall
            subtitleLabel.text = subtitle
            subtitleLabel.sizeToFit()
            
            let totalTextHeight = titleLabel.frame.height + subtitleLabel.frame.height
            
            frame.size.height = titleLabel.frame.height
            frame.origin.y = paymentMethodView.bounds.height / 2 - totalTextHeight / 2
            titleLabel.frame = frame
            
            frame.origin.y = frame.maxY
            frame.size.height = subtitleLabel.frame.size.height
            frame.size.width = subtitleLabel.frame.width
            subtitleLabel.frame = frame
            paymentMethodView.addSubview(subtitleLabel)
        } else {
            frame.size.height = paymentMethodView.bounds.height
            titleLabel.frame = frame
            titleLabel.autoresizingMask = [.flexibleRightMargin, .flexibleHeight]
        }
        
        let changeButton = UIButton(type: .custom)
        changeButton.layer.borderColor = Theme.primaryColor.cgColor
        changeButton.layer.borderWidth = 1.0
        changeButton.layer.cornerRadius = 2.0
        changeButton.titleLabel?.font = Theme.standardFontSmall
        changeButton.setTitle("Change", for: .normal)
        changeButton.setTitleColor(Theme.primaryColor, for: .normal)
        changeButton.addTarget(self, action: #selector(changePaymentMethod), for: .touchUpInside)
        changeButton.sizeToFit()
        
        frame = changeButton.frame
        frame.size.width = frame.width + 20.0
        frame.origin.x = paymentMethodView.bounds.width - frame.width - margin
        frame.origin.y = paymentMethodView.bounds.height / 2 - frame.height / 2
        changeButton.frame = frame
        changeButton.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
        paymentMethodView.addSubview(changeButton)
        
        return paymentMethodView
    }()
    
    private lazy var paymentButtonView: UIView = {
        var frame = self.view.bounds
        frame.size.height = 129.0
        let paymentButtonView = UIView(frame: frame)
        paymentButtonView.backgroundColor = Theme.headerFooterBackgroundColor
        
        self.paymentButton.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
        paymentButtonView.addSubview(self.paymentButton)
        
        return paymentButtonView
    }()
    
    private var paymentButtonPreferredTitle: String {
        return "PAY \(PaymentRequestManager.shared.paymentAmountString)"
    }
    
    private var paymentButtonPreferredFrame: CGRect {
        var frame = paymentButton.frame
        frame.origin.x = Theme.buttonMargin
        frame.size.width = paymentButtonView.frame.width - 2 * frame.minX
        frame.size.height = Theme.buttonHeight
        frame.origin.y = paymentButtonView.bounds.height / 2 - frame.height / 2
        return frame
    }
    
    private lazy var paymentButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = Theme.primaryColor
        button.layer.cornerRadius = 25.0
        button.setTitle(self.paymentButtonPreferredTitle, for: .normal)
        button.titleLabel?.font = Theme.standardFontRegular
        button.addTarget(self, action: #selector(confirmPaymentClicked), for: .touchUpInside)
        return button
    }()
    
    private var loadingIndicator = LoadingIndicatorView.defaultLoadingIndicator()
    
    private var disabledView: UIView = {
        let disabledView = UIView(frame: .zero)
        disabledView.backgroundColor = UIColor.white
        return disabledView
    }()
    
    @objc private func changePaymentMethod() {
        navigationController?.popToRootViewController(animated: false)
    }
    
    @objc private func confirmPaymentClicked() {
        animatePaymentButtonIntoLoadingIndicator {
            // Provide selection to PaymentRequestManager and wait for notifications for further instructions.
            PaymentRequestManager.shared.select(paymentMethod: self.paymentMethod)
        }
    }
    
    private func animatePaymentButtonIntoLoadingIndicator(withCompletionHandler completion: @escaping () -> Void) {
        paymentButton.setTitle(nil, for: .normal)
        loadingIndicator.isHidden = false
        loadingIndicator.alpha = 0.0
        paymentButtonView.addSubview(loadingIndicator)
        loadingIndicator.start()
        
        var newFrame = self.paymentButton.frame
        newFrame.size.width = 50.0
        newFrame.origin.x = paymentButtonView.bounds.size.width / 2 - newFrame.width / 2
        loadingIndicator.frame = newFrame
        
        var disabledFrame = subheaderLabel.frame
        disabledFrame.size.height = disabledFrame.height + paymentMethodView.frame.height
        disabledView.frame = disabledFrame
        view.addSubview(disabledView)
        disabledView.isHidden = false
        disabledView.alpha = 0.0
        
        view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.paymentButton.frame = newFrame
            self.loadingIndicator.alpha = 1.0
            self.disabledView.alpha = 0.5
        }) { _ in
            completion()
        }
    }
    
    private func animateLoadingIndicatorIntoPaymentButton() {
        paymentButton.alpha = 1.0
        loadingIndicator.isHidden = true
        loadingIndicator.start()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.paymentButton.frame = self.paymentButtonPreferredFrame
            self.loadingIndicator.alpha = 0.0
            self.disabledView.alpha = 0.0
        }) { _ in
            self.paymentButton.setTitle(self.paymentButtonPreferredTitle, for: .normal)
            self.disabledView.removeFromSuperview()
            self.loadingIndicator.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    @objc private func didRequestToShowExternalPaymentDetailsFlow(_ notification: NSNotification) {
        if let url = notification.userInfo?[PaymentRequestManager.externalPaymentCompletionURLKey] as? URL {
            let external = SFSafariViewController(url: url)
            if #available(iOS 10.0, *) {
                external.preferredControlTintColor = Theme.primaryColor
            }
            external.modalPresentationStyle = .custom
            external.modalPresentationCapturesStatusBarAppearance = true
            external.delegate = self
            present(external, animated: true, completion: nil)
        }
    }
    
    @objc private func didFinishPaymentRequest(_ notification: NSNotification) {
        if let requestStatus = notification.userInfo?[PaymentRequestManager.finishedRequestStatusKey] as? PaymentRequestManager.RequestStatus {
            switch requestStatus {
            case .success:
                loadingIndicator.markAsCompleted()
            case .failure:
                loadingIndicator.markAsError()
            default:
                break
            }
        }
        
        view.isUserInteractionEnabled = true
        
        // Dismiss external view controller.
        dismiss(animated: true, completion: nil)
        
        // Dismiss self.
        view.isUserInteractionEnabled = true
        DispatchQueue.main.asyncAfter(deadline: (DispatchTime.now() + DispatchTimeInterval.seconds(1))) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
