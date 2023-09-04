//
//  VoucherViewDelegateMock.swift
//  Adyen
//
//  Created by Mohamed Eldoheiri on 6/3/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@testable import Adyen
@testable import AdyenActions
import Foundation

final class VoucherViewDelegateMock: VoucherViewDelegate {
    
    var onDidComplete: (() -> Void)?
    
    func didComplete() {
        onDidComplete?()
    }
    
    var onMainButtonTap: ((UIView) -> Void)?

    func mainButtonTap(sourceView: UIView) {
        onMainButtonTap?(sourceView)
    }
    
    var onAddToAppleWallet: (() -> Void)?
    
    func addToAppleWallet(completion: @escaping () -> Void) {
        onAddToAppleWallet?()
    }
    
    var onSecondaryButtonTap: ((UIView) -> Void)?
    
    func secondaryButtonTap(sourceView: UIView) {
        onSecondaryButtonTap?(sourceView)
    }
    
}
