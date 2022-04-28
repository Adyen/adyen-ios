//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal final class WrapperViewController: UIViewController {

    // MARK: - Properties

    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?
    private var leftConstraint: NSLayoutConstraint?

    internal lazy var requiresKeyboardInput: Bool = hierarchyRequiresKeyboardInput(viewController: child)

    internal let child: ModalViewController

    // MARK: - Initializers

    internal init(child: ModalViewController) {
        self.child = child
        super.init(nibName: nil, bundle: Bundle(for: WrapperViewController.self))

        setupChildViewController()
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func updateFrame(keyboardRect: CGRect, animated: Bool = true) {
        guard let view = child.viewIfLoaded else { return }
        let finalFrame = child.finalPresentationFrame(with: keyboardRect)

        view.adyen.animate(context: SpringAnimationContext(animationKey: "Update frame",
                                                           duration: animated ? 0.3 : 0.0,
                                                           delay: 0,
                                                           dampingRatio: 0.8,
                                                           velocity: 0.2,
                                                           options: [.beginFromCurrentState, .curveEaseInOut],
                                                           animations: { [weak self] in
                                                               self?.update(finalFrame: finalFrame)
                                                           }))
    }

    // MARK: - Private

    private func setupChildViewController() {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
        setupChildLayout()
    }

    private func setupChildLayout() {
        let childView: UIView = child.view
        childView.translatesAutoresizingMaskIntoConstraints = false

        let topConstraint = childView.topAnchor.constraint(equalTo: view.topAnchor)
        let bottomConstraint = childView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let leftConstraint = childView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let rightConstraint = childView.trailingAnchor.constraint(equalTo: view.trailingAnchor)

        NSLayoutConstraint.activate([leftConstraint,
                                     rightConstraint,
                                     bottomConstraint,
                                     topConstraint])

        self.topConstraint = topConstraint
        self.bottomConstraint = bottomConstraint
        self.leftConstraint = leftConstraint
        self.rightConstraint = rightConstraint
    }

    private func hierarchyRequiresKeyboardInput(viewController: UIViewController?) -> Bool {
        if let viewController = viewController as? FormViewController {
            return viewController.requiresKeyboardInput
        }

        return viewController?.children.contains(where: { hierarchyRequiresKeyboardInput(viewController: $0) }) ?? false
    }
    
    private func update(finalFrame: CGRect) {
        guard let view = child.viewIfLoaded else { return }
        leftConstraint?.constant = finalFrame.origin.x
        rightConstraint?.constant = -finalFrame.origin.x
        topConstraint?.constant = finalFrame.origin.y
        view.layoutIfNeeded()
    }
}

extension ModalViewController {

    /// Enables any `UIViewController` to recalculate it's content's size form modal presentation ,
    /// e.g `viewController.adyen.finalPresentationFrame(in:keyboardRect:)`.
    /// :nodoc:
    internal func finalPresentationFrame(with keyboardRect: CGRect = .zero) -> CGRect {
        view.layer.layoutIfNeeded()
        let expectedWidth = Dimensions.greatestPresentableWidth
        var frame = UIScreen.main.bounds
        frame.origin.x = (frame.width - expectedWidth) / 2
        frame.size.width = expectedWidth

        let smallestHeightPossible = frame.height * Dimensions.leastPresentableHeightScale
        let biggestHeightPossible = frame.height * Dimensions.greatestPresentableHeightScale
        guard preferredContentSize != .zero else { return frame }

        let bottomPadding = max(abs(keyboardRect.height), view.safeAreaInsets.bottom)
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
