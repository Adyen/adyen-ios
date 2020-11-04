//
//  AnyRedirectComponentMock.swift
//  AdyenTests
//
//  Created by Mohamed Eldoheiri on 11/4/20.
//  Copyright © 2020 Adyen. All rights reserved.
//

import Foundation
@testable import AdyenCard

final class AnyRedirectComponentMock: AnyRedirectComponent {

    var delegate: ActionComponentDelegate?

    var onHandle: ((_ action: RedirectAction) -> Void)?

    func handle(_ action: RedirectAction) {
        onHandle?(action)
    }
}
