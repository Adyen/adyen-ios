//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// :nodoc:
/// Wrapps ModalViewController and manage it conten's updates and keyboard events
internal final class WrapperViewController: UIViewController, DynamicViewController {

    private var bottomConstraint: NSLayoutConstraint?

    internal lazy var requiresKeyboardInput: Bool = heirarchyRequiresKeyboardInput(viewController: child)

    internal let child: ModalViewController

    internal init(child: ModalViewController) {
        self.child = child
        super.init(nibName: nil, bundle: nil)

        positionContent(child)
        child.dynamicContentDelegate = self
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
        let frame = child.adyen.finalPresentationFrame(in: window, keyboardRect: keyboardRect)
        view.layer.removeAllAnimations()
        UIView.animate(withDuration: animated ? 0.35 : 0.0,
                       delay: 0.0,
                       options: [.curveLinear],
                       animations: { view.frame = frame },
                       completion: nil)
    }

    fileprivate func positionContent(_ child: ModalViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
}

extension WrapperViewController: DynamicViewControllerDelegate {

    /// :nodoc:
    public func viewDidChangeContentSize(viewController: UIViewController) {
        dynamicContentDelegate?.viewDidChangeContentSize(viewController: self)
    }

}
