//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension DropInComponent {
    
    /// Indicates the UI configuration of the drop in components.
    public struct Style {
        
        /// Indicates any navigation style.
        public var navigation: NavigationStyle = NavigationStyle()
        
        /// Indicates the UI configuration of any list component.
        public var listComponent: ListComponentStyle = ListComponentStyle()
        
        /// Indicates any form component UI style.
        public var formComponent: FormComponentStyle = FormComponentStyle()
        
        /// Indicates any `RedirectComponent` UI style.
        public var redirectComponent: RedirectComponentStyle?
        
        /// Initializes the instance of DropIn style with the default values.
        public init() {}
    }
}
