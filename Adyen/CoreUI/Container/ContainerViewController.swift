//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Provides a scroll view and a gray-white background for content view controllers such as forms.
internal class ContainerViewController: UIViewController {
    
    internal init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View
    
    internal var containerView: ContainerView {
        return view as! ContainerView // swiftlint:disable:this force_cast
    }
    
    override func loadView() {
        let containerView = ContainerView()
        containerView.contentView = contentView
        containerView.footerView = footerView
        view = containerView
    }
    
    // MARK: - Content View
    
    internal var contentView: UIView? {
        didSet {
            guard isViewLoaded else {
                return
            }
            
            containerView.contentView = contentView
        }
    }
    
    // MARK: - Footer View
    
    internal var footerView: UIView? {
        didSet {
            guard isViewLoaded else {
                return
            }
            
            containerView.footerView = footerView
        }
    }
    
}
