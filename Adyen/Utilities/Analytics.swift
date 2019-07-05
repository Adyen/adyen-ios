//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public class Analytics {
    
    /// :nodoc:
    public enum Flavor: String {
        case components, dropin
    }
    
    /// :nodoc:
    public static var isEnabled = true
    
    /// :nodoc:
    public static func sendEvent(component: String, flavor: Flavor, environment: Environment) {
        guard isEnabled, let url = urlFor(component: component, flavor: flavor, environment: environment) else {
            return
        }
        
        urlSession.dataTask(with: url).resume()
    }
    
    // MARK: - Private
    
    private static let libraryVersion = Bundle(for: Analytics.self).infoDictionary?["CFBundleShortVersionString"] as? String
    private static let payloadVersion = "1"
    private static let platform = "ios"
    
    private static let localeIdentifier: String = {
        let languageCode = Locale.current.languageCode ?? ""
        let regionCode = Locale.current.regionCode ?? ""
        return "\(languageCode)_\(regionCode)"
    }()
    
    private static let urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }()
    
    private static let deviceModel: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }()
    
    private static func urlFor(component: String, flavor: Flavor, environment: Environment) -> URL? {
        var components = URLComponents(url: environment.baseURL, resolvingAgainstBaseURL: true)
        components?.path = "/checkoutshopper/images/analytics.png"
        
        components?.queryItems = [
            URLQueryItem(name: "version", value: libraryVersion),
            URLQueryItem(name: "payload_version", value: payloadVersion),
            URLQueryItem(name: "platform", value: platform),
            URLQueryItem(name: "locale", value: localeIdentifier),
            URLQueryItem(name: "component", value: component),
            URLQueryItem(name: "flavor", value: flavor.rawValue),
            URLQueryItem(name: "system_version", value: UIDevice.current.systemVersion),
            URLQueryItem(name: "device_model", value: deviceModel),
            URLQueryItem(name: "referer", value: Bundle.main.bundleIdentifier)
        ]
        
        return components?.url
    }
}
