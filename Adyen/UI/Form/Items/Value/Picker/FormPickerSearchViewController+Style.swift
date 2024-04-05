//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

extension FormPickerSearchViewController {
    
    public struct Style: ViewStyle {
        
        public var backgroundColor: UIColor = .Adyen.componentBackground
        public var emptyView: EmptyView.Style = .init()
        
        public init() {}
    }
}
