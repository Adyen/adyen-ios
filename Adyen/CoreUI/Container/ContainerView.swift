//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

internal class ContainerView: UIScrollView {
    
    internal init() {
        super.init(frame: .zero)
        
        backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
        
        addSubview(contentBackgroundView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func configureConstraints() {
        NSLayoutConstraint.deactivate(self.constraints)
        
        guard let contentView = contentView else {
            return
        }
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 20.0),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor),
            
            contentBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ]
        
        if let footerView = footerView {
            footerView.translatesAutoresizingMaskIntoConstraints = false
            
            let footerViewInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
            
            let footerViewConstraints = [
                footerView.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: footerViewInsets.top),
                footerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: footerViewInsets.left),
                footerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -footerViewInsets.right),
                footerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -footerViewInsets.bottom)
            ]
            
            constraints.append(contentsOf: footerViewConstraints)
        } else {
            constraints.append(contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 20.0))
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Content Background View
    
    private lazy var contentBackgroundView: ContainerContentBackgroundView = {
        let contentBackgroundView = ContainerContentBackgroundView()
        contentBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        return contentBackgroundView
    }()
    
    // MARK: - Content View
    
    internal var contentView: UIView? {
        willSet {
            contentView?.removeFromSuperview()
        }
        
        didSet {
            if let contentView = contentView {
                addSubview(contentView)
            }
            
            configureConstraints()
        }
    }
    
    // MARK: - Footer View
    
    internal var footerView: UIView? {
        willSet {
            footerView?.removeFromSuperview()
        }
        
        didSet {
            if let footerView = footerView {
                addSubview(footerView)
            }
            
            configureConstraints()
        }
    }
    
}

fileprivate class ContainerContentBackgroundView: UIView {
    
    override func draw(_ rect: CGRect) {
        // Draw background color.
        UIColor.white.setFill()
        UIRectFill(rect)
        
        let borderHeight = 1.0 / UIScreen.main.scale
        let borderColor = #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1)
        borderColor.setFill()
        
        // Draw top border.
        let topBorderRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: borderHeight)
        UIRectFill(topBorderRect)
        
        // Draw bottom border.
        let bottomBorderRect = CGRect(x: rect.minX, y: rect.maxY - borderHeight, width: rect.width, height: borderHeight)
        UIRectFill(bottomBorderRect)
    }
    
}
