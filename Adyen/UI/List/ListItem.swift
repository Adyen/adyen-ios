//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A selectable item displayed in the list.
@_spi(AdyenInternal)
public class ListItem: FormItem {
    
    public enum TrailingInfoType {
        case text(String)
        case logos(urls: [URL], trailingText: String?)
        
        internal var accessibilityLabel: String? {
            switch self {
            case let .text(text): return text
            case .logos: return nil
            }
        }
    }
    
    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)
    
    public var subitems: [FormItem] = []
    
    /// The list item style.
    public let style: ListItemStyle
    
    /// The title of the item.
    public var title: String
    
    /// The subtitle of the item.
    public var subtitle: String?
    
    /// The icon to display
    public var icon: Icon?

    /// The trailing text of the item.
    public var trailingInfo: TrailingInfoType?
    
    /// The handler to invoke when the item is selected.
    public var selectionHandler: (() -> Void)?
    
    /// The handler to invoke when the item is deleted.
    public var deletionHandler: ((IndexPath, @escaping Completion<Bool>) -> Void)?
    
    /// The `accessibilityIdentifier` to be used on the `ListItem`
    public var identifier: String?
    
    /// The `accessibilityLabel` to be used on the ``ListItem`` or ``ListCell``
    public let accessibilityLabel: String
    
    /// The closure for the ``ListViewController`` to assign, to listen to updates for its loading state
    ///
    /// See: ``ListItem/startLoading()`` & ``ListItem/stopLoading()``
    internal var loadingHandler: ((Bool, ListItem) -> Void)?
    
    /// Initializes the list item.
    ///
    /// - Parameters:
    ///   - title: The title of the item.
    ///   - subtitle: The subtitle of the item.
    ///   - icon: The icon of the item.
    ///   - trailingText: The trailing text.
    ///   - style: The list item style.
    ///   - identifier: The `accessibilityIdentifier` to be used on the `ListItem`
    ///   - selectionHandler: The closure to execute when an item is selected.
    ///   - accessibilityLabel: An optional custom `accessibilityLabel` to use. Defaults to title + subtitle + trailingText joined by a `, `
    public init(
        title: String,
        subtitle: String? = nil,
        icon: Icon? = nil,
        trailingInfo: TrailingInfoType? = nil,
        style: ListItemStyle = ListItemStyle(),
        identifier: String? = nil,
        accessibilityLabel: String? = nil,
        selectionHandler: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.trailingInfo = trailingInfo
        self.style = style
        self.identifier = identifier
        self.accessibilityLabel = accessibilityLabel ?? [
            title,
            subtitle,
            trailingInfo?.accessibilityLabel
        ].compactMap { $0 }.joined(separator: ", ")
        self.selectionHandler = selectionHandler
    }
    
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
    /// Indicate to the ``ListViewController`` to start loading / show the loading indicator for this specific item
    ///
    /// To stop the loading for the whole list either  call  ListViewController.``ListViewController/stopLoading()``
    /// or ListItem.``ListItem/stopLoading()``
    public func startLoading() {
        setLoading(true)
    }
    
    /// Indicate to the ``ListViewController`` to stop loading
    public func stopLoading() {
        setLoading(false)
    }
    
    private func setLoading(_ isLoading: Bool) {
        guard let loadingHandler else {
            AdyenAssertion.assertionFailure(message: "No loadingHandler provided")
            return
        }
        
        loadingHandler(isLoading, self)
    }

    // MARK: - Private
    
    private let listIdentifier: UUID = .init()
}

// MARK: - Hashable & Equatable

@_spi(AdyenInternal)
extension ListItem: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(listIdentifier)
    }
    
    public static func == (lhs: ListItem, rhs: ListItem) -> Bool {
        lhs.listIdentifier == rhs.listIdentifier
    }
}
