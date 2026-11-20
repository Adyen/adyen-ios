//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Adyen3DS2
import Foundation

@MainActor
internal protocol AnyADYService {
    func service(
        with parameters: ADYServiceParameters,
        appearanceConfiguration: ADYAppearanceConfiguration,
        completionHandler: @escaping @MainActor (_ service: AnyADYService) -> Void
    )

    func transaction(withMessageVersion: String) throws -> AnyADYTransaction
}

@MainActor
internal final class ADYServiceAdapter: NSObject, @MainActor AnyADYService {

    private var service: ADYService?

    internal func service(
        with parameters: ADYServiceParameters,
        appearanceConfiguration: ADYAppearanceConfiguration,
        completionHandler: @escaping @MainActor (AnyADYService) -> Void
    ) {
        ADYService.service(with: parameters, appearanceConfiguration: appearanceConfiguration) { [weak self] service in
            // The 3DS2 SDK delivers its callbacks on the main thread.
            guard let self else { return }
            let delivery = ServiceDelivery(service: service, completionHandler: completionHandler)
            self.performSelector(
                onMainThread: #selector(self.deliver(_:)),
                with: delivery,
                waitUntilDone: false
            )
        }
    }

    @objc private func deliver(_ delivery: ServiceDelivery) {
        self.service = delivery.service
        delivery.completionHandler(self)
    }

    internal func transaction(withMessageVersion: String) throws -> AnyADYTransaction {
        guard let service else {
            throw UnknownError.serviceIsNil
        }
        return try service.transaction(withMessageVersion: withMessageVersion)
    }

}

/// Carries the SDK service and completion across the `performSelector` hop,
/// whose `with:` parameter is not `Sendable`-checked.
private final class ServiceDelivery: NSObject {

    internal let service: ADYService
    internal let completionHandler: @MainActor (AnyADYService) -> Void

    internal init(service: ADYService, completionHandler: @escaping @MainActor (AnyADYService) -> Void) {
        self.service = service
        self.completionHandler = completionHandler
    }
}
