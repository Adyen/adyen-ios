//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Combine
import SwiftUI
import UIKit

@MainActor
internal struct StoredPaymentMethodManagementLogoView: View {

    @StateObject private var loader: StoredPaymentMethodManagementLogoLoader

    internal init(url: URL) {
        _loader = StateObject(wrappedValue: StoredPaymentMethodManagementLogoLoader(url: url))
    }

    internal var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Color.clear
            }
        }
        .onAppear(perform: loader.load)
    }
}

@MainActor
private final class StoredPaymentMethodManagementLogoLoader: ObservableObject {

    @Published private(set) var image: UIImage?

    private let url: URL
    private let imageLoader: ImageLoading
    private var loadingTask: AdyenCancellable?

    init(url: URL, imageLoader: ImageLoading = ImageLoaderProvider.imageLoader()) {
        self.url = url
        self.imageLoader = imageLoader
    }

    deinit {
        loadingTask?.cancel()
    }

    func load() {
        guard image == nil, loadingTask == nil else {
            return
        }

        loadingTask = imageLoader.load(url: url) { [weak self] image in
            self?.image = image
        }
    }
}
