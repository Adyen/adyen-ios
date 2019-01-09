//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class LoadingIndicatorView: UIView {
    
    // MARK: - UIView
    
    override var frame: CGRect {
        didSet {
            let expectedSize = CGSize(width: LoadingIndicatorView.sideLength, height: LoadingIndicatorView.sideLength)
            if expectedSize != frame.size {
                var staticSizeFrame = frame
                staticSizeFrame.size = expectedSize
                frame = staticSizeFrame
            }
        }
    }
    
    // MARK: - Public
    
    static func defaultLoadingIndicator() -> LoadingIndicatorView {
        let side = LoadingIndicatorView.sideLength
        let loading = LoadingIndicatorView(frame: CGRect(x: 0, y: 0, width: side, height: side))
        loading.backgroundColor = Theme.primaryColor
        loading.layer.cornerRadius = side / 2.0
        
        loading.imageView.frame = loading.bounds
        loading.imageView.contentMode = .center
        loading.addSubview(loading.imageView)
        
        return loading
    }
    
    func start() {
        shouldStopAnimating = false
        rotate()
    }
    
    func stop() {
        shouldStopAnimating = true
    }
    
    func markAsCompleted() {
        shouldStopAnimating = true
        shouldMarkAsCompleted = true
    }
    
    func markAsError() {
        shouldStopAnimating = true
        shouldMarkAsError = true
    }
    
    // MARK: - Private
    
    private static var sideLength: CGFloat = Theme.buttonHeight
    private var imageView = UIImageView(image: UIImage(named: "loading_indicator"))
    
    private var shouldStopAnimating = false
    private var shouldMarkAsCompleted = false
    private var shouldMarkAsError = false
    
    private func rotate() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: { () -> Void in
            self.imageView.transform = self.imageView.transform.rotated(by: CGFloat.pi / 2)
        }) { (finished) -> Void in
            if !self.shouldStopAnimating {
                self.rotate()
            } else if self.shouldMarkAsCompleted {
                self.imageView.transform = CGAffineTransform.identity
                self.imageView.image = UIImage(named: "checkmark")
            } else if self.shouldMarkAsError {
                self.imageView.transform = CGAffineTransform.identity
                self.imageView.image = UIImage(named: "error")?.withRenderingMode(.alwaysTemplate)
                self.imageView.tintColor = UIColor.white
                self.backgroundColor = Theme.errorColor
            }
        }
    }
    
}
