//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

extension ListItem {
    
    public struct Icon: Hashable {
        
        public enum Location: Hashable {
            case local(image: UIImage)
            case remote(url: URL?)
        }
        
        /// The location of the icon image
        public let location: Location
        /// Whether or not the icon should be styled/altered
        public let canBeModified: Bool
        
        /// Initializes the icon of the `ListItem`
        ///
        /// - Parameters:
        ///   - location: The location of the icon image
        ///   - canBeModified: Whether or not the icon should be styled/altered
        public init(
            location: Location,
            canBeModified: Bool = true
        ) {
            self.location = location
            self.canBeModified = canBeModified
        }
    }
}

// MARK: - Convenience

extension ListItem.Icon {
    
    /// The url of the remote location if applicable
    var url: URL? {
        switch self.location {
        case .local: return nil
        case let .remote(url): return url
        }
    }
    
    /// Convenience init to instantiate an ``ListItem.Icon`` with a remote ``URL``
    public init(
        url: URL?,
        canBeModified: Bool = true
    ) {
        self.init(
            location: .remote(url: url),
            canBeModified: canBeModified
        )
    }
    
    /// Convenience init to instantiate an ``ListItem.Icon`` with a ``UIImage`` object
    public init(
        image: UIImage,
        canBeModified: Bool = true
    ) {
        self.init(
            location: .local(image: image),
            canBeModified: canBeModified
        )
    }
}
