//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

@testable import Adyen
@testable import AdyenCard
@testable import AdyenCheckout
@testable import AdyenDropIn
@testable import AdyenUI

public class AnyEventAnalyticsProviderMock: AnyEventAnalyticsProvider {

    public init() {}

    public var checkoutAttemptId: String?

    // MARK: - add

    public var addInfoCallsCount = 0
    public var addInfoCalled: Bool {
        addInfoCallsCount > 0
    }

    public var addInfoReceivedInfo: AnalyticsEventInfo?
    public var addInfoReceivedInvocations: [AnalyticsEventInfo] = []
    public var addInfoClosure: ((AnalyticsEventInfo) -> Void)?

    public func add(info: AnalyticsEventInfo) {
        addInfoCallsCount += 1
        addInfoReceivedInfo = info
        addInfoReceivedInvocations.append(info)
        addInfoClosure?(info)
    }

    // MARK: - add

    public var addLogCallsCount = 0
    public var addLogCalled: Bool {
        addLogCallsCount > 0
    }

    public var addLogReceivedLog: AnalyticsEventLog?
    public var addLogReceivedInvocations: [AnalyticsEventLog] = []
    public var addLogClosure: ((AnalyticsEventLog) -> Void)?

    public func add(log: AnalyticsEventLog) {
        addLogCallsCount += 1
        addLogReceivedLog = log
        addLogReceivedInvocations.append(log)
        addLogClosure?(log)
    }

    // MARK: - add

    public var addErrorCallsCount = 0
    public var addErrorCalled: Bool {
        addErrorCallsCount > 0
    }

    public var addErrorReceivedError: AnalyticsEventError?
    public var addErrorReceivedInvocations: [AnalyticsEventError] = []
    public var addErrorClosure: ((AnalyticsEventError) -> Void)?

    public func add(error: AnalyticsEventError) {
        addErrorCallsCount += 1
        addErrorReceivedError = error
        addErrorReceivedInvocations.append(error)
        addErrorClosure?(error)
    }

}

class StoredCardInputViewModelProtocolMock: StoredCardInputViewModelProtocol {

    var cardImageItem: CardImageItem {
        get { underlyingCardImageItem }
        set(value) { underlyingCardImageItem = value }
    }

    var underlyingCardImageItem: CardImageItem!
    var titleText: String {
        get { underlyingTitleText }
        set(value) { underlyingTitleText = value }
    }

    var underlyingTitleText: String!
    var subtitleText: NSAttributedString {
        get { underlyingSubtitleText }
        set(value) { underlyingSubtitleText = value }
    }

    var underlyingSubtitleText: NSAttributedString!
    var securityCodeItem: FormCardSecurityCodeItem {
        get { underlyingSecurityCodeItem }
        set(value) { underlyingSecurityCodeItem = value }
    }

    var underlyingSecurityCodeItem: FormCardSecurityCodeItem!
    var submitButtonTitle: String {
        get { underlyingSubmitButtonTitle }
        set(value) { underlyingSubmitButtonTitle = value }
    }

    var underlyingSubmitButtonTitle: String!
    var theme: CheckoutTheme {
        get { underlyingTheme }
        set(value) { underlyingTheme = value }
    }

    var underlyingTheme: CheckoutTheme!
    var onSecurityCodeValidationRequested: VoidCompletion?
    var inProgressPublisher: Published<Bool>.Publisher {
        get { underlyingInProgressPublisher }
        set(value) { underlyingInProgressPublisher = value }
    }

    var underlyingInProgressPublisher: Published<Bool>.Publisher!

    // MARK: - submit

    var submitCallsCount = 0
    var submitCalled: Bool {
        submitCallsCount > 0
    }

    var submitClosure: (() async -> Void)?

    @MainActor
    func submit() async {
        submitCallsCount += 1
        await submitClosure?()
    }

    // MARK: - dismiss

    var dismissCallsCount = 0
    var dismissCalled: Bool {
        dismissCallsCount > 0
    }

    var dismissClosure: (() -> Void)?

    @MainActor
    func dismiss() {
        dismissCallsCount += 1
        dismissClosure?()
    }

    // MARK: - viewDidLoad

    var viewDidLoadCallsCount = 0
    var viewDidLoadCalled: Bool {
        viewDidLoadCallsCount > 0
    }

    var viewDidLoadClosure: (() -> Void)?

    func viewDidLoad() {
        viewDidLoadCallsCount += 1
        viewDidLoadClosure?()
    }

}
