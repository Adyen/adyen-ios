//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

@_spi(AdyenInternal)
public enum Dimensions {

    public static var leastPresentableScale: CGFloat = 0.25

    public static var greatestPresentableHeightScale: CGFloat = 0.9

    public static var maxAdaptiveWidth: CGFloat = 360

    public static var greatestPresentableScale: CGFloat {
        UIDevice.current.userInterfaceIdiom == .phone && UIDevice.current.orientation.isLandscape ? 1 : greatestPresentableHeightScale
    }

    public static func expectedWidth(for window: UIWindow? = nil) -> CGFloat {
        let containerSize = keyWindowSize(for: window)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return min(containerSize.width * (1 - leastPresentableScale), maxAdaptiveWidth * UIScreen.main.scale)
        } else {
            return containerSize.width
        }
    }

    public static func keyWindowSize(for window: UIWindow? = nil) -> CGRect {
        guard let window = window ?? UIApplication.shared.adyen.mainKeyWindow else {
            return UIScreen.main.bounds
        }
        return window.bounds
    }

}
