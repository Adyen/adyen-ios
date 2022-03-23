//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal final class ComponentNavigationController: UINavigationController {
    
    internal var cancelHandler: (Bool, PresentableComponent) -> Void
    
    private let style: NavigationStyle
    
    internal init(rootComponent: PresentableComponent,
                  style: NavigationStyle,
                  cancelHandler: @escaping (Bool, PresentableComponent) -> Void) {
        self.cancelHandler = cancelHandler
        self.components = [rootComponent]
        self.style = style
        
        super.init(rootViewController: rootComponent.viewController)
        setupNavigationBar(for: rootComponent.viewController)
    }
    
    @objc private func cancelTapped() {
        guard let rootComponent = components.first else { return }
        cancelHandler(true, rootComponent)
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
    
    internal func pushAsRoot(component: PresentableComponent, animated: Bool) {
        components = [component]
        component.viewController.navigationItem.hidesBackButton = true
        pushViewController(component.viewController, animated: animated)
        viewControllers = [component.viewController]
        setupNavigationBar(for: component.viewController)
    }
    
    private func setupNavigationBar(for viewController: UIViewController) {
        let button = createCancelButton()
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    private func createCancelButton() -> UIButton {
        let button: UIButton

        func legacy() -> UIButton {
            let button = UIButton(type: UIButton.ButtonType.system)
            let cancelText = Bundle(for: UIApplication.self).localizedString(forKey: "Cancel", value: nil, table: nil)
            button.setTitle(cancelText, for: .normal)
            button.setTitleColor(style.tintColor, for: .normal)
            return button
        }

        switch style.cancelButton {
        case .legacy:
            return legacy()
        case let .custom(image):
            button = UIButton(type: UIButton.ButtonType.custom)
            button.setImage(image, for: .normal)
        default:
            if #available(iOS 13.0, *) {
                button = UIButton(type: UIButton.ButtonType.close)
                button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
            } else {
                return legacy()
            }
        }

        return button
    }
    
    internal func popComponent(animated: Bool) -> UIViewController? {
        popViewController(animated: animated)
    }
    
    override internal func popViewController(animated: Bool) -> UIViewController? {
        let currentComponent = components.removeLast()
        cancelHandler(false, currentComponent)
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
