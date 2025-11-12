//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import Adyen

internal protocol DropInFlowManaging {
    func submit(_ data: PaymentComponentData, from component: PaymentComponent)
    func fail(with error: Error, from component: PaymentComponent)
    func provide(_ data: ActionComponentData, from component: ActionComponent)
    func complete(from component: ActionComponent)
    func fail(with error: Error, from component: ActionComponent)
    func openExternalApplication(component: ActionComponent)
    func fail(with error: Error)
    func cancel(component: PaymentComponent)
}

internal class DropInFlowManager: DropInFlowManaging {

    // MARK: - Properties

    private weak var dropInComponent: DropInComponent?
    private weak var dropInComponentDelegate: DropInComponentDelegate?

    // MARK: - Initializers

    internal init(
        dropInComponent: DropInComponent,
        dropInComponentDelegate: DropInComponentDelegate
    ) {
        self.dropInComponent = dropInComponent
        self.dropInComponentDelegate = dropInComponentDelegate
    }

    // MARK: - DropInFlowManaging

    func submit(_ data: PaymentComponentData, from component: PaymentComponent) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didSubmit(data, from: component, in: dropInComponent)
    }

    func fail(with error: Error, from component: PaymentComponent) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didFail(with: error, from: component, in: dropInComponent)
    }

    func provide(_ data: ActionComponentData, from component: ActionComponent) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didProvide(data, from: component, in: dropInComponent)
    }

    func complete(from component: ActionComponent) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didComplete(from: component, in: dropInComponent)
    }

    func fail(with error: Error, from component: ActionComponent) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didFail(with: error, from: component, in: dropInComponent)
    }

    func openExternalApplication(component: ActionComponent) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didOpenExternalApplication(component: component, in: dropInComponent)
    }

    func fail(with error: Error) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didFail(with: error, from: dropInComponent)
    }

    func cancel(component: PaymentComponent) {
        guard let dropInComponent else { return }
        dropInComponentDelegate?.didCancel(component: component, from: dropInComponent)
    }
}
