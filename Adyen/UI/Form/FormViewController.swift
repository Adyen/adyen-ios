//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// :nodoc:
open class FormViewController: UIViewController {
    
    public init(appearance: Appearance) {
        self.appearance = appearance
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    
    open override var title: String? {
        set {
            formView.title = newValue
        }
        get {
            return nil
        }
    }
    
    open override func loadView() {
        view = formView
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        formView.payButton.addTarget(self, action: #selector(pay), for: .touchUpInside)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        assignInitialFirstResponder()
    }
    
    // MARK: - Public
    
    public private(set) lazy var formView = FormView()
    
    public let appearance: Appearance
    
    public var payActionTitle: String? {
        didSet {
            formView.payButton.setTitle(payActionTitle, for: .normal)
        }
    }
    
    public var payActionSubtitle: String? {
        didSet {
            let attributes = appearance.formAttributes.footerTitleAttributes
            formView.payButtonSubtitle.attributedText = NSAttributedString(string: payActionSubtitle ?? "", attributes: attributes)
        }
    }
    
    public var isValid: Bool = false {
        didSet {
            formView.payButton.isEnabled = isValid
        }
    }
    
    @objc open func pay() {
        // Payment logic implemented by the subclasses
        
        view.endEditing(true)
        formView.payButton.showsActivityIndicator = true
    }
    
    // MARK: - Private
    
    /// This method assigns the first available arranged subview as a first responder. It will only run once.
    private func assignInitialFirstResponder() {
        // Only become first responder for larger screens.
        guard UIScreen.main.bounds.height > 600 else {
            return
        }
        
        guard didAssignInitialFirstResponder == false else {
            return
        }
        
        if let firstResponder = formView.firstResponder {
            firstResponder.becomeFirstResponder()
            didAssignInitialFirstResponder = true
        }
    }
    
    private var didAssignInitialFirstResponder = false
    
    @objc private func keyboardWillChangeFrame(_ notification: NSNotification) {
        guard let bounds = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        formView.contentInset.bottom = bounds.height
        formView.scrollIndicatorInsets.bottom = bounds.height
    }
    
}
