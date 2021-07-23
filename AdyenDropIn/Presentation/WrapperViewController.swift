//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal final class WrapperViewController: UIViewController {

    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?
    private var leftConstraint: NSLayoutConstraint?

    internal lazy var requiresKeyboardInput: Bool = heirarchyRequiresKeyboardInput(viewController: child)

    internal let child: ModalViewController

    internal init(child: ModalViewController) {
        self.child = child
        super.init(nibName: nil, bundle: nil)

        positionContent(child)
    }

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

    internal func updateFrame(keyboardRect: CGRect) {
        guard let view = child.viewIfLoaded else { return }
        let finalFrame = child.finalPresentationFrame(with: keyboardRect)
        topConstraint?.constant = finalFrame.origin.y
        leftConstraint?.constant = finalFrame.origin.x
        rightConstraint?.constant = -finalFrame.origin.x
        view.layoutIfNeeded()
    }

    fileprivate func positionContent(_ child: ModalViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = child.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        let bottomConstraint = child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let leftConstraint = child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let rightConstraint = child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        NSLayoutConstraint.activate([
            leftConstraint,
            rightConstraint,
            bottomConstraint,
            topConstraint
        ])
        self.topConstraint = topConstraint
        self.bottomConstraint = bottomConstraint
        self.leftConstraint = leftConstraint
        self.rightConstraint = rightConstraint
    }

}

extension ModalViewController {

    /// Enables any `UIViewController` to recalculate it's conten's size form modal presentation ,
    /// e.g `viewController.adyen.finalPresentationFrame(in:keyboardRect:)`.
    /// :nodoc:
    internal func finalPresentationFrame(with keyboardRect: CGRect = .zero) -> CGRect {
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
