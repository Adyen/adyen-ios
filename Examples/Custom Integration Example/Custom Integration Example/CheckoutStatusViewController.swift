//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class CheckoutStatusViewController: UIViewController {
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        
        checkoutStepImageView.translatesAutoresizingMaskIntoConstraints = false
        checkoutStepImageView.backgroundColor = UIColor.clear
        checkoutStepImageView.contentMode = .top
        view.addSubview(checkoutStepImageView)
        
        nextStepButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextStepButton)
        
        layoutSubviews()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    // MARK: - Public
    
    var checkoutStepImageView = UIImageView()
    
    lazy var nextStepButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        button.backgroundColor = Theme.primaryColor
        let font = Theme.standardFontRegular
        button.titleLabel?.font = Theme.standardFontRegular
        button.layer.cornerRadius = 25.0
        
        return button
    }()
    
    @objc func buttonClicked() {
        // Implemented by the subclasses.
    }
    
    // MARK: - Private
    
    private func layoutSubviews() {
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: checkoutStepImageView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: checkoutStepImageView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: Theme.buttonMargin),
            NSLayoutConstraint(item: checkoutStepImageView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: -Theme.buttonMargin),
            NSLayoutConstraint(item: checkoutStepImageView, attribute: .bottom, relatedBy: .equal, toItem: nextStepButton, attribute: .top, multiplier: 1.0, constant: -Theme.buttonMargin),
            NSLayoutConstraint(item: nextStepButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: Theme.buttonMargin),
            NSLayoutConstraint(item: nextStepButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: -Theme.buttonMargin),
            NSLayoutConstraint(item: nextStepButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: Theme.buttonHeight),
            NSLayoutConstraint(item: nextStepButton, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -Theme.buttonMargin)
        ])
    }
    
}
