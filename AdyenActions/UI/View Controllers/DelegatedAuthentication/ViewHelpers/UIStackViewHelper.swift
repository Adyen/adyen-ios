//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
@_spi(AdyenInternal) import Adyen

extension UIStackView {
    convenience init(
        arrangedSubviews: [UIView],
        axis: NSLayoutConstraint.Axis = .vertical,
        distribution: UIStackView.Distribution = .fill,
        alignment: UIStackView.Alignment = .fill,
        spacing: CGFloat,
        view: UIView,
        withBackground: Bool = false
    ) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.axis = axis
        self.alignment = alignment
        self.spacing = spacing
        self.distribution = distribution
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if withBackground {
            let subView = UIView(frame: view.bounds)
            if #available(iOS 13.0, *) {
                subView.backgroundColor = UIColor.secondarySystemBackground
            }
            subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.insertSubview(subView, at: 0)
            subView.layer.cornerRadius = 10.0
            self.layer.cornerRadius = 10.0
            subView.layer.masksToBounds = true
            subView.clipsToBounds = true
        }
    }
}
