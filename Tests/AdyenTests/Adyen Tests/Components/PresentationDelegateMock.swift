//
//  PresentationDelegateMock.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 8/11/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

import Adyen
import Foundation

final class PresentationDelegateMock: PresentationDelegate {

    var doPresent: ((_ component: PresentableComponent, _ disableCloseButton: Bool) -> Void)?

    func present(component: PresentableComponent, disableCloseButton: Bool) {
        doPresent?(component, disableCloseButton)
    }

}
