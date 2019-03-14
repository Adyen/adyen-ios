//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import SafariServices
import UIKit

internal struct RedirectPresenter {
    static func presentWebPage(with url: URL, from presenter: UIViewController, safariDelegate: SFSafariViewControllerDelegate) {
        let appearance = Appearance.shared
        
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.delegate = safariDelegate
        
        if #available(iOS 10, *) {
            safariViewController.preferredBarTintColor = appearance.safariViewControllerAttributes.barTintColor
            safariViewController.preferredControlTintColor = appearance.safariViewControllerAttributes.controlTintColor
        }
        
        safariViewController.modalPresentationStyle = .formSheet
        
        if #available(iOS 11, *) {
            safariViewController.dismissButtonStyle = .cancel
        }
        
        presenter.present(safariViewController, animated: true)
    }
    
    static func presentOpenAppErrorMessage(from presenter: UIViewController) {
        let alertTitle = ADYLocalizedString("redirect.cannotOpenApp.title")
        let alertMessage = ADYLocalizedString("redirect.cannotOpenApp.appNotInstalledMessage")
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: ADYLocalizedString("dismissButton"), style: .cancel))
        
        presenter.present(alertController, animated: true)
    }
    
    static func isAppURL(_ url: URL) -> Bool {
        let urlIsAppUrl = url.scheme != "http" && url.scheme != "https"
        return urlIsAppUrl
    }
    
    static func open(url: URL, from presenter: UIViewController, safariDelegate: SFSafariViewControllerDelegate, completion: @escaping ((Bool) -> Void)) {
        let urlIsAppUrl = RedirectPresenter.isAppURL(url)
        
        if #available(iOS 10.0, *) {
            let options: [UIApplication.OpenExternalURLOptionsKey: Any] = urlIsAppUrl ? [:] : [.universalLinksOnly: true]
            UIApplication.shared.open(url, options: options) { success in
                if !success {
                    if !urlIsAppUrl {
                        RedirectPresenter.presentWebPage(with: url, from: presenter, safariDelegate: safariDelegate)
                        completion(true)
                    } else {
                        RedirectPresenter.presentOpenAppErrorMessage(from: presenter)
                        completion(false)
                    }
                }
            }
        } else {
            RedirectPresenter.presentWebPage(with: url, from: presenter, safariDelegate: safariDelegate)
            completion(true)
        }
    }
    
}
