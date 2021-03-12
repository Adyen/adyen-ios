//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// :nodoc:
extension UIViewController: AdyenCompatible {}

/// Adds helper functionality to any `UIViewController` instance through the `adyen` property.
/// :nodoc:
public extension AdyenScope where Base: UIViewController {
    
    /// Enables any `UIViewController` to access its top most presented view controller, e.g `viewController.adyen.topPresenter`.
    /// :nodoc:
    var topPresenter: UIViewController {
        var topController: UIViewController = self.base
        while let presenter = topController.presentedViewController {
            topController = presenter
        }
        return topController
    }
    
    private var leastPresentableHeightScale: CGFloat { 0.3 }
    private var greatestPresentableHeightScale: CGFloat {
        guard base.isViewLoaded else { return 1 }
        return base.view.bounds.height < base.view.bounds.width ? 1 : 0.9
    }
    
    /// Enables any `UIViewController` to recalculate it's conten's size form modal presentation ,
    /// e.g `viewController.adyen.finalPresentationFrame(in:keyboardRect:)`.
    /// :nodoc:
    func finalPresentationFrame(in containerView: UIView, keyboardRect: CGRect = .zero) -> CGRect {
        var frame = containerView.bounds
        let smallestHeightPossible = frame.height * leastPresentableHeightScale
        let biggestHeightPossible = frame.height * greatestPresentableHeightScale
        
        var safeAreaInset: UIEdgeInsets = .zero
        if #available(iOS 11.0, *) {
            safeAreaInset = containerView.safeAreaInsets
        }
        
        func calculateFrame(for expectedHeight: CGFloat) {
            frame.origin.y += frame.size.height - expectedHeight
            frame.size.height = expectedHeight
        }
        
        guard base.preferredContentSize != .zero else { return frame }
        
        let bottomPadding = max(keyboardRect.height, safeAreaInset.bottom)
        let expectedHeight = base.preferredContentSize.height + bottomPadding
        
        switch expectedHeight {
        case let height where height < smallestHeightPossible:
            calculateFrame(for: smallestHeightPossible)
        case let height where height > biggestHeightPossible:
            calculateFrame(for: biggestHeightPossible)
        default:
            calculateFrame(for: expectedHeight)
        }
        
        return frame
    }
    
}
