//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

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
        
        // Forms need to have a navigation bar that matches the background of the view.
        navigationController?.navigationBar.barTintColor = navigationController?.view.backgroundColor
        navigationController?.navigationBar.isTranslucent = false
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
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
        guard let bounds = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        formView.contentInset.bottom = bounds.height
        formView.scrollIndicatorInsets.bottom = bounds.height
    }
    
}
