//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A View Controller wrapper to blur its content when going into the background.
/// Used to wrap view controllers that contain sensitive user info.
public final class SecuredViewController: UIViewController {
    
    private let notificationCenter = NotificationCenter.default
    
    private let childViewController: UIViewController
    
    private let style: ViewStyle

    private var blurConstraints: [NSLayoutConstraint]?

    private var backgroundObservers: [Any]?
    
    /// :nodoc:
    public weak var delegate: ViewControllerDelegate?
    
    /// :nodoc:
    override public var preferredContentSize: CGSize {
        get { childViewController.preferredContentSize }
        set { childViewController.preferredContentSize = newValue }
    }
    
    /// :nodoc:
    override public var title: String? {
        get { childViewController.title }
        set { childViewController.title = newValue }
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
        backgroundObservers?.forEach { notificationCenter.removeObserver($0) }
    }
    
    /// :nodoc:
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = style.backgroundColor
        
        addChildViewController()
        
        listenToBackgroundNotifications()
    }
    
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
        childViewController.view.adyen.anchor(inside: view)
    }
    
    private func listenToBackgroundNotifications() {
        var array = [Any]()
        array.append(notificationCenter.addObserver(forName: UIApplication.willResignActiveNotification,
                                                    object: nil,
                                                    queue: OperationQueue.main,
                                                    using: { [weak self] _ in self?.addBlur() }))
        array.append(notificationCenter.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                                    object: nil,
                                                    queue: OperationQueue.main,
                                                    using: { [weak self] _ in self?.removeBlur() }))
        backgroundObservers = array
    }
    
    private func addBlur() {
        view.addSubview(blurEffectView)
        view.backgroundColor = .clear
        
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurConstraints = blurEffectView.adyen.anchor(inside: view)
        
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.blurEffectView.effect = self?.blurEffect
        })
    }
    
    private func removeBlur() {
        UIView.animate(withDuration: 0.2,
                       animations: { [weak self] in self?.blurEffectView.effect = nil },
                       completion: { [weak self] _ in
                           if let blurConstraints = self?.blurConstraints {
                               NSLayoutConstraint.deactivate(blurConstraints)
                           }
                           self?.blurEffectView.removeFromSuperview()
                           self?.$blurEffectView.reset()
                        
                           self?.view.backgroundColor = self?.style.backgroundColor
                       })
    }
    
}
