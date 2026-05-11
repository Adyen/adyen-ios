//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

package final class LoadingView: UIControl {

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: activityIndicatorStyle)
        activityIndicatorView.backgroundColor = .clear
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()
    
    private var activityIndicatorStyle: UIActivityIndicatorView.Style {
        .large
    }

    private let contentView: UIView
    
    package var disableUserInteractionWhileLoading: Bool = false

    package var spinnerAppearanceDelay: DispatchTimeInterval = .seconds(1)

    package init(contentView: UIView) {
        self.contentView = contentView
        super.init(frame: .zero)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        addSubview(activityIndicatorView)
        contentView.adyen.anchor(inside: self)

        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    @available(*, unavailable)
    package required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Boolean value indicating whether an activity indicator should be shown.
    package var showsActivityIndicator: Bool {
        get {
            activityIndicatorView.isAnimating
        }

        set {
            if newValue {
                startAnimating(after: spinnerAppearanceDelay)
            } else {
                stopAnimating()
            }
        }
    }
    
    internal var workItem: DispatchWorkItem?
    
    private func startAnimating(after delay: DispatchTimeInterval) {
        guard !activityIndicatorView.isAnimating else { return }
        workItem?.cancel()
        workItem = nil
        let workItem = DispatchWorkItem { [weak self] in
            self?.startAnimating()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
        self.workItem = workItem
    }
    
    private func startAnimating() {
        activityIndicatorView.startAnimating()
        isEnabled = !disableUserInteractionWhileLoading
        isUserInteractionEnabled = !disableUserInteractionWhileLoading
    }
    
    private func stopAnimating() {
        workItem?.cancel()
        workItem = nil
        activityIndicatorView.stopAnimating()
        isEnabled = true
        isUserInteractionEnabled = true
    }
}
