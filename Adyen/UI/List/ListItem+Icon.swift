//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

public struct Icon: Hashable {

    public enum Location: Hashable {
        case local(image: UIImage)
        case remote(url: URL?)
    }

    /// The location of the icon image
    public let location: Location
    /// Whether or not the icon should be styled/altered
    public let canBeModified: Bool

    /// Initializes the icon
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

    /// The url of the remote location if applicable
    internal var url: URL? {
        switch self.location {
        case .local: return nil
        case let .remote(url): return url
        }
    }

    /// Convenience init to instantiate an ``Icon`` with a remote ``URL``
    public init(
        url: URL?,
        canBeModified: Bool = true
    ) {
        self.init(
            location: .remote(url: url),
            canBeModified: canBeModified
        )
    }

    /// Convenience init to instantiate an ``Icon`` with a ``UIImage`` object
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
