//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public typealias SubmitHandler = @MainActor @Sendable (_ data: PaymentComponentData) async throws -> SubmitResult
public typealias AdditionalDetailsHandler = @MainActor @Sendable (_ data: ActionComponentData) async throws -> AdditionalDetailsResult
public typealias BeforeSubmitHandler = @MainActor @Sendable (_ data: BeforeSubmitData) async throws -> BeforeSubmitResult
public typealias CheckoutErrorHandler = @MainActor (_ error: CheckoutError) -> Void
public typealias CheckoutSuccessHandler = @MainActor (_ result: CheckoutResult) -> Void
