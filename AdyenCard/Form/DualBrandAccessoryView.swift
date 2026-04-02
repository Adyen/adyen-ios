//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A segmented picker view housing up to 2 brand logos with selection support for dual-branded cards.
internal class DualBrandAccessoryView: UIView {
    
    internal enum BrandSelection {
        case primary
        case secondary
    }
    
    private enum Constants {
        static let iconSize = CGSize(width: 27, height: 18)
        static let placeholderImage = UIImage(named: "ic_card_front", in: .cardInternalResources, compatibleWith: nil)
        static let containerCornerRadius: CGFloat = 8
        static let optionCornerRadius: CGFloat = 7
        static let optionPadding: CGFloat = 5
        static let containerPadding: CGFloat = 2
        static let stackSpacing: CGFloat = 2
        static let selectedBorderWidth: CGFloat = 0.5
        static let selectedBorderColor = UIColor.black.withAlphaComponent(0.04)
        static let selectedShadowRadius: CGFloat = 8
        static let selectedShadowOffset = CGSize(width: 0, height: 3)
        static let selectedShadowOpacity: Float = 0.12
        static let segmentedBackgroundColor = UIColor.Adyen.secondaryComponentBackground
        static let animationDuration: CGFloat = 0.2
    }
    
    private let style: ImageStyle
    private var primaryLogoUrl: URL?
    private var secondaryLogoUrl: URL?
    private let imageLoader: ImageLoading
    private var imageLoadingTasks = [AdyenCancellable]()
    
    internal let childItemViews: [any AnyFormItemView] = []
    
    internal private(set) var selectedBrand: BrandSelection = .primary
    
    internal var onBrandSelection: ((BrandSelection) -> Void)?
    
    private var isSegmentedPickerActive: Bool {
        !secondaryOptionView.isHidden
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
        return stackView
    }()
    
    internal private(set) lazy var primaryLogoView: UIImageView = createEmptyImageView()
    
    internal private(set) lazy var secondaryLogoView: UIImageView = createEmptyImageView()
    
    private lazy var primaryOptionView: UIView = createOptionView(with: primaryLogoView)
    
    private lazy var secondaryOptionView: UIView = {
        let view = createOptionView(with: secondaryLogoView)
        view.isHidden = true
        return view
    }()
    
    private lazy var primaryTapGesture = UITapGestureRecognizer(target: self, action: #selector(primaryOptionTapped))
    private lazy var secondaryTapGesture = UITapGestureRecognizer(target: self, action: #selector(secondaryOptionTapped))
    
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
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public API
    
    internal func updateCurrentLogos(_ logos: [FormCardLogosItem.CardTypeLogo]) {
        resetState()
        guard !logos.isEmpty else { return }
        setupLogoViews(from: logos)
    }
    
    // MARK: - Layout
    
    override public var intrinsicContentSize: CGSize {
        // needed to return a calculated size since the stack view top is not constrained
        CGSize(width: UIView.noIntrinsicMetric, height: Constants.iconSize.height)
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard isSegmentedPickerActive else { return }
        updateSelectionAppearance()
    }
    
    // MARK: - Selection
    
    @objc private func primaryOptionTapped() {
        select(.primary)
    }
    
    @objc private func secondaryOptionTapped() {
        select(.secondary)
    }
    
    private func setupViews() {
        addSubview(segmentedBackground)
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                // stackview top not connected to clip through
                stackView.leadingAnchor.constraint(
                    equalTo: leadingAnchor,
                    constant: Constants.containerPadding
                ),
                stackView.trailingAnchor.constraint(
                    equalTo: trailingAnchor,
                    constant: -Constants.containerPadding
                ),
                stackView.bottomAnchor.constraint(
                    equalTo: bottomAnchor,
                    constant: -Constants.containerPadding
                ),
                
                segmentedBackground.topAnchor.constraint(
                    equalTo: stackView.topAnchor,
                    constant: -Constants.containerPadding
                ),
                segmentedBackground.leadingAnchor.constraint(
                    equalTo: stackView.leadingAnchor,
                    constant: -Constants.containerPadding
                ),
                segmentedBackground.trailingAnchor.constraint(
                    equalTo: stackView.trailingAnchor,
                    constant: Constants.containerPadding
                ),
                segmentedBackground.bottomAnchor.constraint(
                    equalTo: stackView.bottomAnchor,
                    constant: Constants.containerPadding
                )
            ]
        )
        primaryLogoView.image = Constants.placeholderImage
    }
    
    private func select(_ brand: BrandSelection) {
        guard selectedBrand != brand else { return }
        selectedBrand = brand
        UIView.animate(withDuration: Constants.animationDuration) { self.updateSelectionAppearance() }
        onBrandSelection?(brand)
    }
    
    private func updateSelectionAppearance() {
        applySelectionStyle(to: primaryOptionView, selected: selectedBrand == .primary)
        applySelectionStyle(to: secondaryOptionView, selected: selectedBrand == .secondary)
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
    
    // MARK: - State Management
    
    private func resetState() {
        primaryLogoUrl = nil
        secondaryLogoUrl = nil
        selectedBrand = .primary
        
        primaryLogoView.image = Constants.placeholderImage
        secondaryLogoView.image = Constants.placeholderImage
        
        primaryOptionView.removeGestureRecognizer(primaryTapGesture)
        secondaryOptionView.removeGestureRecognizer(secondaryTapGesture)
        segmentedBackground.isHidden = true
        secondaryOptionView.isHidden = true
        applySelectionStyle(to: primaryOptionView, selected: false)
    }
    
    // MARK: - Logo Setup
    
    private func setupLogoViews(from logos: [FormCardLogosItem.CardTypeLogo]) {
        guard let firstLogo = logos.first else { return }
        let secondLogo = logos.adyen[safeIndex: 1]
        
        primaryLogoUrl = firstLogo.url
        secondaryLogoUrl = secondLogo?.url
        
        primaryLogoView.accessibilityValue = firstLogo.type.name
        primaryLogoView.isAccessibilityElement = true
        
        if let secondLogo {
            secondaryLogoView.accessibilityValue = secondLogo.type.name
            
            // un-hide the second logo view and enable tapping
            segmentedBackground.backgroundColor = Constants.segmentedBackgroundColor
            segmentedBackground.isHidden = false
            secondaryOptionView.isHidden = false
            
            primaryOptionView.addGestureRecognizer(primaryTapGesture)
            secondaryOptionView.addGestureRecognizer(secondaryTapGesture)
            
            selectedBrand = .primary
            updateSelectionAppearance()
        }
        
        secondaryLogoView.isAccessibilityElement = secondLogo != nil
        
        updateLogos()
    }
    
    // MARK: - View Creation
    
    private func createOptionView(with imageView: UIImageView) -> UIView {
        let wrapper = UIView()
        wrapper.layer.cornerRadius = Constants.optionCornerRadius
        wrapper.clipsToBounds = false
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(imageView)
        imageView.adyen.anchor(
            inside: wrapper,
            with: .init(
                top: Constants.optionPadding,
                left: Constants.optionPadding,
                bottom: Constants.optionPadding,
                right: Constants.optionPadding
            )
        )
        
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
