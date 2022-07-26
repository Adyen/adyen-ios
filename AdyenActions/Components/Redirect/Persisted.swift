//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@propertyWrapper
internal class Persisted<ValueType: Codable> {
    
    internal let defaultValue: ValueType

    internal let key: String
    
    internal init(defaultValue: ValueType, key: String) {
        self.defaultValue = defaultValue
        self.key = key
        if let value = wrappedValue as? AnyOptional, value.isNil {
            wrappedValue = defaultValue
        }
    }
    
    internal var wrappedValue: ValueType {
        get {
            guard let data = userDefaults.object(forKey: key) as? Data else { return defaultValue }
            let decoder = JSONDecoder()
            let value = try? decoder.decode(ValueType.self, from: data)
            return value ?? defaultValue
        }
        
        set {
            let encoder = JSONEncoder()
            if let optional = newValue as? AnyOptional, optional.isNil,
               let optionalDefaultValue = defaultValue as? AnyOptional, !optionalDefaultValue.isNil {

                let encodedValue = try? encoder.encode(defaultValue)
                userDefaults.setValue(encodedValue, forKey: key)

            } else if let optional = newValue as? AnyOptional, optional.isNil {

                userDefaults.removeObject(forKey: key)

            } else {

                let encodedValue = try? encoder.encode(newValue)
                userDefaults.setValue(encodedValue, forKey: key)
            }
        }
    }

    internal lazy var userDefaults: UserDefaults = {
        if NSClassFromString("XCTest") != nil {
            // Unit tests, use a separate `UserDefaults` instance.
            return UserDefaults(suiteName: "UnitTestsSuiteName")!
        } else {
            return UserDefaults.standard
        }
    }()
}

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}
