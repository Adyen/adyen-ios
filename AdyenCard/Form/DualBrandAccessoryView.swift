//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A segmented picker view housing up to 2 brand logos with selection support for dual-branded cards.
internal class DualBrandAccessoryView: UIView {
    
    internal enum BrandSelection: Int {
        case primary = 0
        case secondary
    }
    
    internal enum BrandDisplayMode: Equatable {
        case single
        case dualUnselectable
        case dualSelectable
    }
    
    private enum Constants {
        static let iconSize = CGSize(width: 27, height: 18)
        static let placeholderImage = UIImage(named: "ic_card_front", in: .cardInternalResources, compatibleWith: nil)
        static let containerCornerRadius: CGFloat = 8
        static let optionCornerRadius: CGFloat = 7
        static let optionPadding: CGFloat = 5
        static let containerPadding: CGFloat = 2
        static let stackSpacing: CGFloat = 2
        static let selectedBorderWidth: CGFloat = 1
        static var selectedBorderColor: UIColor {
            UIColor.Adyen.componentTertiaryLabel.withAlphaComponent(0.2)
        }

        static let selectedShadowRadius: CGFloat = 8
        static let selectedShadowOffset = CGSize(width: 0, height: 3)
        static let selectedShadowOpacity: Float = 0.12
        static var segmentedBackgroundColor: UIColor {
            UIColor.Adyen.secondaryComponentBackground
        }

        static let animationDuration: TimeInterval = 0.2
    }
    
    private let style: ImageStyle
    private var primaryLogoUrl: URL?
    private var secondaryLogoUrl: URL?
    private let imageLoader: ImageLoading
    private var imageLoadingTasks = [AdyenCancellable]()
    
    internal let childItemViews: [any AnyFormItemView] = []
    
    internal private(set) var currentSelection: BrandSelection = .primary
    
    internal var onBrandSelection: ((BrandSelection) -> Void)?
    
    private var displayMode: BrandDisplayMode = .single {
        didSet {
            guard displayMode != oldValue else { return }
            applyDisplayMode()
        }
    }
    
    // MARK: - Subviews
    
