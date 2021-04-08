//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// :nodoc:
internal final class WrapperViewController: UIViewController {

    /// :nodoc:
    internal lazy var requiresKeyboardInput: Bool = heirarchyRequiresKeyboardInput(viewController: child)

    internal let child: ModalViewController

    internal init(child: ModalViewController) {
        self.child = child
        super.init(nibName: nil, bundle: nil)

        positionContent(child)
    }

    /// :nodoc:
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func heirarchyRequiresKeyboardInput(viewController: UIViewController?) -> Bool {
        if let viewController = viewController as? FormViewController {
            return viewController.requiresKeyboardInput
        }

        return viewController?.children.contains(where: { heirarchyRequiresKeyboardInput(viewController: $0) }) ?? false
    }

    internal func updateFrame(keyboardRect: CGRect, animated: Bool) {
        guard let view = child.viewIfLoaded, let window = UIApplication.shared.keyWindow else { return }
        view.setNeedsLayout()
        let finalFrame = child.finalPresentationFrame(in: window, keyboardRect: keyboardRect)
        updateTopScrollViewInsets(keyboardHeight: keyboardRect.height,
                                  preferredContentSize: child.preferredContentSize,
                                  finalHeight: finalFrame.height)
        view.layer.removeAllAnimations()
        UIView.animate(withDuration: animated ? 0.35 : 0.0,
                       delay: 0.0,
                       options: [.curveLinear],
                       animations: { view.frame = finalFrame },
                       completion: nil)
    }

    private func updateTopScrollViewInsets(keyboardHeight: CGFloat,
                                           preferredContentSize: CGSize,
                                           finalHeight: CGFloat) {
        guard keyboardHeight > 0 else {
            topMostScrollView?.contentInset.bottom = 0
            return
        }
        let bottomScrollInset: CGFloat = preferredContentSize.height + keyboardHeight - finalHeight
        topMostScrollView?.contentInset.bottom = bottomScrollInset
    }

    private lazy var topMostScrollView: UIScrollView? = {
        guard let view = child.viewIfLoaded else { return nil }
        return view.adyen.getTopMostView()
    }()

    fileprivate func positionContent(_ child: ModalViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
}

extension ModalViewController {

    private var leastPresentableHeightScale: CGFloat { 0.3 }
    private var greatestPresentableHeightScale: CGFloat {
        UIApplication.shared.statusBarOrientation.isPortrait ? 0.9 : 1
    }

    /// Enables any `UIViewController` to recalculate it's conten's size form modal presentation ,
    /// e.g `viewController.adyen.finalPresentationFrame(in:keyboardRect:)`.
    /// :nodoc:
    func finalPresentationFrame(in containerView: UIView, keyboardRect: CGRect = .zero) -> CGRect {
        var frame = containerView.bounds
        let smallestHeightPossible = frame.height * leastPresentableHeightScale
        let biggestHeightPossible = frame.height * greatestPresentableHeightScale
        guard preferredContentSize != .zero else { return frame }

        let bottomPadding = max(abs(keyboardRect.height), containerView.safeAreaInsets.bottom)
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
