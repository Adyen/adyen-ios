//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// Handles keyboard appearance/disappearance by adjusting scroll view content insets.
/// This provides a reusable way to keep scroll view content visible when the keyboard appears.
/// To check this behavior select a small device like a iPhone(SE) and load card component, or stored card component and see the cvv input screen with the keyboard visible,
/// you should be able to scroll to see the primary button.
package class KeyboardScrollViewHandler: AdyenObserver {

    // MARK: - Properties

    private weak var scrollView: UIScrollView?
    private weak var view: UIView?
    private let keyboardObserver = KeyboardObserver()
    private let animationKey: String

    // MARK: - Initializers

    package init(
        scrollView: UIScrollView,
        view: UIView,
        animationKey: String = "keyboardBottomInset"
    ) {
        self.scrollView = scrollView
        self.view = view
        self.animationKey = animationKey
    }

    package func startObserving() {
        observe(keyboardObserver.$keyboardTransition) { [weak self] in
            self?.handleKeyboardTransitionDidChange($0)
        }
    }

    // MARK: - Private Methods

    private func handleKeyboardTransitionDidChange(_ transition: KeyboardTransition) {
        let updateInsets: () -> Void = { [weak self] in
            guard let self, let scrollView = self.scrollView else { return }

            let bottomInset = self.keyboardOverlap(with: transition.keyboardRect)

            var contentInset = scrollView.contentInset
            contentInset.bottom = bottomInset
            scrollView.contentInset = contentInset

            var verticalInsets = scrollView.verticalScrollIndicatorInsets
            verticalInsets.bottom = bottomInset
            scrollView.verticalScrollIndicatorInsets = verticalInsets
        }

        guard let view, view.window != nil else {
            updateInsets()
            return
        }

        view.adyen.animate(context: AnimationContext(
            animationKey: animationKey,
            duration: transition.animationDuration,
            options: transition.animationOptions.union(.beginFromCurrentState),
            animations: updateInsets
        ))
    }

    private func keyboardOverlap(with keyboardRect: CGRect) -> CGFloat {
        guard let scrollView, let view, view.window != nil else {
            return keyboardRect.height
        }

        let scrollViewFrame = scrollView.convert(scrollView.bounds, to: nil)
        return scrollViewFrame.intersection(keyboardRect).height
    }
}
