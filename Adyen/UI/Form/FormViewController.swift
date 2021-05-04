//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Displays a form for the user to enter details.
/// :nodoc:
@objc(ADYFormViewController)
open class FormViewController: UIViewController, Localizable, KeyboardObserver, Observer, PreferredContentSizeConsumer {

    /// :nodoc:
    public var requiresKeyboardInput: Bool { formRequiresInputView() }

    /// Indicates the `FormViewController` UI styling.
    public let style: ViewStyle

    /// :nodoc:
    /// Delegate to handle different viewController events.
    public weak var delegate: ViewControllerDelegate?

    // MARK: - Public
    
    /// Initializes the FormViewController.
    ///
    /// - Parameter style: The `FormViewController` UI style.
    public init(style: ViewStyle) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
        startObserving()
    }

    deinit {
        stopObserving()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// :nodoc:
    override public var preferredContentSize: CGSize {
        get { formView.intrinsicContentSize }
        
        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assert(message: """
        PreferredContentSize is overridden for this view controller.
        getter - returns minimum possible content size.
        setter - no implemented.
        """) }
    }

    // MARK: - KeyboardObserver

    /// :nodoc:
    public var keyboardObserver: Any?

    /// :nodoc:
    public func startObserving() {
        keyboardObserver = startObserving { [weak self] in
            self?.keyboardRect = $0
            self?.didUpdatePreferredContentSize()
        }
    }

    private var keyboardRect: CGRect = .zero

    private func updateScrollViewInsets(keyboardHeight: CGFloat) {
        formView.contentInset.bottom = keyboardHeight
    }

    // MARK: - Private Properties

    private lazy var itemManager = FormViewItemManager()

    // MARK: - PreferredContentSizeConsumer

    /// :nodoc:
    public func willUpdatePreferredContentSize() { /* Empty implementation */ }

    /// :nodoc:
    public func didUpdatePreferredContentSize() {
        updateScrollViewInsets(keyboardHeight: keyboardRect.height)
        view.layoutIfNeeded()
    }
    
    // MARK: - Items
    
    /// Appends an item to the form.
    ///
    /// - Parameters:
    ///   - item: The item to append.
    public func append<T: FormItem>(_ item: T) {
        let itemView = itemManager.append(item)
        observerVisibility(of: item, and: itemView)
        itemView.applyTextDelegateIfNeeded(delegate: self)
        addItemViewIfNeeded(itemView)
    }

    private func addItemViewIfNeeded(_ itemView: AnyFormItemView) {
        guard isViewLoaded else { return }
        formView.appendItemView(itemView)
    }

    private func observerVisibility<T: FormItem>(of item: T, and itemView: UIView) {
        guard let item = item as? Hidable else { return }
        observe(item.isHidden) { isHidden in
            itemView.adyen.hideWithAnimation(isHidden)
        }
    }

    // MARK: - Localizable

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
        
        itemManager.flatItemViews
            .compactMap { $0 as? AnyFormValueItemView }
            .forEach { $0.validate() }
        
        resignFirstResponder()
        
        return false
    }
    
    private func getAllValidatableItems() -> [ValidatableFormItem] {
        itemManager.flatItems.compactMap { $0 as? ValidatableFormItem }
    }
    
    private func formRequiresInputView() -> Bool {
        itemManager.flatItems.contains { $0 is InputViewRequiringFormItem }
    }
    
    // MARK: - View
    
    /// :nodoc:
    override open func viewDidLoad() {
        super.viewDidLoad()
        addFormView()
        
        delegate?.viewDidLoad(viewController: self)
        itemManager.topLevelItemViews.forEach(formView.appendItemView(_:))
    }

    private func addFormView() {
        view.addSubview(formView)
        view.backgroundColor = style.backgroundColor
        formView.backgroundColor = style.backgroundColor
        formView.adyen.anchor(inside: view.safeAreaLayoutGuide)
    }
    
    /// :nodoc:
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.viewDidAppear(viewController: self)
        assignInitialFirstResponder()
    }
    
    private lazy var formView: FormView = {
        let form = FormView()
        form.translatesAutoresizingMaskIntoConstraints = false
        return form
    }()

    // MARK: - UIResponder
    
    @discardableResult
    override public func resignFirstResponder() -> Bool {
        let textItemView = itemManager.flatItemViews.first(where: { $0.isFirstResponder })
        textItemView?.resignFirstResponder()
        
        return super.resignFirstResponder()
    }
    
    // MARK: - Other
    
    private func assignInitialFirstResponder() {
        guard view.isUserInteractionEnabled else { return }
        let textItemView = itemManager.topLevelItemViews.first(where: { $0.canBecomeFirstResponder })
        textItemView?.becomeFirstResponder()
    }
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
        let itemViews = itemManager.flatItemViews
        
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
