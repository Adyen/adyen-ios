//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

class JsonReader {
    class func read(file: String) -> [String: Any]? {
        do {
            if let file = Bundle(for: JsonReader.self).url(forResource: file, withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    return object
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
}
