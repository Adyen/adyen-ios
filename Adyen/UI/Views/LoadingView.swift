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
            return .large
        } else {
            return .whiteLarge
        }
    }

    private let contentView: UIView
    
    /// :nodoc:
    public var disableUserInteractionWhileLoading: Bool = false
    
    /// :nodoc:
    public var spinnerAppearanceDelay: DispatchTimeInterval = .seconds(1)

    /// :nodoc:
    public init(contentView: UIView) {
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
