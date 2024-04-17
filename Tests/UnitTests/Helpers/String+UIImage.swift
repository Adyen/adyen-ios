//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

extension String {

    func generateImage() -> UIImage? {
        let string = self as NSString
        let size = string.size()

        return UIGraphicsImageRenderer(size: size).image { context in
            UIColor.white.setFill()
            context.fill(.init(origin: .zero, size: size))

            string.draw(
                with: .init(origin: .zero, size: size),
                options: [.usesLineFragmentOrigin],
                context: nil
            )
        }
    }
}
