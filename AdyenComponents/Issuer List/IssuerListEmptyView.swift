//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

/// The empty view to be used in the IssuerListComponent SearchViewController
internal class IssuerListEmptyView: UIStackView, SearchViewControllerEmptyView {
    
    private let localizationParameters: LocalizationParameters?
    
    public var searchTerm: String {
        didSet { updateLabels() }
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "search",
                                  in: Bundle.coreInternalResources,
                                  compatibleWith: nil)
        imageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        imageView.setContentHuggingPriority(.required, for: .vertical)

        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2).adyen.font(with: .bold)
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        return titleLabel
    }()

    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.text = localizedString(.paybybankSubtitle, localizationParameters)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        
        return subtitleLabel
    }()
    
    // MARK: - Stack View
    
    internal init(localizationParameters: LocalizationParameters? = nil) {
        
        self.localizationParameters = localizationParameters
        self.searchTerm = ""
        
        super.init(frame: .zero)
        
        addArrangedSubview(imageView)
        setCustomSpacing(32.0, after: imageView)
        
        addArrangedSubview(titleLabel)
        setCustomSpacing(4.0, after: titleLabel)
        
        addArrangedSubview(subtitleLabel)
        
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        alignment = .center
        distribution = .fill
        
        updateLabels()
    }
    
    @available(*, unavailable)
    internal required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension IssuerListEmptyView {
    
    func updateLabels() {
        titleLabel.text = "\(localizedString(.paybybankTitle, localizationParameters)) '\(searchTerm)'"
    }
}
