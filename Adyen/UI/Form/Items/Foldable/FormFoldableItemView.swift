//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A view representing a split item.
internal final class FormFoldableItemView: FormItemView<FormFoldableItem>, Observer {

    private let view: AnyFormItemView

    /// Initializes the split item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormFoldableItem) {
        self.view = FormFoldableItemView.renderItem(item.item)
        super.init(item: item)

        addSubview(stackView)
        stackView.adyen.anchore(inside: self)
        observe(item.$isFolded) { [weak self] in self?.changeState($0) }
        changeState(item.isFolded)
    }

    override internal var childItemViews: [AnyFormItemView] { [view] }

    // MARK: - Layout

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: childItemViews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.preservesSuperviewLayoutMargins = true
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()

    private static func renderItem(_ item: FormItem) -> AnyFormItemView {
        let itemView = FormItemViewBuilder.renderItem(item)
        itemView.preservesSuperviewLayoutMargins = true
        return itemView
    }

    private func changeState(_ isFolded: Bool) {
        self.stackView.arrangedSubviews.forEach { $0.isHidden = isFolded }
    }

    override internal var intrinsicContentSize: CGSize { stackView.intrinsicContentSize }

}
