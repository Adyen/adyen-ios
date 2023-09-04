//
//  ActionViewDelegateMock.swift
//  AdyenUIKitTests
//
//  Created by Eren Besel on 12/16/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@testable import Adyen
@testable import AdyenActions
import Foundation

final class ActionViewDelegateMock: ActionViewDelegate {
    var onDidComplete: (() -> Void)?
    
    func didComplete() {
        onDidComplete?()
    }
    
    var onMainButtonTap: ((UIView) -> Void)?

    func mainButtonTap(sourceView: UIView) {
        onMainButtonTap?(sourceView)
    }
}
