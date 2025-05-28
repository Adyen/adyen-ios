//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

internal protocol PreselectedPaymentMethodViewModelProtocol {

}

internal class PreselectedPaymentMethodViewModel: PreselectedPaymentMethodViewModelProtocol {

    // MARK: - Properties

    private let preselectedPaymentMethodComponent: PreselectedPaymentMethodComponent

    // MARK: - Initializers

    internal init(
        component: PaymentComponent,
        title: String,
        style: FormComponentStyle,
        listItemStyle: ListItemStyle
    ) {
        self.preselectedPaymentMethodComponent = PreselectedPaymentMethodComponent(
            component: component,
            title: title,
            style: style,
            listItemStyle: listItemStyle
        )
    }

    // MARK: - PreselectedPaymentMethodViewModelProtocol

    // MARK: - Private

}

internal class PreselectedPaymentMethodViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: PreselectedPaymentMethodViewModelProtocol

    // MARK: - Initalizers

    internal init(viewModel: PreselectedPaymentMethodViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle

    // MARK: - Public

    // MARK: - Private
}
