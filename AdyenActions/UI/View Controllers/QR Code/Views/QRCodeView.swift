//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
@_spi(AdyenInternal) import Adyen

internal final class QRCodeView: UIView, AdyenObserver {
    
    private enum Layout {
        static let qrCodeImageWidth: CGFloat = 170
        static let progressViewSize = CGSize(width: 120, height: 4)
    }
    
    // MARK: - Subviews
    
    internal let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
        
    internal let amountLabel: UILabel
    internal let progressView: UIProgressView
    internal let expirationLabel: UILabel
    
    // MARK: - Initialization
    
    internal init(viewModel: QRCodeViewModel, style: QRCodeViewStyle) {
        self.amountLabel = UILabel(style: style.amountToPayLabel)
        self.progressView = UIProgressView(style: style.progressView)
        self.expirationLabel = UILabel(style: style.expirationLabel)
        
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        buildViewHierarchy()
        setupLayoutConstraints()
        configureAppearance()
        configure(with: viewModel)
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func buildViewHierarchy() {
        [imageView, amountLabel, progressView, expirationLabel]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                addSubview($0)
            }
    }
    
    private func setupLayoutConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: Layout.qrCodeImageWidth),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            amountLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            amountLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            progressView.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 12),
            progressView.centerXAnchor.constraint(equalTo: centerXAnchor),
            progressView.widthAnchor.constraint(equalToConstant: Layout.progressViewSize.width),
            progressView.heightAnchor.constraint(equalToConstant: Layout.progressViewSize.height),
            
            expirationLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 12),
            expirationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            expirationLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func configureAppearance() {
        amountLabel.numberOfLines = 0
        amountLabel.font = UIFont.preferredFont(forTextStyle: .callout).adyen.font(with: .bold)
        
        expirationLabel.numberOfLines = 0
    }
    
    // MARK: - Configuration
    
    private func configure(with viewModel: QRCodeViewModel) {
        let qrCodeSize = CGSize(width: Layout.qrCodeImageWidth, height: Layout.qrCodeImageWidth)
        imageView.image = viewModel.qrCodeData.generateQRCode(size: qrCodeSize)
        
        amountLabel.text = viewModel.amountText
        
        progressView.observedProgress = viewModel.observedProgress
        
        bind(viewModel.expiration, to: expirationLabel, at: \.text) { string in
            guard let text = string, !text.isEmpty else {
                self.expirationLabel.alpha = 0
                return " "
            }
            self.expirationLabel.alpha = 1
            return text
        }
    }
}
