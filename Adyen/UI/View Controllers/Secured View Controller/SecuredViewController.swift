//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A View Controller wrapper to blur its content when going into the background.
/// Used to wrap view controllers that contain sensitive user info.
public final class SecuredViewController: UIViewController {
    
    /// :nodoc:
    override public var preferredContentSize: CGSize {
        
        get {
            childViewController.preferredContentSize
        }
        
        set {
            childViewController.preferredContentSize = newValue
        }
        
    }
    
    /// :nodoc:
    override public var title: String? {
        
        get {
            childViewController.title
        }
        
        set {
            childViewController.title = newValue
        }
        
    }
    
    /// Initializes the `SecuredViewController`.
    ///
    /// - Parameter child: The wrapped `UIViewController`.
    /// - Parameter style: The UI style.
    public init(child: UIViewController, style: ViewStyle) {
        self.childViewController = child
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    
    /// :nodoc:
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// :nodoc:
    deinit {
        backgroundObservers?.forEach { NotificationCenter.default.removeObserver($0) }
    }
    
    /// :nodoc:
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = style.backgroundColor
        
        addChildViewController()
        
        listenToBackgroundNotifications()
    }
    
    private let childViewController: UIViewController
    
    private let style: ViewStyle
    
    private var backgroundObservers: [Any]?
    
    private var blurConstraints: [NSLayoutConstraint]?
    
    @LazyOptional(initialize: UIVisualEffectView())
    private var blurEffectView: UIVisualEffectView
    
    private lazy var blurEffect: UIBlurEffect = {
        if #available(iOS 12.0, *) {
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIBlurEffect(style: .dark)
            case .light, .unspecified:
                return UIBlurEffect(style: .light)
            @unknown default:
                return UIBlurEffect(style: .light)
            }
        } else {
            return UIBlurEffect(style: .light)
        }
    }()
    
    private func addChildViewController() {
        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
        
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        childViewController.view.adyen.anchore(inside: view)
    }
    
    private func listenToBackgroundNotifications() {
        let toBackgroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification,
                                                                          object: nil,
                                                                          queue: OperationQueue.main) { [weak self] _ in
            self?.addBlur()
        }
        
        let backFromBackgroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                                                                object: nil,
                                                                                queue: OperationQueue.main) { [weak self] _ in
            self?.removeBlur()
        }
        
        backgroundObservers = [toBackgroundObserver, backFromBackgroundObserver]
    }
    
    private func addBlur() {
        view.addSubview(blurEffectView)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        let constraints = [
            blurEffectView.leftAnchor.constraint(equalTo: view.leftAnchor),
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.rightAnchor.constraint(equalTo: view.rightAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        blurConstraints = constraints
        
        NSLayoutConstraint.activate(constraints)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.blurEffectView.effect = self.blurEffect
        })
    }
    
    private func removeBlur() {
        UIView.animate(withDuration: 0.2, animations: {
            self.blurEffectView.effect = nil
        }, completion: { _ in
            if let blurConstraints = self.blurConstraints {
                NSLayoutConstraint.deactivate(blurConstraints)
            }
            self.blurEffectView.removeFromSuperview()
            self.$blurEffectView.reset()
            
            self.view.backgroundColor = self.style.backgroundColor
        })
    }
    
}
