//
// Copyright (c) 2018 Oktawian Chojnacki
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

final class LoadingViewController: UIViewController {

    var didCancelClosure: (()-> Void)?

    internal init() {
        super.init(nibName: nil, bundle: nil)

        navigationItem.leftBarButtonItem = AppearanceConfiguration.shared.cancelButtonItem(target: self, selector: #selector(didSelect(cancelButtonItem:)))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .white)
        navigationItem.titleView = activity
        activity.startAnimating()
    }

    @objc private func didSelect(cancelButtonItem: Any) {
        didCancelClosure?()
    }
}
