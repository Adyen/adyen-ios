//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Displays a form for the user to enter details.
@objc(ADYFormViewController)
@_documentation(visibility: internal)
open class FormViewController: UIViewController, AdyenObserver, PreferredContentSizeConsumer {

    fileprivate enum Animations {
        fileprivate static let keyboardBottomInset = "keyboardBottomInset"
        fileprivate static let firstResponder = "firstResponder"
    }

    public var requiresKeyboardInput: Bool { formRequiresInputView() }

    /// Indicates the `FormViewController` UI styling.
    public let style: ViewStyle

    /// Delegate to handle different viewController events.
    public weak var delegate: ViewControllerDelegate?
    
    internal lazy var keyboardObserver = KeyboardObserver()

    // MARK: - Public

    /// Initializes the FormViewController.
    ///
    /// - Parameters:
    ///   - style: The `FormViewController` UI style.
    ///   - localizationParameters: The localization parameters.
    public init(
        style: ViewStyle,
        localizationParameters: LocalizationParameters?
    ) {
        self.style = style
        self.localizationParameters = localizationParameters
        super.init(nibName: nil, bundle: Bundle(for: FormViewController.self))
    }

    // MARK: - View lifecycle

    override open func viewDidLoad() {
        super.viewDidLoad()
        addFormView()
        itemManager.topLevelItemViews.forEach(formView.appendItemView(_:))
        delegate?.viewDidLoad(viewController: self)
        
        observe(keyboardObserver.$keyboardRect) { [weak self] _ in
            self?.didUpdatePreferredContentSize()
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.viewWillAppear(viewController: self)
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delegate?.viewDidAppear(viewController: self)

        view.adyen.animate(context: AnimationContext(animationKey: Animations.firstResponder,
                                                     duration: 0,
                                                     options: [.layoutSubviews, .beginFromCurrentState],
                                                     animations: { [weak self] in
                                                         self?.assignInitialFirstResponder()
                                                     }))
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resignFirstResponder()
    }

    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resetForm()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var preferredContentSize: CGSize {
        get { formView.intrinsicContentSize }

        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assertionFailure(message: """
        PreferredContentSize is overridden for this view controller.
        getter - returns minimum possible content size.
        setter - no implemented.
        """) }
    }

    // MARK: - Private Properties

    private lazy var itemManager = FormViewItemManager()

    // MARK: - PreferredContentSizeConsumer

    public func willUpdatePreferredContentSize() { /* Empty implementation */ }

    public func didUpdatePreferredContentSize() {
        let bottomInset: CGFloat = keyboardObserver.keyboardRect.height - view.safeAreaInsets.bottom
        let context = AnimationContext(animationKey: Animations.keyboardBottomInset,
                                       duration: 0.25,
                                       options: [.beginFromCurrentState, .layoutSubviews],
                                       animations: { [weak self] in
                                           self?.formView.contentInset.bottom = bottomInset
                                       })
        view.adyen.animate(context: context)
    }

    // MARK: - Items

    /// Appends an item to the form.
    ///
    /// - Parameters:
    ///   - item: The item to append.
    @_documentation(visibility: internal)
    public func append(_ item: some FormItem) {
        let itemView = itemManager.append(item)
        observerVisibility(of: item, and: itemView)
        itemView.applyTextDelegateIfNeeded(delegate: self)
        addItemViewIfNeeded(itemView)
    }

    private func addItemViewIfNeeded(_ itemView: AnyFormItemView) {
        guard isViewLoaded else { return }
        formView.appendItemView(itemView)
    }

    private func observerVisibility(of item: some FormItem, and itemView: UIView) {
        guard let item = item as? Hidable else { return }
        itemView.adyen.hide(animationKey: String(describing: itemView),
                            hidden: item.isHidden.wrappedValue, animated: false)

        observe(item.isHidden) { isHidden in
            itemView.adyen.hide(animationKey: String(describing: itemView),
                                hidden: isHidden, animated: true)
        }
    }

    // MARK: - Localizable

    public let localizationParameters: LocalizationParameters?

    // MARK: - Validity

    /// Validates the items in the form. If the form's contents are invalid, an alert is presented.
    ///
    /// - Returns: Whether the form is valid or not.
    public func validate() -> Bool {
        let validatableItems = getAllValidatableItems()
        let isValid = validatableItems.allSatisfy { $0.isValid() }

        // Exit when all validations passed.
        guard !isValid else { return true }

        resignFirstResponder()

        showValidation()

        return false
    }

    @_documentation(visibility: internal)
    public func showValidation() {
        let validatableItemViews = itemManager.flatItemViews
            .compactMap { $0 as? AnyFormValidatableValueItemView }
        
        validatableItemViews.forEach { $0.showValidation() }
        
        let firstInvalidItemView = validatableItemViews.first { !$0.isValid }
        
        if let firstInvalidItemView {
            UIAccessibility.post(notification: .screenChanged, argument: firstInvalidItemView)
        }
    }

    private func getAllValidatableItems() -> [ValidatableFormItem] {
        let visibleItems = itemManager.topLevelItem.filter {
            !(($0 as? Hidable)?.isHidden.wrappedValue == true)
        }

        let validatableItems = visibleItems.flatMap(\.flatSubitems).compactMap { $0 as? ValidatableFormItem }
        return validatableItems
    }

    private func formRequiresInputView() -> Bool {
        itemManager.flatItems.contains { $0 is InputViewRequiringFormItem }
    }

    public func resetForm() {
        itemManager.flatItemViews.forEach { $0.reset() }
    }

    // MARK: - Private

    private func addFormView() {
        view.addSubview(formView)
        view.backgroundColor = style.backgroundColor
        formView.backgroundColor = style.backgroundColor
        formView.adyen.anchor(inside: view.safeAreaLayoutGuide)
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

@_documentation(visibility: internal)
extension FormViewController: FormTextItemViewDelegate {

    public func didReachMaximumLength(in itemView: FormTextItemView<some FormTextItem>) {
        handleReturnKey(from: itemView)
    }

    public func didSelectReturnKey(in itemView: FormTextItemView<some FormTextItem>) {
        handleReturnKey(from: itemView)
    }

    private func handleReturnKey(from itemView: FormTextItemView<some FormTextItem>) {
        let itemViews = itemManager.flatItemViews

        // Determine the index of the current item view.
        guard let currentIndex = itemViews.firstIndex(where: { $0 === itemView }) else {
            return
        }

        // Create a slice of the remaining item views.
        let remainingItemViews = itemViews.suffix(from: itemViews.index(after: currentIndex))

        // Find the first item view that's eligible to become a first responder.
        let nextItemView = remainingItemViews.first { $0.canBecomeFirstResponder && $0.isHidden == false }

        // Assign the first responder, or resign the current one if there is none remaining.
        if let nextItemView {
            nextItemView.becomeFirstResponder()
        } else {
            itemView.resignFirstResponder()
        }
    }

}
