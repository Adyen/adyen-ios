//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension UIScreen {
    
    class func retinaExtension() -> String {
        let scale = Int(main.nativeScale)
        
        switch scale {
        case 2:
            return "@2x"
        case 3:
            return "@3x"
        default:
            return ""
        }
    }
}
