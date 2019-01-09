//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/**
 *  This class is to serve as a navigation bar for view controllers in the checkout flow.
 *  It is to be added directly to the view by each view controller in the flow
 */
class CheckoutFlowNavigationBar: UIView {
    
    // MARK: - Object Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = Theme.secondaryColor
        
        titleLabel.textColor = UIColor.white
        titleLabel.frame = bounds
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textAlignment = .center
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleLabel.font = Theme.standardFontRegular
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch buttonType {
        case .none:
            break
        default:
            addSubview(leftBarButton)
            bringSubview(toFront: leftBarButton)
            leftBarButton.sizeToFit()
            let frame = CGRect(x: 20.0, y: 0.0, width: leftBarButton.bounds.width + 2 * 20.0, height: bounds.height)
            leftBarButton.frame = frame
        }
    }
    
    // MARK: - Public
    
    enum LeftBarButtonType {
        case none
        case back(target: Any, action: Selector)
        case dismiss(target: Any, action: Selector)
    }
    
    var buttonType: LeftBarButtonType = .none {
        didSet {
            switch buttonType {
            case .none:
                leftBarButton.removeFromSuperview()
            case let .back(target, action):
                let backImage = UIImage(named: "btn_back")
                leftBarButton.setImage(backImage, for: .normal)
                leftBarButton.addTarget(target, action: action, for: .touchUpInside)
                break
            case let .dismiss(target, action):
                let closeImage = UIImage(named: "btn_close")
                leftBarButton.setImage(closeImage, for: .normal)
                leftBarButton.addTarget(target, action: action, for: .touchUpInside)
            }
        }
    }
    
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue?.uppercased()
        }
    }
    
    static func bar(withTitle title: String) -> CheckoutFlowNavigationBar {
        let bar = CheckoutFlowNavigationBar(frame: CGRect(x: 0, y: 0, width: 0, height: 85.0))
        bar.autoresizingMask = .flexibleWidth
        bar.title = title
        return bar
    }
    
    // MARK: - Private
    
    private var titleLabel = UILabel(frame: .zero)
    private var leftBarButton: UIButton = UIButton(type: .custom)
    
}

class CheckoutFlowNavigationController: UINavigationController {
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setNavigationBarHidden(true, animated: false)
    }
    
}
