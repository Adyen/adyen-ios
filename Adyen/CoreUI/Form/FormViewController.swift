//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A view controller designed to display form elements, such as `FormTextField` and `FormCheckmarkButton`.
internal class FormViewController: ContainerViewController {
    
    // MARK: - View
    
    private(set) internal lazy var formView = FormView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView = formView
        
        let notificationCenter = NotificationCenter.default
        
        #if swift(>=4.2)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        #else
        notificationCenter.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
        #endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        assignInitialFirstResponder()
    }
    
    // MARK: - Initial First Responder
    
    /// This method assigns the first available arranged subview as a first responder. It will only run once.
    private func assignInitialFirstResponder() {
        guard didAssignInitialFirstResponder == false else {
            return
        }
        
        guard let firstResponder = formView.arrangedSubviews.first(where: { $0.canBecomeFirstResponder }) else {
            return
        }
        
        firstResponder.becomeFirstResponder()
        
        didAssignInitialFirstResponder = true
    }
    
    private var didAssignInitialFirstResponder = false
    
    // MARK: - Keyboard
    
    @objc private func keyboardWillChangeFrame(_ notification: NSNotification) {
        #if swift(>=4.2)
        let key = UIResponder.keyboardFrameEndUserInfoKey
        #else
        let key = UIKeyboardFrameEndUserInfoKey
        #endif
        
        guard let bounds = notification.userInfo?[key] as? CGRect else {
            return
        }
        
        containerView.contentInset.bottom = bounds.height
        containerView.scrollIndicatorInsets.bottom = bounds.height
    }
    
}
