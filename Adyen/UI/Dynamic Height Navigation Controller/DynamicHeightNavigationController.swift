//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A UINavigationController subclass for presenting content with dynamic height.
internal class DynamicHeightNavigationController: UINavigationController {
    init() {
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationCapturesStatusBarAppearance = true
        delegate = self
        
        if shouldPresentAsFormSheet {
            modalPresentationStyle = .formSheet
        } else {
            transitioningDelegate = self
            modalPresentationStyle = .custom
            
            preferredContentSize = CGSize(width: view.bounds.width, height: 0.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard isFullScreen else {
            return presentingViewController?.preferredStatusBarStyle ?? .default
        }
        
        return Appearance.shared.preferredStatusBarStyle ?? .default
    }
    
    // MARK: - Private
    
    private var isFullScreen: Bool {
        return preferredContentSize == CGSize.zero
    }
    
    private var shouldPresentAsFormSheet: Bool {
        let size = UIApplication.shared.keyWindow?.bounds.size ?? .zero
        
        // The largest side length on an iPhone
        let minimumSideLengthForForPresentation: CGFloat = 414
        if size.width > minimumSideLengthForForPresentation && size.height > minimumSideLengthForForPresentation {
            return true
        }
        
        return false
    }
}

// MARK: - UINavigationControllerDelegate

extension DynamicHeightNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // This forces full-screen presentation.
        if viewController.preferredContentSize == CGSize.zero {
            preferredContentSize = viewController.preferredContentSize
            setNeedsStatusBarAppearanceUpdate()
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension DynamicHeightNavigationController: UIViewControllerTransitioningDelegate {
    internal func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DynamicHeightPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