    private lazy var segmentedBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.containerCornerRadius
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [primaryOptionView, secondaryOptionView])
        stackView.axis = .horizontal
        stackView.spacing = Constants.stackSpacing
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    internal private(set) lazy var primaryLogoView: UIImageView = createEmptyImageView()
    
    internal private(set) lazy var secondaryLogoView: UIImageView = createEmptyImageView()
    
    private lazy var primaryOptionView: UIView = createOptionView(with: primaryLogoView)
    
    private lazy var secondaryOptionView: UIView = {
        let view = createOptionView(with: secondaryLogoView)
        view.isHidden = true
        secondaryLogoView.isHidden = true
        return view
    }()
    
    private lazy var primaryTapGesture = UITapGestureRecognizer(target: self, action: #selector(primaryOptionTapped))
    private lazy var secondaryTapGesture = UITapGestureRecognizer(target: self, action: #selector(secondaryOptionTapped))
    
    private var singleBrandConstraints: [NSLayoutConstraint] = []
    private var dualBrandConstraints: [NSLayoutConstraint] = []
    private var optionPaddingConstraints: [NSLayoutConstraint] = []
    
    // MARK: - Init
    
    internal init(
        style: ImageStyle,
        imageLoader: ImageLoading = ImageLoaderProvider.imageLoader()
    ) {
        self.style = style
        self.imageLoader = imageLoader
        
        super.init(frame: .zero)
        clipsToBounds = false
        setupViews()
        setupConstraints()
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public API
    
    internal func updateCurrentLogos(
        _ logos: [FormCardLogosItem.CardTypeLogo],
        mode: BrandDisplayMode = .single
    ) {
        resetState()
        guard !logos.isEmpty else { return }
        setupLogoViews(from: logos, mode: mode)
    }
    
    internal func overflowHitTest(point: CGPoint, with event: UIEvent?) -> UIView? {
        guard displayMode == .dualSelectable else { return nil }
        
        let visualBounds = segmentedBackground.frame
        guard visualBounds.contains(point) else { return nil }
        
        for subview in subviews.reversed() {
            let subviewPoint = subview.convert(point, from: self)
            if let hitView = subview.hitTest(subviewPoint, with: event) {
                return hitView
            }
        }
        
        return self
    }
    
    /// Updates the selection from outside.
    internal func updateSelection(with selection: BrandSelection) {
        currentSelection = selection
        updateSelectionAppearance()
    }
    
    // MARK: - Layout
    
    override public var intrinsicContentSize: CGSize {
        if displayMode == .dualSelectable {
            return CGSize(width: UIView.noIntrinsicMetric, height: Constants.iconSize.height)
        }
        return super.intrinsicContentSize
    }
    
    // MARK: - Appearance
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard displayMode == .dualSelectable else { return }
        updateSelectionAppearance()
    }
    
    // MARK: - Display Mode
    
    private func applyDisplayMode() {
        // Reset to baseline
        NSLayoutConstraint.deactivate(dualBrandConstraints)
        NSLayoutConstraint.deactivate(singleBrandConstraints)
        primaryOptionView.removeGestureRecognizer(primaryTapGesture)
        secondaryOptionView.removeGestureRecognizer(secondaryTapGesture)
        segmentedBackground.isHidden = true
        applySelectionStyle(to: primaryOptionView, selected: false)
        applySelectionStyle(to: secondaryOptionView, selected: false)
        
        switch displayMode {
        case .single:
            NSLayoutConstraint.activate(singleBrandConstraints)
            setOptionPadding(0)
            setSecondaryVisible(false)
            
        case .dualUnselectable:
            NSLayoutConstraint.activate(singleBrandConstraints)
            setOptionPadding(0)
            setSecondaryVisible(true)
            
        case .dualSelectable:
            NSLayoutConstraint.activate(dualBrandConstraints)
            setOptionPadding(Constants.optionPadding)
            setSecondaryVisible(true)
            segmentedBackground.backgroundColor = Constants.segmentedBackgroundColor
            segmentedBackground.isHidden = false
            primaryOptionView.addGestureRecognizer(primaryTapGesture)
            secondaryOptionView.addGestureRecognizer(secondaryTapGesture)
            currentSelection = .primary
            updateSelectionAppearance()
        }
        
        invalidateIntrinsicContentSize()
    }
    
    private func setSecondaryVisible(_ visible: Bool) {
        secondaryOptionView.isHidden = !visible
        secondaryLogoView.isHidden = !visible
    }
    
    private func setOptionPadding(_ padding: CGFloat) {
        optionPaddingConstraints.forEach { $0.constant = padding }
    }
    
    // MARK: - Selection
    
    @objc private func primaryOptionTapped() {
        select(.primary)
    }
    
    @objc private func secondaryOptionTapped() {
        select(.secondary)
    }
    
    private func select(_ selection: BrandSelection) {
        guard currentSelection != selection else { return }
        currentSelection = selection
        UIView.animate(withDuration: Constants.animationDuration) { self.updateSelectionAppearance() }
        onBrandSelection?(selection)
    }
    
    private func updateSelectionAppearance() {
        applySelectionStyle(to: primaryOptionView, selected: currentSelection == .primary)
        applySelectionStyle(to: secondaryOptionView, selected: currentSelection == .secondary)
    }
    
    // MARK: - State Management
    
    private func resetState() {
        primaryLogoUrl = nil
        secondaryLogoUrl = nil
        currentSelection = .primary
        
        primaryLogoView.image = Constants.placeholderImage
        secondaryLogoView.image = Constants.placeholderImage
        
        displayMode = .single
    }
    
    // MARK: - Logo Setup
    
    private func setupLogoViews(from logos: [FormCardLogosItem.CardTypeLogo], mode: BrandDisplayMode) {
        guard let firstLogo = logos.first else { return }
        let secondLogo = logos.adyen[safeIndex: 1]
        
        primaryLogoUrl = firstLogo.url
        secondaryLogoUrl = secondLogo?.url
        
        primaryLogoView.accessibilityValue = firstLogo.type.name
        primaryLogoView.isAccessibilityElement = true
        
        if secondLogo != nil {
            secondaryLogoView.accessibilityValue = secondLogo?.type.name
        }
        secondaryLogoView.isAccessibilityElement = secondLogo != nil
        
        displayMode = mode
        updateLogos()
    }
    
    // MARK: - View Creation
    
    private func setupViews() {
        addSubview(segmentedBackground)
        addSubview(stackView)
    }
    
    private func setupConstraints() {
        singleBrandConstraints = [
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        dualBrandConstraints = [
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.containerPadding),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.containerPadding),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.containerPadding),
            
            segmentedBackground.topAnchor.constraint(equalTo: stackView.topAnchor, constant: -Constants.containerPadding),
            segmentedBackground.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: -Constants.containerPadding),
            segmentedBackground.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: Constants.containerPadding),
            segmentedBackground.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: Constants.containerPadding)
        ]
        
        optionPaddingConstraints = [
            primaryLogoView.topAnchor.constraint(equalTo: primaryOptionView.topAnchor),
            primaryLogoView.leadingAnchor.constraint(equalTo: primaryOptionView.leadingAnchor),
            primaryOptionView.trailingAnchor.constraint(equalTo: primaryLogoView.trailingAnchor),
            primaryOptionView.bottomAnchor.constraint(equalTo: primaryLogoView.bottomAnchor),
            secondaryLogoView.topAnchor.constraint(equalTo: secondaryOptionView.topAnchor),
            secondaryLogoView.leadingAnchor.constraint(equalTo: secondaryOptionView.leadingAnchor),
            secondaryOptionView.trailingAnchor.constraint(equalTo: secondaryLogoView.trailingAnchor),
            secondaryOptionView.bottomAnchor.constraint(equalTo: secondaryLogoView.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(optionPaddingConstraints)
        NSLayoutConstraint.activate(singleBrandConstraints)
    }
    
    // MARK: - Image Loading
    
    override public func didMoveToWindow() {
        super.didMoveToWindow()
        updateLogos()
    }
    
    private func updateLogos() {
        imageLoadingTasks.forEach { $0.cancel() }
        
        guard let primaryLogoUrl else { return }
        
        var imageLoadingTasks = [primaryLogoView.load(
            url: primaryLogoUrl,
            using: imageLoader,
            placeholder: Constants.placeholderImage
        )]
        
        if let secondaryLogoUrl {
            imageLoadingTasks.append(
                secondaryLogoView.load(
                    url: secondaryLogoUrl,
                    using: imageLoader,
                    placeholder: Constants.placeholderImage
                )
            )
        }
        
        self.imageLoadingTasks = imageLoadingTasks
    }
}

