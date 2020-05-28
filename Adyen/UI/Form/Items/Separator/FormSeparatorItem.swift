//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A form item that represents a separator line.
/// :nodoc:
public final class FormSeparatorItem: FormItem {
    
    /// Indicates the line color.
    public let color: UIColor
    
    /// :nodoc:
    public var identifier: String?
    
    /// Initializes the separator item.
    ///
    /// - Parameter style: Any `ViewStyle` UI style.
    public init(color: UIColor) {
        self.color = color
    }
    
    /// :nodoc:
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}
