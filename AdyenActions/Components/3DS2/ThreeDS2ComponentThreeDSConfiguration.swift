//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

internal extension ThreeDS2Component {
    struct ThreeDSConfiguration: Decodable, ThreeDSFeatureChecker {
        private let version: String
        internal let featureFlags: [String: Bool]?
        
        internal enum CodingKeys: String, CodingKey {
            case version
            case featureFlags
        }
        
        internal init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // We first check the version of the object and if it is an unrecognized version we bail out safely.
            self.version = try container.decode(String.self, forKey: .version)
            guard version == "1.0" else {
                self.featureFlags = nil
                return
            }
            self.featureFlags = try? container.decode(
                [String: Bool].self,
                forKey: .featureFlags
            )
        }
        
        internal func isFeatureEnabled(_ name: String) -> Bool {
            featureFlags?[name] ?? false
        }
    }
}
