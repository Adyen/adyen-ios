//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import UIKit

/// Adds helper functionality to any `UIView` instance through the `adyen` property.
@_spi(AdyenInternal)
extension AdyenScope where Base: UIView {
    
    @discardableResult
    public func snapshot(forceRedraw: Bool = false) -> UIImage? {
        if forceRedraw {
            snapshot(forceRedraw: false)
        }

        // Ensure the view has a valid size
        let size = base.bounds.size
        guard size.width > 0, size.height > 0 else { return nil }

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { _ in
            base.drawHierarchy(in: base.bounds, afterScreenUpdates: true)
        }

        return image
    }
    
    public func hide(
        animationKey: String,
        hidden: Bool,
        animated: Bool
    ) {
        if animated {
            hideWithAnimation(
                animationKey: animationKey,
                hidden
            )
        } else {
            hideWithoutAnimation(hidden)
        }
    }

    private func hideWithAnimation(
        animationKey: String,
        _ hidden: Bool
    ) {
        // Set isHidden immediately for synchronous state updates (tests)
        base.isHidden = hidden
        
        let context = KeyFrameAnimationContext(
            animationKey: animationKey,
            duration: 0.35,
            delay: 0,
            options: [.calculationModeCubicPaced, .beginFromCurrentState],
            animations: { [weak base] in
                // Only animate alpha for visual transition
                base?.alpha = hidden ? 0 : 1
            },
            completion: { [weak base] _ in
                // Ensure final state is consistent
                base?.isHidden = hidden
                base?.alpha = hidden ? 0 : 1
            }
        )
        animate(context: context)
    }
    
    private func hideWithoutAnimation(_ hidden: Bool) {
        base.isHidden = hidden
        base.alpha = hidden ? 0 : 1
    }

    public var minimalSize: CGSize {
        let targetSize = CGSize(
            width: Dimensions.expectedWidth(for: base.window),
            height: UIView.layoutFittingCompressedSize.height
        )
        return base.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
}
