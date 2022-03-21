//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal final class ComponentNavigationController: UINavigationController {
    
    internal var cancelHandler: (Bool, PresentableComponent) -> Void
    
    internal init(rootComponent: PresentableComponent,
                  cancelHandler: @escaping (Bool, PresentableComponent) -> Void) {
        self.cancelHandler = cancelHandler
        self.components = [rootComponent]
        
        super.init(rootViewController: rootComponent.viewController)
    }
    
    @available(*, unavailable)
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override internal var preferredContentSize: CGSize {
        get {
            guard let innerController = topViewController,
                  innerController.isViewLoaded else { return .zero }
            let innerSize = innerController.preferredContentSize
            return CGSize(width: innerSize.width,
                          height: navigationBar.frame.size.height + innerSize.height)
        }
        
        // swiftlint:disable:next unused_setter_value
        set { AdyenAssertion.assertionFailure(message: """
        PreferredContentSize is overridden for this view controller.
        getter - returns combined size of an inner content and navigation bar.
        setter - no implemented.
        """)
        }
    }
    
    private var components: [PresentableComponent]
    
    internal func push(component: PresentableComponent, animated: Bool) {
        components.append(component)
        pushViewController(component.viewController, animated: animated)
    }
    
    internal func popComponent(animated: Bool) -> UIViewController? {
        popViewController(animated: animated)
    }
    
    override internal func popViewController(animated: Bool) -> UIViewController? {
        let currentComponent = components.removeLast()
        cancelHandler(components.isEmpty, currentComponent)
        return super.popViewController(animated: animated)
    }
    
    /// Enables any `UIViewController` to recalculate it's content's size form modal presentation ,
    /// e.g `viewController.adyen.finalPresentationFrame(in:keyboardRect:)`.
    /// :nodoc:
    internal func finalPresentationFrame(with keyboardRect: CGRect = .zero) -> CGRect {
        viewIfLoaded?.layoutIfNeeded()
        topViewController?.viewIfLoaded?.layoutIfNeeded()
        let expectedWidth = Dimensions.greatestPresentableWidth
        var frame = UIScreen.main.bounds
        frame.origin.x = (frame.width - expectedWidth) / 2
        frame.size.width = expectedWidth

        let smallestHeightPossible = frame.height * Dimensions.leastPresentableHeightScale
        let biggestHeightPossible = frame.height * Dimensions.greatestPresentableHeightScale
        guard preferredContentSize != .zero else { return frame }

        let bottomPadding = max(abs(keyboardRect.height), view.safeAreaInsets.bottom, 0)
        let expectedHeight = preferredContentSize.height + bottomPadding

        func calculateFrame(for expectedHeight: CGFloat) {
            frame.origin.y += frame.size.height - expectedHeight
            frame.size.height = expectedHeight
        }

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
