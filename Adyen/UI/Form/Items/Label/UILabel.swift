//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension UILabel: FormItem, AnyFormItemView {
    public var delegate: FormItemViewDelegate? {
        get {
            objc_getAssociatedObject(self, &UIViewAssociatedKeys.delegate) as? FormItemViewDelegate
        }
        set {
            objc_setAssociatedObject(self,
                                     &UIViewAssociatedKeys.delegate,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }

    public var childItemViews: [AnyFormItemView] { [] }

    public var identifier: String? {
        get {
            objc_getAssociatedObject(self, &UIViewAssociatedKeys.identifier) as? String
        }
        set {
            objc_setAssociatedObject(self,
                                     &UIViewAssociatedKeys.identifier,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        FormLabelItemView(item: self)
    }

}

private enum UIViewAssociatedKeys {
    internal static var identifier = "identifier"
    internal static var delegate = "delegate"
}
