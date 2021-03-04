//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// :nodoc:
/// Delegate to handle different viewController events.
public protocol ViewControllerDelegate: AnyObject {
    
    /// :nodoc:
    /// Handles the UIViewController.viewDidLoad() event.
    func viewDidLoad(viewController: UIViewController)

    /// :nodoc:
    /// Handles the UIViewController.viewDidAppear() event.
    func viewDidAppear(viewController: UIViewController)
    
}

/// Displays a form for the user to enter details.
/// :nodoc:
@objc(ADYFormViewController)
public final class FormViewController: UIViewController, Localizable {
    
    private lazy var itemManager = FormViewItemManager(itemViewDelegate: self)
    
    /// :nodoc:
    public var requiresKeyboardInput: Bool { formRequiresInputView() }
    
    /// Indicates the `FormViewController` UI styling.
    public let style: ViewStyle
    
    /// :nodoc:
    /// Delegate to handle different viewController events.
    public weak var delegate: ViewControllerDelegate?
    
    /// Initializes the FormViewController.
    ///
    /// - Parameter style: The `FormViewController` UI style.
    public init(style: ViewStyle) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    /// :nodoc:
    override public var preferredContentSize: CGSize {
        get { formView.intrinsicContentSize }
        
        // swiftlint:disable:next unused_setter_value
        set { assertionFailure("""
        PreferredContentSize is overridden for this view controller.
        getter - returns minimum possible content size.
        setter - no implemented.
        """) }
    }
    
    // MARK: - Items
    
    /// The items displayed in the form.
    public var items: [FormItem] {
        itemManager.items
    }
    
    /// Appends an item to the form.
    ///
    /// - Parameters:
    ///   - item: The item to append.
    ///   - itemViewType: Optionally, the item view type to use for this item.
    ///                   When none is specified, the default will be used.
    public func append<T: FormItem>(_ item: T) {
        itemManager.append(item)
        
        if isViewLoaded, let itemView = itemManager.itemView(for: item) {
            formView.appendItemView(itemView)
        }
    }
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    // MARK: - Validity
    
    /// Validates the items in the form. If the form's contents are invalid, an alert is presented.
    ///
    /// - Returns: Whether the form is valid or not.
    public func validate() -> Bool {
        let validatableItems = getAllValidatableItems()
        let isValid = validatableItems.allSatisfy { $0.isValid() }
        
        // Exit when all validations passed.
        guard !isValid else { return true }
        
        itemManager.allItemViews
            .compactMap { $0 as? AnyFormValueItemView }
            .forEach { $0.validate() }
        
        resignFirstResponder()
        
        return false
    }
    
    private func getAllValidatableItems() -> [ValidatableFormItem] {
        let flatItems = getAllFlatItems()
        return flatItems.compactMap { $0 as? ValidatableFormItem }
    }
    
    private func formRequiresInputView() -> Bool {
        let flatItems = getAllFlatItems()
        return flatItems.contains { $0 is InputViewRequiringFormItem }
    }
    
    private func getAllFlatItems() -> [FormItem] {
        itemManager.items.flatMap(\.flatSubitems)
    }
    
    // MARK: - View
    
    /// :nodoc:
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(formView)
        setupConstraints()
        
        delegate?.viewDidLoad(viewController: self)
        
        itemManager.itemViews.forEach(formView.appendItemView(_:))
        
        view.backgroundColor = style.backgroundColor
        formView.backgroundColor = style.backgroundColor
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(keyboardWillChangeFrame(_:)),
                                       name: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil)
    }
    
    /// :nodoc:
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        assignInitialFirstResponder()
        delegate?.viewDidAppear(viewController: self)
    }
    
    private lazy var formView: FormView = {
        let form = FormView()
        form.translatesAutoresizingMaskIntoConstraints = false
        return form
    }()
    
    private var bottomConstraint: NSLayoutConstraint?
    
    private func setupConstraints() {

        let constraints: [NSLayoutConstraint?]
        if #available(iOS 11.0, *) {
            bottomConstraint = formView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            constraints = [
                formView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                bottomConstraint,
                formView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
                formView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor)
            ]
        } else {
            bottomConstraint = formView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            constraints = [
                formView.topAnchor.constraint(equalTo: view.topAnchor),
                bottomConstraint,
                formView.leftAnchor.constraint(equalTo: view.leftAnchor),
                formView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ]
        }
        
        bottomConstraint?.priority = .defaultHigh
        NSLayoutConstraint.activate(constraints.compactMap { $0 })
    }
    
    // MARK: - Keyboard
    
    @discardableResult
    override public func resignFirstResponder() -> Bool {
        let textItemView = itemManager.allItemViews.first(where: { $0.isFirstResponder })
        textItemView?.resignFirstResponder()
        
        return super.resignFirstResponder()
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        var heightOffset = keyboardFrame.origin.y - UIScreen.main.bounds.height
        
        if #available(iOS 11.0, *) {
            heightOffset += min(abs(heightOffset), view.safeAreaInsets.bottom)
        }
        
        bottomConstraint?.constant = heightOffset
    }
    
    // MARK: - Other
    
    private func assignInitialFirstResponder() {
        guard view.isUserInteractionEnabled else { return }
        let textItemView = itemManager.itemViews.first(where: { $0.canBecomeFirstResponder })
        textItemView?.becomeFirstResponder()
    }
}

// MARK: - FormValueItemViewDelegate

extension FormViewController: FormValueItemViewDelegate {
    
    /// :nodoc:
    public func didChangeValue<T: FormValueItem>(in itemView: FormValueItemView<T>) {}
    
}

// MARK: - FormTextItemViewDelegate

extension FormViewController: FormTextItemViewDelegate {
    
    /// :nodoc:
    public func didReachMaximumLength<T: FormTextItem>(in itemView: FormTextItemView<T>) {
        handleReturnKey(from: itemView)
    }
    
    /// :nodoc:
    public func didSelectReturnKey<T: FormTextItem>(in itemView: FormTextItemView<T>) {
        handleReturnKey(from: itemView)
    }
    
    private func handleReturnKey<T: FormTextItem>(from itemView: FormTextItemView<T>) {
        let itemViews = itemManager.allItemViews
        
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
