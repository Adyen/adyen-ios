//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenSwiftUI
import SwiftUI

class TestPresentingViewModel: ObservableObject {
    @Published var viewController: UIViewController?
}

struct TestPresentingView: View {
    @ObservedObject var viewModel: TestPresentingViewModel

    var body: some View {
        Color.clear
            .present(viewController: $viewModel.viewController)
    }
}
