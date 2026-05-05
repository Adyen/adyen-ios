//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import UIKit

/// Adds helper functionality to any `UIView` instance through the `adyen` property.
extension AdyenScope where Base: UIView {
    
    @discardableResult
    package func snapshot(forceRedraw: Bool = false) -> UIImage? {
        if forceRedraw {
            snapshot(forceRedraw: false)
        }

        // Ensure the view has a valid size
        let size = base.bounds.size
        guard size.width > 0, size.height > 0 else { return nil }

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            base.drawHierarchy(in: base.bounds, afterScreenUpdates: true)
        }
    }
    
    package func hide(
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
        // Find the nearest UIStackView parent for proper layout animation
        let parentStackView = findParentStackView(from: base)

        // Force current layout state before animation starts
        parentStackView?.layoutIfNeeded()

        let context = KeyFrameAnimationContext(
            animationKey: animationKey,
            duration: 0.35,
            delay: 0,
            options: [.calculationModeCubicPaced, .beginFromCurrentState],
            animations: { [weak base, weak parentStackView] in
                // Set isHidden INSIDE animation block so stack view animates height
                base?.isHidden = hidden
                base?.alpha = hidden ? 0 : 1
                // Animate stack view layout for smooth height transition
                parentStackView?.layoutIfNeeded()
            },
            completion: { [weak base] _ in
                // Ensure final state is consistent
                base?.isHidden = hidden
                base?.alpha = hidden ? 0 : 1
            }
        )
        animate(context: context)
    }

    private func findParentStackView(from view: UIView) -> UIStackView? {
        var current: UIView? = view.superview
        while let parent = current {
            if let stackView = parent as? UIStackView {
                return stackView
            }
            current = parent.superview
        }
        return nil
    }

    private func hideWithoutAnimation(_ hidden: Bool) {
        base.isHidden = hidden
        base.alpha = hidden ? 0 : 1
    }

    package var minimalSize: CGSize {
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

    package func applyLayerBorderColor(
        _ color: UIColor?,
        on layer: CALayer? = nil,
        resolvingWith traitCollection: UITraitCollection? = nil
    ) {
        let targetLayer = layer ?? base.layer
        let resolvedTraitCollection = traitCollection ?? base.traitCollection
        targetLayer.borderColor = color?.resolvedColor(with: resolvedTraitCollection).cgColor
    }
}
