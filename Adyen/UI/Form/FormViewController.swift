//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Displays a form for the user to enter details.
/// :nodoc:
@objc(ADYFormViewController)
open class FormViewController: UIViewController, Localizable, KeyboardObserver, Observer, PreferredContentSizeConsumer {

    fileprivate enum Animations {
        fileprivate static let keyboardBottomInset = "keyboardBottomInset"
        fileprivate static let firstResponder = "firstResponder"
    }

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
        super.init(nibName: nil, bundle: Bundle(for: FormViewController.self))
        startObserving()
    }

    deinit {
        stopObserving()
    }

    // MARK: - View lifecycle

    /// :nodoc:
    override open func viewDidLoad() {
        super.viewDidLoad()
        addFormView()
        itemManager.topLevelItemViews.forEach(formView.appendItemView(_:))
        delegate?.viewDidLoad(viewController: self)
    }

    /// :nodoc:
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.viewWillAppear(viewController: self)
    }

    /// :nodoc:
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

    /// :nodoc:
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resignFirstResponder()
    }

    /// :nodoc:
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resetForm()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// :nodoc:
    override public var preferredContentSize: CGSize {
        get { formView.intrinsicContentSize }

        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assertionFailure(message: """
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
        startObserving { [weak self] in
            self?.keyboardRect = $0
            self?.didUpdatePreferredContentSize()
        }
    }

    // MARK: - Private Properties

    private var keyboardRect: CGRect = .zero

    private lazy var itemManager = FormViewItemManager()

    // MARK: - PreferredContentSizeConsumer

    /// :nodoc:
    public func willUpdatePreferredContentSize() { /* Empty implementation */ }

    /// :nodoc:
    public func didUpdatePreferredContentSize() {
        let bottomInset: CGFloat = keyboardRect.height - view.safeAreaInsets.bottom
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
        itemView.adyen.hide(animationKey: String(describing: itemView),
                            hidden: item.isHidden.wrappedValue, animated: false)

        observe(item.isHidden) { isHidden in
            itemView.adyen.hide(animationKey: String(describing: itemView),
                                hidden: isHidden, animated: true)
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

        resignFirstResponder()

        showValidation()

        return false
    }

    /// :nodoc:
    public func showValidation() {
        itemManager.flatItemViews
            .compactMap { $0 as? AnyFormValueItemView }
            .forEach { $0.validate() }
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
        let nextItemView = remainingItemViews.first { $0.canBecomeFirstResponder && $0.isHidden == false }

        // Assign the first responder, or resign the current one if there is none remaining.
        if let nextItemView = nextItemView {
            nextItemView.becomeFirstResponder()
        } else {
            itemView.resignFirstResponder()
        }
    }

}
