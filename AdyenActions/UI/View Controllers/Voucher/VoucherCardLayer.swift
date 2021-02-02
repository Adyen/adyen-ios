//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal final class VoucherCardLayer: CAShapeLayer {

    private var cardCornerRadius: CGFloat = 12
    private var cutoutRadius: CGFloat = 6

    internal func drawCardCutOut(cutoutCenterY: CGFloat) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: cardCornerRadius))

        drawCardTop(path: path)

        drawCardRightSide(path: path, cutoutCenterY: cutoutCenterY)

        drawCardBottomSide(path: path)

        drawCardLeftSide(path: path, cutoutCenterY: cutoutCenterY)

        self.path = path.cgPath
    }

    private func drawCardTop(path: UIBezierPath) {
        // Top Left corner
        let topLeftCornerCenter = CGPoint(x: cardCornerRadius, y: cardCornerRadius)
        path.addArc(withCenter: topLeftCornerCenter,
                    radius: cardCornerRadius,
                    startAngle: .pi,
                    endAngle: (.pi * 3) / 2,
                    clockwise: true)
        // Top border
        path.addLine(to: CGPoint(x: bounds.width - cardCornerRadius, y: 0))

        // Top right corner
        let topRightCornerCenter = CGPoint(x: bounds.width - cardCornerRadius, y: cardCornerRadius)
        path.addArc(withCenter: topRightCornerCenter,
                    radius: cardCornerRadius,
                    startAngle: (.pi * 3) / 2,
                    endAngle: 0,
                    clockwise: true)
    }

    private func drawCardRightSide(path: UIBezierPath, cutoutCenterY: CGFloat) {
        // Right cutout
        let rightCutoutCenter = CGPoint(x: bounds.width, y: cutoutCenterY)
        path.addLine(to: CGPoint(x: rightCutoutCenter.x, y: rightCutoutCenter.y - cutoutRadius))
        path.addArc(withCenter: rightCutoutCenter, radius: cutoutRadius, startAngle: (.pi * 3) / 2, endAngle: .pi * 0.5, clockwise: false)
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height - cardCornerRadius))
    }

    private func drawCardBottomSide(path: UIBezierPath) {
        // Right Bottom corner
        let bottomRightCornerCenter = CGPoint(x: bounds.width - cardCornerRadius, y: bounds.height - cardCornerRadius)
        path.addArc(withCenter: bottomRightCornerCenter,
                    radius: cardCornerRadius,
                    startAngle: 0,
                    endAngle: .pi * 0.5,
                    clockwise: true)

        // Bottom border
        path.addLine(to: CGPoint(x: cardCornerRadius, y: bounds.height))

        // Bottom left corner
        let bottomLeftCornerCenter = CGPoint(x: cardCornerRadius, y: bounds.height - cardCornerRadius)
        path.addArc(withCenter: bottomLeftCornerCenter,
                    radius: cardCornerRadius,
                    startAngle: .pi * 0.5,
                    endAngle: .pi,
                    clockwise: true)
    }

    private func drawCardLeftSide(path: UIBezierPath, cutoutCenterY: CGFloat) {
        // Left cutout
        let leftCutoutCenter = CGPoint(x: 0, y: cutoutCenterY)
        path.addLine(to: CGPoint(x: leftCutoutCenter.x, y: leftCutoutCenter.y + cutoutRadius))
        path.addArc(withCenter: leftCutoutCenter, radius: cutoutRadius, startAngle: .pi * 0.5, endAngle: (.pi * 3) / 2, clockwise: false)
        path.close()
    }
}
