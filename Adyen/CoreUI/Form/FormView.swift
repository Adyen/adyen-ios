//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// :nodoc:
public class FormView: UIScrollView {
    public init() {
        super.init(frame: .zero)
        
        addSubview(titleLabel)
        footerStackView.addArrangedSubview(payButton)
        addSubview(footerStackView)
        addSubview(formStackView)
        
        configureConstraints()
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    public private(set) lazy var payButton: UIButton = {
        let payButton = Appearance.shared.payButton
        payButton.isEnabled = false
        payButton.translatesAutoresizingMaskIntoConstraints = false
        return payButton
    }()
    
    public var title: String? {
        didSet {
            if let title = title {
                titleLabel.attributedText = NSAttributedString(string: title, attributes: Appearance.shared.formAttributes.titleAttributes)
            }
        }
    }
    
    public func addFormElement(_ element: UIView) {
        element.backgroundColor = UIColor.clear
        
        // Embed in a stack view so that we can set margins.
        let stackView = UIStackView()
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(element)
        formStackView.addArrangedSubview(stackView)
        
        func containsFormField(_ view: UIView) -> Bool {
            if view is FormField || view is FormPicker {
                return true
            } else {
                for subview in view.subviews where subview is FormField || subview is FormPicker {
                    return true
                }
            }
            
            return false
        }
        
        if containsFormField(element) {
            addSeparator()
        }
    }
    
    public func addFooterElement(_ element: UIView) {
        footerStackView.addArrangedSubview(element)
    }
    
    // MARK: - Internal
    
    internal var firstResponder: UIResponder? {
        func allSubviews(_ view: UIView) -> [UIView] {
            var subviews = [UIView]()
            
            for subview in view.subviews {
                subviews.append(contentsOf: allSubviews(subview))
                subviews.append(subview)
            }
            
            return subviews
        }
        
        let subviews = allSubviews(formStackView)
        return subviews.first(where: { $0.canBecomeFirstResponder })
    }
    
    // MARK: - Private
    
    private let margin: CGFloat = 16
    
    private lazy var wrapperView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    private lazy var formStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor.clear
        return stackView
    }()
    
    private lazy var footerStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: margin)
        stackView.spacing = 12.0
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.backgroundColor = UIColor.clear
        return stackView
    }()
    
    private func configureConstraints() {
        NSLayoutConstraint.deactivate(self.constraints)
        
        var constraints: [NSLayoutConstraint] = []
        
        let titleLabelConstraints = [
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor)
        ]
        constraints.append(contentsOf: titleLabelConstraints)
        
        let stackViewConstraints = [
            formStackView.firstBaselineAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16.0),
            formStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            formStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            formStackView.widthAnchor.constraint(equalTo: widthAnchor)
        ]
        constraints.append(contentsOf: stackViewConstraints)
        
        let footerConstraints = [
            footerStackView.topAnchor.constraint(equalTo: formStackView.bottomAnchor, constant: 32),
            footerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            footerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            footerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin)
        ]
        constraints.append(contentsOf: footerConstraints)
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addSeparator() {
        let separator = UIView(frame: .zero)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = Appearance.shared.formAttributes.separatorColor
        
        let height = 1.0 / UIScreen.main.scale
        separator.heightAnchor.constraint(equalToConstant: height).isActive = true
        formStackView.addArrangedSubview(separator)
        separator.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        separator.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
}
