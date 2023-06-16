//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A selectable item displayed in the list.
@_spi(AdyenInternal)
public class ListItem: FormItem {

    public enum IconMode {
        /// Icon is hidden
        case none
        /// Custom image that should not be styled/altered e.g. Apple Pay
        case custom
        /// Standard icon that can be styled
        case generic
        
        /// Whether or not the icon should be hidden
        public var isHidden: Bool {
            switch self {
            case .custom: return false
            case .generic: return false
            case .none: return true
            }
        }
        
        /// Whether or not the icon should be styled/altered
        public var canBeModified: Bool {
            switch self {
            case .custom: return false
            case .generic: return true
            case .none: return false
            }
        }
    }
    
    public var subitems: [FormItem] = []
    
    /// The list item style.
    public let style: ListItemStyle
    
    /// The title of the item.
    public var title: String
    
    /// The subtitle of the item.
    public var subtitle: String?
    
    /// A URL to an image to display.
    public var imageURL: URL?

    /// The trailing text of the item.
    public var trailingText: String?
    
    /// The handler to invoke when the item is selected.
    public var selectionHandler: (() -> Void)?
    
    /// The handler to invoke when the item is deleted.
    public var deletionHandler: ((IndexPath, @escaping Completion<Bool>) -> Void)?
    
    /// An identifier for the `ListItem`,
    /// that is set to the `ListItemView.accessibilityIdentifier`.
    public var identifier: String?

    /// Specifies the icon behavior
    public let iconMode: IconMode
    
    /// Initializes the list item.
    ///
    /// - Parameters:
    ///   - title: The title of the item.
    ///   - subtitle: The subtitle of the item.
    ///   - imageURL: A URL to an image to display.
    ///   - trailingText: The trailing text.
    ///   - style: The list item style.
    ///   - selectionHandler: The closure to execute when an item is selected.
    ///   - iconMode: Specifies the icon behavior
    public init(
        title: String,
        subtitle: String? = nil,
        imageURL: URL? = nil,
        trailingText: String? = nil,
        style: ListItemStyle = ListItemStyle(),
        selectionHandler: (() -> Void)? = nil,
        iconMode: IconMode = .generic
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.trailingText = trailingText
        self.style = style
        self.selectionHandler = selectionHandler
        self.iconMode = iconMode
    }
    
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}

// MARK: - Deprecated

extension ListItem {
    
    /// The flag to indicate if an icon is a custom image that should not be tempered.
    @available(*, deprecated, message: "Use `iconMode.canBeModified` property if needed.")
    public var canModifyIcon: Bool {
        iconMode.canBeModified
    }
    
    /// Initializes the list item.
    ///
    /// - Parameters:
    ///   - title: The title of the item.
    ///   - subtitle: The subtitle of the item.
    ///   - imageURL: A URL to an image to display.
    ///   - trailingText: The trailing text.
    ///   - style: The list item style.
    ///   - selectionHandler: The closure to execute when an item is selected.
    ///   - canModifyIcon: The flag to indicate that image could be tampered.
    @available(*, deprecated, message: "Use the initializer that takes an iconMode instead.")
    public convenience init(
        title: String,
        subtitle: String? = nil,
        imageURL: URL? = nil,
        trailingText: String? = nil,
        style: ListItemStyle = ListItemStyle(),
        selectionHandler: (() -> Void)? = nil,
        canModifyIcon: Bool
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            imageURL: imageURL,
            trailingText: trailingText,
            style: style,
            selectionHandler: selectionHandler,
            iconMode: canModifyIcon ? .generic : .custom
        )
    }
}

// MARK: - Hashable & Equatable

@_spi(AdyenInternal)
extension ListItem: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(imageURL)
        hasher.combine(trailingText)
    }
    
    public static func == (lhs: ListItem, rhs: ListItem) -> Bool {
        lhs.title == rhs.title && lhs.imageURL == rhs.imageURL && lhs.trailingText == rhs.trailingText
    }
    
}
