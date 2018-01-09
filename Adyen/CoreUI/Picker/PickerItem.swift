//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A selectable item in a PickerViewController.
internal struct PickerItem {
    
    /// The title of the picker item.
    internal let title: String
    
    /// A URL to an image to optionally display in the picker item.
    internal let imageURL: URL?
    
}

// MARK: - Hashable & Equatable

extension PickerItem: Hashable {
    
    internal var hashValue: Int {
        return title.hashValue ^ (imageURL?.hashValue ?? 0)
    }
    
    internal static func ==(lhs: PickerItem, rhs: PickerItem) -> Bool {
        return lhs.title == rhs.title && lhs.imageURL == rhs.imageURL
    }
    
}

// MARK: - Helpers

extension PickerItem {
    
    /// Initializes the picker item with an input select item.
    ///
    /// - Parameter inputSelectItem: The input select item to initialize the picker item with.
    internal init(_ inputSelectItem: InputSelectItem) {
        title = inputSelectItem.name
        imageURL = inputSelectItem.imageURL
    }
    
}
