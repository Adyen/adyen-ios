//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A space form item in terms of number of layout margins.
/// :nodoc:
public final class FormSpacerItemView: FormItemView<FormSpacerItem> {

    /// Initializes the spacer item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormSpacerItem) {
        super.init(item: item)
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: 0)
        ])
    }

    // MARK: - Stack View

    private lazy var stackView: UIView = {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 0
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.preservesSuperviewLayoutMargins = true

        return stackView
    }()

    private lazy var arrangedSubviews: [UIView] = {

        func createView(_: Int) -> UIView {
            let view = UIView()
            view.heightAnchor
                .constraint(equalToConstant: 0)
                .adyen.with(priority: .defaultHigh)
                .isActive = true

            let containerView = UIView()
            containerView.addSubview(view)
            containerView.preservesSuperviewLayoutMargins = true
            containerView.translatesAutoresizingMaskIntoConstraints = false
            view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: containerView.layoutMarginsGuide.topAnchor, constant: 0),
                view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
                view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
                view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0)
            ])

            return containerView
        }

        return (0..<item.standardSpaceMultiplier).map(createView(_:))
    }()

}
