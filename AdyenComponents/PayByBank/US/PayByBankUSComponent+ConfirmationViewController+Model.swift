//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
@_spi(AdyenInternal) import Adyen

extension PayByBankUSComponent.ConfirmationViewController {
    
    internal class Model {
        
        internal let headerImageUrl: URL
        internal let supportedBankLogoURLs: [URL]
        internal let supportedBanksMoreText: String
        internal let title: String
        internal let subtitle: String
        internal let message: String
        internal let submitTitle: String
        
        internal let style: PayByBankUSComponent.Style
        internal let headerImageViewSize = CGSize(width: 80, height: 52)
        
        internal let continueHandler: () -> Void
        
        private let imageLoader: ImageLoading = ImageLoaderProvider.imageLoader()
        private var imageLoadingTask: AdyenCancellable? {
            willSet { imageLoadingTask?.cancel() }
        }
        
        internal init(
            title: String,
            headerImageUrl: URL,
            supportedBankLogoNames: [String],
            style: PayByBankUSComponent.Style,
            localizationParameters: LocalizationParameters?,
            logoUrlProvider: LogoURLProvider,
            continueHandler: @escaping () -> Void
        ) {
            self.headerImageUrl = headerImageUrl
            self.supportedBankLogoURLs = supportedBankLogoNames.map { logoUrlProvider.logoURL(withName: $0) }
            self.supportedBanksMoreText = localizedString(.payByBankAISDDMore, localizationParameters)
            self.title = title
            self.subtitle = localizedString(.payByBankAISDDDisclaimerHeader, localizationParameters)
            self.message = localizedString(.payByBankAISDDDisclaimerBody, localizationParameters)
            self.submitTitle = localizedString(.payByBankAISDDSubmit, localizationParameters)
            self.style = style
            self.continueHandler = continueHandler
        }
        
        internal func loadHeaderImage(for imageView: UIImageView) {
            imageLoadingTask = imageView.load(url: headerImageUrl, using: imageLoader)
        }
    }
}
