//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

extension FormPickerSearchViewController {
    
    package struct Style: ViewStyle {

        package var backgroundColor: UIColor = .Adyen.componentBackground
        package var emptyView: EmptyView.Style = .init()

        package init() {}
    }
}
