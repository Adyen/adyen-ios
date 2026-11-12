//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

package enum Dimensions {

    package static let leastPresentableScale: CGFloat = 0.25

    package static let greatestPresentableHeightScale: CGFloat = 0.9

    package static let maxAdaptiveWidth: CGFloat = 360

    @MainActor
    package static var greatestPresentableScale: CGFloat {
        UIDevice.current.userInterfaceIdiom == .phone && UIDevice.current.orientation.isLandscape ? 1 : greatestPresentableHeightScale
    }

    @MainActor
    package static func expectedWidth(for window: UIWindow? = nil) -> CGFloat {
        let containerSize = keyWindowSize(for: window)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return min(containerSize.width * (1 - leastPresentableScale), maxAdaptiveWidth * UIScreen.main.scale)
        } else {
            return containerSize.width
        }
    }

    @MainActor
    package static func keyWindowSize(for window: UIWindow? = nil) -> CGRect {
        guard let window = window ?? UIApplication.shared.adyen.mainKeyWindow else {
            return UIScreen.main.bounds
        }
        return window.bounds
    }

}
