//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension UIViewController {
    
    private var leastPresentableHeightScale: CGFloat { 0.3 }
    private var greatestPresentableHeightScale: CGFloat {
        guard isViewLoaded else { return 1 }
        return view.bounds.height < view.bounds.width ? 1 : 0.9
    }
    
    internal func finalPresentationFrame(in containerView: UIView, keyboardRect: CGRect = .zero) -> CGRect {
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
        
        guard
            self.preferredContentSize != .zero
        else {
            return frame
        }
        
        let bottomPadding = max(keyboardRect.height, safeAreaInset.bottom)
        let expectedHeight = preferredContentSize.height + bottomPadding
        
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
