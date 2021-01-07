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

    /// :nodoc:
    internal let child: ModalViewController

    /// :nodoc:
    internal init(child: ModalViewController) {
        self.child = child
        super.init(nibName: nil, bundle: nil)
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
        UIView.animate(withDuration: animated ? 0.35 : 0.0, delay: 0.0, options: [.curveLinear], animations: {
            view.frame = frame
        }, completion: nil)
    }
}