// MARK: - View Factory

extension DualBrandAccessoryView {
    
    private func createOptionView(with imageView: UIImageView) -> UIView {
        let wrapper = UIView()
        wrapper.layer.cornerRadius = Constants.optionCornerRadius
        wrapper.clipsToBounds = false
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(imageView)
        
        return wrapper
    }
    
    private func createEmptyImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = Constants.placeholderImage
        imageView.adyen.round(using: style.cornerRounding)
        imageView.layer.masksToBounds = style.clipsToBounds
        imageView.layer.borderWidth = style.borderWidth
        imageView.layer.borderColor = style.borderColor?.cgColor
        imageView.backgroundColor = style.backgroundColor
        imageView.widthAnchor.constraint(equalToConstant: Constants.iconSize.width).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: Constants.iconSize.height).isActive = true
        return imageView
    }
    
    private func applySelectionStyle(to view: UIView, selected: Bool) {
        if selected {
            view.backgroundColor = UIColor.Adyen.componentBackground
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = Constants.selectedShadowOffset
            view.layer.shadowRadius = Constants.selectedShadowRadius
            view.layer.shadowOpacity = Constants.selectedShadowOpacity
            view.layer.borderWidth = Constants.selectedBorderWidth
            view.layer.borderColor = Constants.selectedBorderColor.cgColor
        } else {
            view.backgroundColor = .clear
            view.layer.shadowOpacity = 0
            view.layer.borderWidth = 0
        }
    }
}
