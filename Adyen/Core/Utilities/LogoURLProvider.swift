//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

internal struct LogoURLProvider {
    internal static func logoURL(for paymentMethod: PaymentMethod, selectItem: PaymentDetail.SelectItem? = nil, baseURL: URL) -> URL? {
        let componentsString = "\(baseURL.absoluteString)images/logos/"
        guard var components = URLComponents(string: componentsString) else {
            return nil
        }
        
        let pathComponents = ["small", paymentMethod.type, selectItem?.identifier].compactMap { $0 }
        components.path += pathComponents.joined(separator: "/") + LogoURLProvider.logoPathSuffix
        
        guard let url = components.url else {
            return nil
        }
        
        return url
    }
    
    private static var logoPathSuffix: String {
        let scale = Int(UIScreen.main.scale)
        if scale > 1 {
            return "@\(scale)x.png"
        }
        
        return ".png"
    }
    
}
