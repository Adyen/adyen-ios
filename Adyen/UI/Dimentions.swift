//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// :nodoc:
public enum Dimensions {

    /// :nodoc:
    public static var leastPresentableHeightScale: CGFloat = 0.25

    /// :nodoc:
    public static var maxAdaptiveWidth: CGFloat = 375

    /// :nodoc:
    public static var greatestPresentableHeightScale: CGFloat {
        UIDevice.current.userInterfaceIdiom == .phone && UIDevice.current.orientation.isLandscape ? 1 : 0.9
    }

    /// :nodoc:
    public static var greatestPresentableWidth: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return min(UIScreen.main.bounds.width * 0.85, maxAdaptiveWidth * UIScreen.main.scale)
        } else {
            return UIScreen.main.bounds.width
        }
    }

}
