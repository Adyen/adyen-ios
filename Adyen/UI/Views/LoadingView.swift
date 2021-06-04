//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// :nodoc:
public final class LoadingView: UIControl {

    /// :nodoc:
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: activityIndicatorStyle)
        activityIndicatorView.backgroundColor = .clear
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()
    
    private var activityIndicatorStyle: UIActivityIndicatorView.Style {
        if #available(iOS 13.0, *) {
            return .medium
        } else {
            return .white
        }
    }

    private let contentView: UIView

    /// :nodoc:
    public init(contentView: UIView) {
        self.contentView = contentView
        super.init(frame: .zero)
        addSubview(contentView)
        addSubview(activityIndicatorView)
        contentView.adyen.anchor(inside: self)

        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    /// :nodoc:
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Boolean value indicating whether an activity indicator should be shown.
    public var showsActivityIndicator: Bool {
        get {
            activityIndicatorView.isAnimating
        }

        set {
            if newValue {
                activityIndicatorView.startAnimating()
                isEnabled = false
                isUserInteractionEnabled = false
            } else {
                activityIndicatorView.stopAnimating()
                isEnabled = true
                isUserInteractionEnabled = true
            }
        }
    }
}
