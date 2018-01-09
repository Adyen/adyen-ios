//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

class JsonReader {
    class func readData(fileName: String) -> Data {
        guard let url = Bundle(for: JsonReader.self).url(forResource: fileName, withExtension: "json") else {
            fatalError("Could not find file named '\(fileName)'")
        }
        
        do {
            return try Data(contentsOf: url)
        } catch {
            fatalError("Failed to read file named '\(fileName)' (error: \(error))")
        }
    }
    
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
