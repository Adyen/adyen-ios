//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An object representing a selectable item used in `InputDetail` with `select` type.
public final class InputSelectItem {
    
    // MARK: - Initializing
    
    init(identifier: String, name: String, imageURL: URL? = nil) {
        self.identifier = identifier
        self.name = name
        self.imageURL = imageURL
    }
    
    convenience init?(info: [String: Any]) {
        guard
            let identifier = info["id"] as? String,
            let name = info["name"] as? String
        else {
            return nil
        }
        
        let imageURL = (info["imageUrl"] as? String).flatMap { URL(string: $0) }
        
        //  Fix retina extension
        var editedUrl: URL?
        let retinaExt = UIScreen.retinaExtension()
        if let url = imageURL {
            let string = url.absoluteString
            let newString = string.replacingOccurrences(of: ".png", with: retinaExt + ".png")
            editedUrl = URL(string: newString)
        }
        
        self.init(identifier: identifier, name: name, imageURL: editedUrl)
    }
    
    // MARK: - Accessing Identifying Info
    
    /// Identifier of an item. Upon selection, the value of this property should be assigned to the `value` property of the `InputDetail` object.
    public let identifier: String
    
    // MARK: - Accessing Display Info
    
    /// Display name of an item.
    public let name: String
    
    /// Optional URL for the icon of an item.
    public let imageURL: URL?
}
