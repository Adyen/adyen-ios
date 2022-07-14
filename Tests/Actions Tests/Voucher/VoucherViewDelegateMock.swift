//
//  VoucherViewDelegateMock.swift
//  Adyen
//
//  Created by Mohamed Eldoheiri on 6/3/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
import Foundation

internal final class VoucherViewDelegateMock: VoucherViewDelegate {
    
    var onDidComplete: (() -> Void)?
    
    func didComplete() {
        onDidComplete?()
    }
    
    var onMainButtonTap: ((UIView, VoucherAction) -> Void)?

    func mainButtonTap(sourceView: UIView, action: VoucherAction) {
        onMainButtonTap?(sourceView, action)
    }
    
    var onAddToAppleWallet: ((VoucherAction) -> Void)?
    
    func addToAppleWallet(action: VoucherAction, completion: @escaping () -> Void) {
        onAddToAppleWallet?(action)
    }
    
    var onSecondaryButtonTap: ((UIView, VoucherAction) -> Void)?
    
    func secondaryButtonTap(sourceView: UIView, action: VoucherAction) {
        onSecondaryButtonTap?(sourceView, action)
    }
    
}
