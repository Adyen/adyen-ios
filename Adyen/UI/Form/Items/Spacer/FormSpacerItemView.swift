//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A space form item in terms of number of layout margins.
/// :nodoc:
public final class FormSpacerItemView: FormItemView<FormSpacerItem> {

    /// Initializes the spacer item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormSpacerItem) {
        super.init(item: item)
        addSubview(stackView)
        let constraints = [
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: 0)
        ]
        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Stack View

    private lazy var stackView: UIView = {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = self.layoutMargins.top
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.preservesSuperviewLayoutMargins = true

        return stackView
    }()

    private lazy var arrangedSubviews: [UIView] = {

        func createView(_ index: Int) -> UIView {
            let view = UIView()
            view.heightAnchor.constraint(equalToConstant: 0).isActive = true

            let containerView = UIView()
            containerView.addSubview(view)
            containerView.preservesSuperviewLayoutMargins = true
            containerView.translatesAutoresizingMaskIntoConstraints = false
            view.translatesAutoresizingMaskIntoConstraints = false

            let constraints = [
                view.topAnchor.constraint(equalTo: containerView.layoutMarginsGuide.topAnchor, constant: 0),
                view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
                view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
                view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0)
            ]
            NSLayoutConstraint.activate(constraints)

            return containerView
        }

        return (1...item.numberOfSpaces).map(createView(_:))
    }()

}
