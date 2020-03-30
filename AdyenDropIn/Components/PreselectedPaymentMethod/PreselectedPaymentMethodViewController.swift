//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal class PreselectedPaymentMethodViewController: UIViewController {
    
    internal typealias SelectionHandler = () -> Void
    
    private let style: PreselectedPaymentMethodStyle
    private let listItem: ListItem
    private let didSelectSubmit: SelectionHandler
    private let didSelectOpenAll: SelectionHandler
    private var payment: Payment?
    
    // MARK: Public
    
    /// Inititate a view controller for a One Click component.
    /// - Parameters:
    ///   - listItem: Description of a stored payment visual representation.
    ///   - style: style to use for.
    ///   - didSelectSubmit: Action to be executed when user taps submit button.
    ///   - didSelectOpenAll: Action to be executed when user taps button to open all available payment methods.
    internal init(listItem: ListItem,
                  style: PreselectedPaymentMethodStyle,
                  payment: Payment? = nil,
                  didSelectSubmit: @escaping SelectionHandler,
                  didSelectOpenAll: @escaping SelectionHandler) {
        self.listItem = listItem
        self.style = style
        self.didSelectOpenAll = didSelectOpenAll
        self.didSelectSubmit = didSelectSubmit
        self.payment = payment
        super.init(nibName: nil, bundle: nil)
        
        self.title = title
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal var isBusy: Bool = false {
        willSet(value) {
            submitButton.showsActivityIndicator = value
        }
    }
    
    // MARK: View
    
    /// The form view's scroll view.
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.preservesSuperviewLayoutMargins = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        return scrollView
    }()
    
    private lazy var submitButton: SubmitButton = {
        let button = SubmitButton(style: style.submitButton)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "submitButton")
        button.title = ADYLocalizedSubmitButtonTitle(with: payment?.amount, localizationParameters)
        button.addTarget(self, action: #selector(didSelectSubmitButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    private lazy var moreButton: SubmitButton = {
        let button = SubmitButton(style: style.openAllButton)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "moreButton")
        button.title = ADYLocalizedString("adyen.dropIn.preselected.openAll.title", localizationParameters)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(didSelectOpenAllButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var separator: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.AdyenCore.componentSeparator
        return view
    }()
    
    private lazy var itemView: ListItemView = {
        let view = ListItemView()
        view.item = listItem
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let views = [ContainerView(body: itemView, padding: .init(top: 12, left: 16, bottom: 8, right: 16)),
                     ContainerView(body: submitButton, padding: .init(top: 8, left: 16, bottom: 20, right: 16)),
                     separator,
                     ContainerView(body: moreButton, padding: .init(top: 8, left: 16, bottom: 8, right: 16))]
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    /// :nodoc:
    public override var preferredContentSize: CGSize {
        get {
            let targetSize = CGSize(width: view.superview?.bounds.width ?? UIScreen.main.bounds.width,
                                    height: UIView.layoutFittingCompressedSize.height)
            return stackView.systemLayoutSizeFitting(targetSize,
                                                     withHorizontalFittingPriority: .required,
                                                     verticalFittingPriority: .fittingSizeLevel)
        }
        
        // swiftlint:disable:next unused_setter_value
        set { assertionFailure("""
        PreferredContentSize is overridden for this view controller.
        getter - returns content size of scroll view.
        setter - no implemented.
        """) }
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        configureConstraints()
    }
    
    private func configureConstraints() {
        let leadingAnchor: NSLayoutXAxisAnchor
        let trailingAnchor: NSLayoutXAxisAnchor
        
        if #available(iOS 11.0, *) {
            leadingAnchor = view.safeAreaLayoutGuide.leadingAnchor
            trailingAnchor = view.safeAreaLayoutGuide.trailingAnchor
        } else {
            leadingAnchor = view.leadingAnchor
            trailingAnchor = view.trailingAnchor
        }
        
        let bottomAttachmentConstraint = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomAttachmentConstraint.priority = .defaultHigh
        
        let constraints = [
            separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),
            
            scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomAttachmentConstraint,
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints.compactMap { $0 })
    }
    
    @objc private func didSelectSubmitButton() {
        submitButton.showsActivityIndicator = true
        self.didSelectSubmit()
    }
    
    @objc private func didSelectOpenAllButton() {
        self.didSelectOpenAll()
    }
    
    // MARK: - Localization
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
}
