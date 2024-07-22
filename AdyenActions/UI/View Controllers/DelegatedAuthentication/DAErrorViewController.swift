//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

@available(iOS 16.0, *)
internal final class DAErrorViewController: UIViewController {

    internal enum Screen {
        
        private enum Constant {
            static let feedbackImage = UIImage(named: "feedback",
                                               in: Bundle.actionsInternalResources,
                                               compatibleWith: nil)
            static let checkmarkImage = UIImage(systemName: "checkmark.circle",
                                                withConfiguration: UIImage.SymbolConfiguration(weight: .ultraLight))
            static let thrashImage = UIImage(systemName: "trash",
                                             withConfiguration: UIImage.SymbolConfiguration(weight: .ultraLight))
        }
        
        case authenticationFailed(localizationParameters: LocalizationParameters?)
        case registrationFailed(localizationParameters: LocalizationParameters?)
        case deletionConfirmation(localizationParameters: LocalizationParameters?)
        
        internal var title: String {
            switch self {
            case let .authenticationFailed(localizationParameters):
                return localizedString(.threeds2DAApprovalErrorTitle, localizationParameters)
            case let .registrationFailed(localizationParameters):
                return localizedString(.threeds2DARegistrationErrorTitle, localizationParameters)
            case let .deletionConfirmation(localizationParameters):
                return localizedString(.threeds2DADeletionConfirmationTitle, localizationParameters)
            }
        }
        
        internal var image: UIImage? {
            switch self {
            case .authenticationFailed:
                return Constant.feedbackImage
            case .registrationFailed:
                return Constant.checkmarkImage?.withTintColor(.systemGreen,
                                                              renderingMode: .alwaysOriginal)
            case .deletionConfirmation:
                return Constant.thrashImage?.withTintColor(.systemGray,
                                                           renderingMode: .alwaysOriginal)
            }
        }
        
        internal var message: String {
            switch self {
            case let .authenticationFailed(localizationParameters):
                return localizedString(.threeds2DAApprovalErrorMessage, localizationParameters)
            case let .registrationFailed(localizationParameters):
                return localizedString(.threeds2DARegistrationErrorMessage, localizationParameters)
            case let .deletionConfirmation(localizationParameters):
                return localizedString(.threeds2DADeletionConfirmationMessage, localizationParameters)
            }
        }
                
        internal var buttonTitle: String {
            switch self {
            case let .authenticationFailed(localizationParameters):
                return localizedString(.threeds2DAApprovalErrorButtonTitle, localizationParameters)
            case let .registrationFailed(localizationParameters):
                return localizedString(.threeds2DARegistrationErrorButtonTitle, localizationParameters)
            case let .deletionConfirmation(localizationParameters):
                return localizedString(.threeds2DADeletionConfirmationButtonTitle, localizationParameters)
            }
        }
    }

    private lazy var errorView: DelegatedAuthenticationErrorView = .init(style: style)
    private let style: DelegatedAuthenticationComponentStyle
    private let continueHandler: VoidHandler
    private let screen: Screen
    
    // MARK: - Init

    internal init(style: DelegatedAuthenticationComponentStyle,
                  screen: Screen,
                  completion: @escaping () -> Void) {
        self.style = style
        self.screen = screen
        self.continueHandler = completion

        super.init(nibName: nil, bundle: Bundle(for: DAErrorViewController.self))
        errorView.delegate = self
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        configureErrorView()
        view.backgroundColor = style.errorBackgroundColor
        configureErrorView()
        isModalInPresentation = true
    }
        
    // MARK: - Configuration
    
    private func configureErrorView() {
        errorView.titleLabel.text = screen.title
        errorView.descriptionLabel.text = screen.message
        errorView.firstButton.title = screen.buttonTitle
        errorView.image.image = screen.image
    }
    
    private func buildUI() {
        view.addSubview(errorView)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.adyen.anchor(inside: view.safeAreaLayoutGuide)
    }

    override internal var preferredContentSize: CGSize {
        get {
            UIView.layoutFittingExpandedSize
        }

        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assertionFailure(message: """
        PreferredContentSize is overridden for this view controller.
        getter - returns minimum possible content size.
        setter - no implemented.
        """) }
    }
}

@available(iOS 16.0, *)
extension DAErrorViewController: DelegatedAuthenticationErrorViewDelegate {
    internal func firstButtonTapped() {
        errorView.firstButton.showsActivityIndicator = true
        continueHandler()
    }
}
