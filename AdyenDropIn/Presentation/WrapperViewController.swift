//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

final class WrapperViewController: UIViewController {

    // MARK: - Properties

    private var topConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?
    private var leftConstraint: NSLayoutConstraint?

    lazy var requiresKeyboardInput: Bool = hierarchyRequiresKeyboardInput(viewController: child)

    let child: ModalViewController

    // MARK: - Initializers

    init(child: ModalViewController) {
        self.child = child
        super.init(nibName: nil, bundle: Bundle(for: WrapperViewController.self))

        setupChildViewController()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateFrame(keyboardRect: CGRect, animated: Bool = true) {
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
    func finalPresentationFrame(with keyboardRect: CGRect = .zero) -> CGRect {
        view.layer.layoutIfNeeded()
        let frame = Dimensions.keyWindowSize(for: self.view.window)
        guard preferredContentSize != .zero else { return frame }

        let bottomPadding = max(abs(keyboardRect.height), view.safeAreaInsets.bottom)
        let contentHeight = preferredContentSize.height + bottomPadding
        
        let expectedHeight = expectedHeight(for: contentHeight, in: frame)
        let expectedWidth = Dimensions.expectedWidth(for: self.view.window)
        let expectedSize = CGSize(width: expectedWidth, height: expectedHeight)
        return calculateFrame(for: expectedSize, in: frame)
    }

    private func calculateFrame(for expectedSize: CGSize, in parent: CGRect) -> CGRect {
        var parent = parent
        parent.origin.y += parent.size.height - expectedSize.height
        parent.size.height = expectedSize.height
        parent.origin.x = (parent.width - expectedSize.width) / 2
        parent.size.width = expectedSize.width
        return parent
    }

    private func expectedHeight(for content: CGFloat, in parent: CGRect) -> CGFloat {
        let smallestPossibleHeight = parent.height * Dimensions.leastPresentableScale
        let biggestPossibleHeight = parent.height * Dimensions.greatestPresentableScale
        var expectedHeight = content
        expectedHeight = min(expectedHeight, biggestPossibleHeight)
        expectedHeight = max(expectedHeight, smallestPossibleHeight)
        return expectedHeight
    }

}
