//
//  VoucherViewDelegateMock.swift
//  Adyen
//
//  Created by Mohamed Eldoheiri on 6/3/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import Foundation
@testable import Adyen
@testable import AdyenActions

internal final class VoucherViewDelegateMock: VoucherViewDelegate {
    
    var onDidComplete: ((_ presentingViewController: UIViewController) -> Void)?
    
    func didComplete(presentingViewController: UIViewController) {
        onDidComplete?(presentingViewController)
    }
    
    var onSaveAsImage: ((_ voucherView: UIView, _ presentingViewController: UIViewController) -> Void)?
    
    func saveAsImage(voucherView: UIView, presentingViewController: UIViewController) {
        onSaveAsImage?(voucherView, presentingViewController)
    }
    
    var onDownload: ((_ url: URL, _ voucherView: UIView, _ presentingViewController: UIViewController) -> Void)?
    
    func download(url: URL, voucherView: UIView, presentingViewController: UIViewController) {
        onDownload?(url, voucherView, presentingViewController)
    }
    
    var onAddToAppleWallet: ((_ passToken: String, _ presentingViewController: UIViewController, _ completion: ((Bool) -> Void)?) -> Void)?
    
    func addToAppleWallet(passToken: String, presentingViewController: UIViewController, completion: ((Bool) -> Void)?) {
        onAddToAppleWallet?(passToken, presentingViewController, completion)
    }
    
    
}
