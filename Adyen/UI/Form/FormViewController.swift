//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Displays a form for the user to enter details.
/// :nodoc:
public final class FormViewController: UIViewController {
    
    // MARK: - Items
    
    /// The items displayed in the form.
    public var items: [FormItem] {
        return itemManager.items
    }
    
    /// Appends an item to the form.
    ///
    /// - Parameters:
    ///   - item: The item to append.
    ///   - itemViewType: Optionally, the item view type to use for this item.
    ///                   When none is specified, the default will be used.
    public func append<T: FormItem>(_ item: T, using itemViewType: FormItemView<T>.Type? = nil) {
        itemManager.append(item, using: itemViewType)
        
        if isViewLoaded {
            let itemView = itemManager.itemView(for: item)
            formView.appendItemView(itemView)
        }
    }
    
    private lazy var itemManager = FormViewItemManager(itemViewDelegate: self)
    
    // MARK: - Validity
    
    /// Validates the items in the form. If the form's contents are invalid, an alert is presented.
    ///
    /// - Returns: Whether the form is valid or not.
    public func validate() -> Bool {
        var textItems = itemManager.items.compactMap { $0 as? FormTextItem }
        
        // Append items from FormSplitTextItem.
        // TODO: Consider having a childItems property in the protocol.
        itemManager.items.compactMap { $0 as? FormSplitTextItem }.forEach { textItems += [$0.leftItem, $0.rightItem] }
        
        let failureMessages: [String] = textItems.compactMap { textItem in
            guard let validator = textItem.validator else { return nil }
            
            return validator.isValid(textItem.value) ? nil : textItem.validationFailureMessage
        }
        
        // Exit when all validations passed.
        if failureMessages.isEmpty {
            return true
        }
        
        let alertController = UIAlertController(title: ADYLocalizedString("adyen.validationAlert.title"),
                                                message: nil,
                                                preferredStyle: .alert)
        
        if failureMessages.count == 1 {
            alertController.message = failureMessages.first
        } else {
            alertController.message = failureMessages.map { "• " + $0 }.joined(separator: "\n")
        }
        
        alertController.addAction(UIAlertAction(title: ADYLocalizedString("adyen.dismissButton"),
                                                style: .default,
                                                handler: nil))
        present(alertController, animated: true, completion: nil)
        
        return false
    }
    
    // MARK: - View
    
    /// :nodoc:
    public override func loadView() {
        view = FormView()
    }
    
    /// :nodoc:
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        itemManager.itemViews.forEach(formView.appendItemView(_:))
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillChangeFrame(_:)),
                                       name: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil)
    }
    
    /// :nodoc:
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        assignInitialFirstResponder()
    }
    
    private var formView: FormView {
        return view as! FormView // swiftlint:disable:this force_cast
    }
    
    // MARK: - Keyboard
    
    @objc private func keyboardWillChangeFrame(_ notification: NSNotification) {
        guard let bounds = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        var inset = bounds.height
        if #available(iOS 11.0, *) {
            inset -= formView.safeAreaInsets.bottom
        }
        
        formView.scrollView.contentInset.bottom = inset
        formView.scrollView.scrollIndicatorInsets.bottom = inset
    }
    
    // MARK: - Other
    
    private func assignInitialFirstResponder() {
        // Only become first responder for larger screens.
        guard UIScreen.main.bounds.height > 600 else { return }
        guard didAssignInitialFirstResponder == false else { return }
        
        let textItemViews = itemManager.itemViews(ofType: FormTextItemView.self)
        textItemViews.first?.becomeFirstResponder()
        
        didAssignInitialFirstResponder = true
    }
    
    private var didAssignInitialFirstResponder = false
    
}

// MARK: - FormValueItemViewDelegate

extension FormViewController: FormValueItemViewDelegate {
    
    /// :nodoc:
    public func didChangeValue<T: FormValueItem>(in itemView: FormValueItemView<T>) {}
    
}

// MARK: - FormTextItemViewDelegate

extension FormViewController: FormTextItemViewDelegate {
    
    /// :nodoc:
    public func didReachMaximumLength(in itemView: FormTextItemView) {
        handleReturnKey(from: itemView)
    }
    
    /// :nodoc:
    public func didSelectReturnKey(in itemView: FormTextItemView) {
        handleReturnKey(from: itemView)
    }
    
    private func handleReturnKey(from itemView: FormTextItemView) {
        let itemViews = itemManager.itemViews(ofType: FormTextItemView.self)
        
        // Determine the index of the current item view.
        guard let currentIndex = itemViews.firstIndex(where: { $0 === itemView }) else {
            return
        }
        
        // Create a slice of the remaining item views.
        let remainingItemViews = itemViews.suffix(from: itemViews.index(after: currentIndex))
        
        // Find the first item view that's eligible to become a first responder.
        let nextItemView = remainingItemViews.first { $0.canBecomeFirstResponder }
        
        // Assign the first responder, or resign the current one if there is none remaining.
        if let nextItemView = nextItemView {
            nextItemView.becomeFirstResponder()
        } else {
            itemView.resignFirstResponder()
        }
    }
    
}
