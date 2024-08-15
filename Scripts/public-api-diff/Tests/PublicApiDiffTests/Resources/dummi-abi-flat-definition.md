```javascript
// Parent: Root
import AdyenNetworking
```
```javascript
// Parent: Root
import Contacts
```
```javascript
// Parent: Root
import Darwin
```
```javascript
// Parent: Root
import DeveloperToolsSupport
```
```javascript
// Parent: Root
import Foundation
```
```javascript
// Parent: Root
import Foundation
```
```javascript
// Parent: Root
import Foundation
```
```javascript
// Parent: Root
import Foundation
```
```javascript
// Parent: Root
import PassKit
```
```javascript
// Parent: Root
import QuartzCore
```
```javascript
// Parent: Root
import SwiftOnoneSupport
```
```javascript
// Parent: Root
import SwiftUI
```
```javascript
// Parent: Root
import UIKit
```
```javascript
// Parent: Root
import WebKit
```
```javascript
// Parent: Root
import _Concurrency
```
```javascript
// Parent: Root
import _StringProcessing
```
```javascript
// Parent: Root
import _SwiftConcurrencyShims
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum AnalyticsFlavor
```
```javascript
// Parent: AnalyticsFlavor
@_spi(AdyenInternal) public case components(type: Adyen.PaymentMethodType)
```
```javascript
// Parent: AnalyticsFlavor
@_spi(AdyenInternal) public case dropIn(type: Swift.String, paymentMethods: [Swift.String])
```
```javascript
// Parent: AnalyticsFlavor
@_spi(AdyenInternal) public var value: Swift.String { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol AnalyticsProviderProtocol
```
```javascript
// Parent: AnalyticsProviderProtocol
@_spi(AdyenInternal) public var checkoutAttemptId: Swift.String? { get }
```
```javascript
// Parent: AnalyticsProviderProtocol
@_spi(AdyenInternal) public func sendInitialAnalytics<Self where Self : Adyen.AnalyticsProviderProtocol>(with: Adyen.AnalyticsFlavor, additionalFields: Adyen.AdditionalAnalyticsFields?) -> Swift.Void
```
```javascript
// Parent: AnalyticsProviderProtocol
@_spi(AdyenInternal) public func add<Self where Self : Adyen.AnalyticsProviderProtocol>(info: Adyen.AnalyticsEventInfo) -> Swift.Void
```
```javascript
// Parent: AnalyticsProviderProtocol
@_spi(AdyenInternal) public func add<Self where Self : Adyen.AnalyticsProviderProtocol>(log: Adyen.AnalyticsEventLog) -> Swift.Void
```
```javascript
// Parent: AnalyticsProviderProtocol
@_spi(AdyenInternal) public func add<Self where Self : Adyen.AnalyticsProviderProtocol>(error: Adyen.AnalyticsEventError) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class AnalyticsForSession
```
```javascript
// Parent: AnalyticsForSession
@_spi(AdyenInternal) public static var sessionId: Swift.String? { get set }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol AnalyticsEvent<Self : Swift.Encodable> : Encodable
```
```javascript
// Parent: AnalyticsEvent
@_spi(AdyenInternal) public var timestamp: Swift.Int { get }
```
```javascript
// Parent: AnalyticsEvent
@_spi(AdyenInternal) public var component: Swift.String { get }
```
```javascript
// Parent: AnalyticsEvent
@_spi(AdyenInternal) public var id: Swift.String { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum AnalyticsEventTarget : Encodable, Equatable, Hashable, RawRepresentable
```
```javascript
// Parent: AnalyticsEventTarget
@_spi(AdyenInternal) public case cardNumber
```
```javascript
// Parent: AnalyticsEventTarget
@_spi(AdyenInternal) public case expiryDate
```
```javascript
// Parent: AnalyticsEventTarget
@_spi(AdyenInternal) public case securityCode
```
```javascript
// Parent: AnalyticsEventTarget
@_spi(AdyenInternal) public case holderName
```
```javascript
// Parent: AnalyticsEventTarget
@_spi(AdyenInternal) public case dualBrand
```
```javascript
// Parent: AnalyticsEventTarget
@_spi(AdyenInternal) public case boletoSocialSecurityNumber
```
```javascript
// Parent: AnalyticsEventTarget
@_spi(AdyenInternal) public case taxNumber
```
```javascript
// Parent: AnalyticsEventTarget
@_spi(AdyenInternal) public case authPassWord
```
```javascript
// Parent: AnalyticsEventTarget
@_spi(AdyenInternal) public case addressStreet
```
```javascript
// Parent: AnalyticsEventTarget
@_spi(AdyenInternal) public case addressHouseNumber
```
```javascript
// Parent: AnalyticsEventTarget
@_spi(AdyenInternal) public case addressCity
```
```javascript
// Parent: AnalyticsEventTarget
@_spi(AdyenInternal) public case addressPostalCode
```
```javascript
// Parent: AnalyticsEventTarget
@_spi(AdyenInternal) public case issuerList
```
```javascript
// Parent: AnalyticsEventTarget
@_spi(AdyenInternal) public case listSearch
```
```javascript
// Parent: AnalyticsEventTarget
@_spi(AdyenInternal) @inlinable public init(rawValue: Swift.String) -> Adyen.AnalyticsEventTarget?
```
```javascript
// Parent: AnalyticsEventTarget
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
// Parent: AnalyticsEventTarget
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
// Parent: Root
public struct AnalyticsConfiguration
```
```javascript
// Parent: AnalyticsConfiguration
public var isEnabled: Swift.Bool { get set }
```
```javascript
// Parent: AnalyticsConfiguration
@_spi(AdyenInternal) public var context: Adyen.AnalyticsContext { get set }
```
```javascript
// Parent: AnalyticsConfiguration
public init() -> Adyen.AnalyticsConfiguration
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct AdditionalAnalyticsFields
```
```javascript
// Parent: AdditionalAnalyticsFields
@_spi(AdyenInternal) public let amount: Adyen.Amount? { get }
```
```javascript
// Parent: AdditionalAnalyticsFields
@_spi(AdyenInternal) public let sessionId: Swift.String? { get }
```
```javascript
// Parent: AdditionalAnalyticsFields
@_spi(AdyenInternal) public init(amount: Adyen.Amount?, sessionId: Swift.String?) -> Adyen.AdditionalAnalyticsFields
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum AnalyticsConstants
```
```javascript
// Parent: AnalyticsConstants
@_spi(AdyenInternal) public enum ValidationErrorCodes
```
```javascript
// Parent: AnalyticsConstants.ValidationErrorCodes
@_spi(AdyenInternal) public static let cardNumberEmpty: Swift.Int { get }
```
```javascript
// Parent: AnalyticsConstants.ValidationErrorCodes
@_spi(AdyenInternal) public static let cardNumberPartial: Swift.Int { get }
```
```javascript
// Parent: AnalyticsConstants.ValidationErrorCodes
@_spi(AdyenInternal) public static let cardLuhnCheckFailed: Swift.Int { get }
```
```javascript
// Parent: AnalyticsConstants.ValidationErrorCodes
@_spi(AdyenInternal) public static let cardUnsupported: Swift.Int { get }
```
```javascript
// Parent: AnalyticsConstants.ValidationErrorCodes
@_spi(AdyenInternal) public static let expiryDateEmpty: Swift.Int { get }
```
```javascript
// Parent: AnalyticsConstants.ValidationErrorCodes
@_spi(AdyenInternal) public static let expiryDatePartial: Swift.Int { get }
```
```javascript
// Parent: AnalyticsConstants.ValidationErrorCodes
@_spi(AdyenInternal) public static let cardExpired: Swift.Int { get }
```
```javascript
// Parent: AnalyticsConstants.ValidationErrorCodes
@_spi(AdyenInternal) public static let expiryDateTooFar: Swift.Int { get }
```
```javascript
// Parent: AnalyticsConstants.ValidationErrorCodes
@_spi(AdyenInternal) public static let securityCodeEmpty: Swift.Int { get }
```
```javascript
// Parent: AnalyticsConstants.ValidationErrorCodes
@_spi(AdyenInternal) public static let securityCodePartial: Swift.Int { get }
```
```javascript
// Parent: AnalyticsConstants.ValidationErrorCodes
@_spi(AdyenInternal) public static let holderNameEmpty: Swift.Int { get }
```
```javascript
// Parent: AnalyticsConstants.ValidationErrorCodes
@_spi(AdyenInternal) public static let brazilSSNEmpty: Swift.Int { get }
```
```javascript
// Parent: AnalyticsConstants.ValidationErrorCodes
@_spi(AdyenInternal) public static let brazilSSNPartial: Swift.Int { get }
```
```javascript
// Parent: AnalyticsConstants.ValidationErrorCodes
@_spi(AdyenInternal) public static let postalCodeEmpty: Swift.Int { get }
```
```javascript
// Parent: AnalyticsConstants.ValidationErrorCodes
@_spi(AdyenInternal) public static let postalCodePartial: Swift.Int { get }
```
```javascript
// Parent: AnalyticsConstants.ValidationErrorCodes
@_spi(AdyenInternal) public static let kcpPasswordEmpty: Swift.Int { get }
```
```javascript
// Parent: AnalyticsConstants.ValidationErrorCodes
@_spi(AdyenInternal) public static let kcpPasswordPartial: Swift.Int { get }
```
```javascript
// Parent: AnalyticsConstants.ValidationErrorCodes
@_spi(AdyenInternal) public static let kcpFieldEmpty: Swift.Int { get }
```
```javascript
// Parent: AnalyticsConstants.ValidationErrorCodes
@_spi(AdyenInternal) public static let kcpFieldPartial: Swift.Int { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct AnalyticsContext
```
```javascript
// Parent: AnalyticsContext
@_spi(AdyenInternal) public init(version: Swift.String = $DEFAULT_ARG, platform: Adyen.AnalyticsContext.Platform = $DEFAULT_ARG) -> Adyen.AnalyticsContext
```
```javascript
// Parent: AnalyticsContext
@_spi(AdyenInternal) public enum Platform : Equatable, Hashable, RawRepresentable
```
```javascript
// Parent: AnalyticsContext.Platform
@_spi(AdyenInternal) public case iOS
```
```javascript
// Parent: AnalyticsContext.Platform
@_spi(AdyenInternal) public case reactNative
```
```javascript
// Parent: AnalyticsContext.Platform
@_spi(AdyenInternal) public case flutter
```
```javascript
// Parent: AnalyticsContext.Platform
@_spi(AdyenInternal) @inlinable public init(rawValue: Swift.String) -> Adyen.AnalyticsContext.Platform?
```
```javascript
// Parent: AnalyticsContext.Platform
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
// Parent: AnalyticsContext.Platform
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct AnalyticsEventError : AnalyticsEvent, Encodable
```
```javascript
// Parent: AnalyticsEventError
@_spi(AdyenInternal) public var id: Swift.String { get set }
```
```javascript
// Parent: AnalyticsEventError
@_spi(AdyenInternal) public var timestamp: Swift.Int { get set }
```
```javascript
// Parent: AnalyticsEventError
@_spi(AdyenInternal) public var component: Swift.String { get set }
```
```javascript
// Parent: AnalyticsEventError
@_spi(AdyenInternal) public var type: Adyen.AnalyticsEventError.ErrorType { get set }
```
```javascript
// Parent: AnalyticsEventError
@_spi(AdyenInternal) public var code: Swift.String? { get set }
```
```javascript
// Parent: AnalyticsEventError
@_spi(AdyenInternal) public var message: Swift.String? { get set }
```
```javascript
// Parent: AnalyticsEventError
@_spi(AdyenInternal) public enum ErrorType : Encodable, Equatable, Hashable, RawRepresentable
```
```javascript
// Parent: AnalyticsEventError.ErrorType
@_spi(AdyenInternal) public case network
```
```javascript
// Parent: AnalyticsEventError.ErrorType
@_spi(AdyenInternal) public case implementation
```
```javascript
// Parent: AnalyticsEventError.ErrorType
@_spi(AdyenInternal) public case internal
```
```javascript
// Parent: AnalyticsEventError.ErrorType
@_spi(AdyenInternal) public case api
```
```javascript
// Parent: AnalyticsEventError.ErrorType
@_spi(AdyenInternal) public case sdk
```
```javascript
// Parent: AnalyticsEventError.ErrorType
@_spi(AdyenInternal) public case thirdParty
```
```javascript
// Parent: AnalyticsEventError.ErrorType
@_spi(AdyenInternal) public case generic
```
```javascript
// Parent: AnalyticsEventError.ErrorType
@_spi(AdyenInternal) @inlinable public init(rawValue: Swift.String) -> Adyen.AnalyticsEventError.ErrorType?
```
```javascript
// Parent: AnalyticsEventError.ErrorType
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
// Parent: AnalyticsEventError.ErrorType
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
// Parent: AnalyticsEventError
@_spi(AdyenInternal) public init(component: Swift.String, type: Adyen.AnalyticsEventError.ErrorType) -> Adyen.AnalyticsEventError
```
```javascript
// Parent: AnalyticsEventError
@_spi(AdyenInternal) public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct AnalyticsEventInfo : AnalyticsEvent, Encodable
```
```javascript
// Parent: AnalyticsEventInfo
@_spi(AdyenInternal) public var id: Swift.String { get set }
```
```javascript
// Parent: AnalyticsEventInfo
@_spi(AdyenInternal) public var timestamp: Swift.Int { get set }
```
```javascript
// Parent: AnalyticsEventInfo
@_spi(AdyenInternal) public var component: Swift.String { get set }
```
```javascript
// Parent: AnalyticsEventInfo
@_spi(AdyenInternal) public var type: Adyen.AnalyticsEventInfo.InfoType { get set }
```
```javascript
// Parent: AnalyticsEventInfo
@_spi(AdyenInternal) public var target: Adyen.AnalyticsEventTarget? { get set }
```
```javascript
// Parent: AnalyticsEventInfo
@_spi(AdyenInternal) public var isStoredPaymentMethod: Swift.Bool? { get set }
```
```javascript
// Parent: AnalyticsEventInfo
@_spi(AdyenInternal) public var brand: Swift.String? { get set }
```
```javascript
// Parent: AnalyticsEventInfo
@_spi(AdyenInternal) public var issuer: Swift.String? { get set }
```
```javascript
// Parent: AnalyticsEventInfo
@_spi(AdyenInternal) public var validationErrorCode: Swift.String? { get set }
```
```javascript
// Parent: AnalyticsEventInfo
@_spi(AdyenInternal) public var validationErrorMessage: Swift.String? { get set }
```
```javascript
// Parent: AnalyticsEventInfo
@_spi(AdyenInternal) public enum InfoType : Encodable, Equatable, Hashable, RawRepresentable
```
```javascript
// Parent: AnalyticsEventInfo.InfoType
@_spi(AdyenInternal) public case selected
```
```javascript
// Parent: AnalyticsEventInfo.InfoType
@_spi(AdyenInternal) public case focus
```
```javascript
// Parent: AnalyticsEventInfo.InfoType
@_spi(AdyenInternal) public case unfocus
```
```javascript
// Parent: AnalyticsEventInfo.InfoType
@_spi(AdyenInternal) public case validationError
```
```javascript
// Parent: AnalyticsEventInfo.InfoType
@_spi(AdyenInternal) public case rendered
```
```javascript
// Parent: AnalyticsEventInfo.InfoType
@_spi(AdyenInternal) public case input
```
```javascript
// Parent: AnalyticsEventInfo.InfoType
@_spi(AdyenInternal) @inlinable public init(rawValue: Swift.String) -> Adyen.AnalyticsEventInfo.InfoType?
```
```javascript
// Parent: AnalyticsEventInfo.InfoType
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
// Parent: AnalyticsEventInfo.InfoType
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
// Parent: AnalyticsEventInfo
@_spi(AdyenInternal) public init(component: Swift.String, type: Adyen.AnalyticsEventInfo.InfoType) -> Adyen.AnalyticsEventInfo
```
```javascript
// Parent: AnalyticsEventInfo
@_spi(AdyenInternal) public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct AnalyticsEventLog : AnalyticsEvent, Encodable
```
```javascript
// Parent: AnalyticsEventLog
@_spi(AdyenInternal) public var id: Swift.String { get set }
```
```javascript
// Parent: AnalyticsEventLog
@_spi(AdyenInternal) public var timestamp: Swift.Int { get set }
```
```javascript
// Parent: AnalyticsEventLog
@_spi(AdyenInternal) public var component: Swift.String { get set }
```
```javascript
// Parent: AnalyticsEventLog
@_spi(AdyenInternal) public var type: Adyen.AnalyticsEventLog.LogType { get set }
```
```javascript
// Parent: AnalyticsEventLog
@_spi(AdyenInternal) public var subType: Adyen.AnalyticsEventLog.LogSubType? { get set }
```
```javascript
// Parent: AnalyticsEventLog
@_spi(AdyenInternal) public var target: Adyen.AnalyticsEventTarget? { get set }
```
```javascript
// Parent: AnalyticsEventLog
@_spi(AdyenInternal) public var message: Swift.String? { get set }
```
```javascript
// Parent: AnalyticsEventLog
@_spi(AdyenInternal) public enum LogType : Encodable, Equatable, Hashable, RawRepresentable
```
```javascript
// Parent: AnalyticsEventLog.LogType
@_spi(AdyenInternal) public case action
```
```javascript
// Parent: AnalyticsEventLog.LogType
@_spi(AdyenInternal) public case submit
```
```javascript
// Parent: AnalyticsEventLog.LogType
@_spi(AdyenInternal) public case redirect
```
```javascript
// Parent: AnalyticsEventLog.LogType
@_spi(AdyenInternal) public case threeDS2
```
```javascript
// Parent: AnalyticsEventLog.LogType
@_spi(AdyenInternal) @inlinable public init(rawValue: Swift.String) -> Adyen.AnalyticsEventLog.LogType?
```
```javascript
// Parent: AnalyticsEventLog.LogType
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
// Parent: AnalyticsEventLog.LogType
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
// Parent: AnalyticsEventLog
@_spi(AdyenInternal) public enum LogSubType : Encodable, Equatable, Hashable, RawRepresentable
```
```javascript
// Parent: AnalyticsEventLog.LogSubType
@_spi(AdyenInternal) public case threeDS2
```
```javascript
// Parent: AnalyticsEventLog.LogSubType
@_spi(AdyenInternal) public case redirect
```
```javascript
// Parent: AnalyticsEventLog.LogSubType
@_spi(AdyenInternal) public case voucher
```
```javascript
// Parent: AnalyticsEventLog.LogSubType
@_spi(AdyenInternal) public case await
```
```javascript
// Parent: AnalyticsEventLog.LogSubType
@_spi(AdyenInternal) public case qrCode
```
```javascript
// Parent: AnalyticsEventLog.LogSubType
@_spi(AdyenInternal) public case bankTransfer
```
```javascript
// Parent: AnalyticsEventLog.LogSubType
@_spi(AdyenInternal) public case sdk
```
```javascript
// Parent: AnalyticsEventLog.LogSubType
@_spi(AdyenInternal) public case fingerprintSent
```
```javascript
// Parent: AnalyticsEventLog.LogSubType
@_spi(AdyenInternal) public case fingerprintComplete
```
```javascript
// Parent: AnalyticsEventLog.LogSubType
@_spi(AdyenInternal) public case challengeDataSent
```
```javascript
// Parent: AnalyticsEventLog.LogSubType
@_spi(AdyenInternal) public case challengeDisplayed
```
```javascript
// Parent: AnalyticsEventLog.LogSubType
@_spi(AdyenInternal) public case challengeComplete
```
```javascript
// Parent: AnalyticsEventLog.LogSubType
@_spi(AdyenInternal) @inlinable public init(rawValue: Swift.String) -> Adyen.AnalyticsEventLog.LogSubType?
```
```javascript
// Parent: AnalyticsEventLog.LogSubType
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
// Parent: AnalyticsEventLog.LogSubType
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
// Parent: AnalyticsEventLog
@_spi(AdyenInternal) public init(component: Swift.String, type: Adyen.AnalyticsEventLog.LogType, subType: Adyen.AnalyticsEventLog.LogSubType? = $DEFAULT_ARG) -> Adyen.AnalyticsEventLog
```
```javascript
// Parent: AnalyticsEventLog
@_spi(AdyenInternal) public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol AnalyticsValidationError<Self : Adyen.ValidationError> : Error, LocalizedError, Sendable, ValidationError
```
```javascript
// Parent: AnalyticsValidationError
@_spi(AdyenInternal) public var analyticsErrorCode: Swift.Int { get }
```
```javascript
// Parent: AnalyticsValidationError
@_spi(AdyenInternal) public var analyticsErrorMessage: Swift.String { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct LocalizationKey
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let submitButton: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let submitButtonFormatted: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cancelButton: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let dismissButton: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let removeButton: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let errorTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let errorUnknown: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let validationAlertTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let paymentMethodsOtherMethods: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let paymentMethodsStoredMethods: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let paymentMethodsPaidMethods: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let paymentMethodsTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let paymentMethodRemoveButton: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let paymentRefusedMessage: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let sepaIbanItemTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let sepaIbanItemInvalid: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let sepaNameItemTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let sepaNameItemPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let sepaConsentLabel: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let sepaNameItemInvalid: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardStoreDetailsButton: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardNameItemTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardNameItemPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardNameItemInvalid: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardNumberItemTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardNumberItemPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardNumberItemInvalid: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardExpiryItemTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardExpiryItemTitleOptional: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardExpiryItemPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardExpiryItemInvalid: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardCvcItemInvalid: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardCvcItemTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardCvcItemPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardStoredTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardStoredMessage: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardStoredExpires: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardNumberItemUnsupportedBrand: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardNumberItemUnknownBrand: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let dropInStoredTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let dropInPreselectedOpenAllTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let continueTo: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let continueTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let phoneNumberTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let phoneNumberInvalid: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let telephonePrefix: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let phoneNumberPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardCvcItemPlaceholderDigits: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let emailItemTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let emailItemPlaceHolder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let emailItemInvalid: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let moreOptions: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let applePayTotal: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let mbwayConfirmPayment: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let awaitWaitForConfirmation: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let blikConfirmPayment: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let blikInvalid: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let blikCode: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let blikHelp: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let blikPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let preauthorizeWith: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let confirmPreauthorization: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardCvcItemTitleOptional: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let confirmPurchase: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let lastName: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let firstName: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardPinTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let missingField: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardApplyGiftcard: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let voucherCollectionInstitutionNumber: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let voucherMerchantName: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let voucherExpirationDate: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let voucherPaymentReferenceLabel: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let voucherShopperName: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let buttonCopy: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let voucherIntroduction: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let voucherReadInstructions: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let voucherSaveImage: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let voucherFinish: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardBrazilSSNPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let amount: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let voucherEntity: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let pixInstructions: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let pixExpirationLabel: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let pixCopyButton: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let pixInstructionsCopiedMessage: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let billingAddressSectionTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let billingAddressPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let deliveryAddressSectionTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let deliveryAddressPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let countryFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let countryFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let countryFieldInvalid: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let addressFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let addressFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let streetFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let streetFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let houseNumberFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let houseNumberFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cityFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cityFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cityTownFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cityTownFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let postalCodeFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let postalCodeFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let zipCodeFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let zipCodeFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let stateFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let stateFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let selectStateFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let stateOrProvinceFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let stateOrProvinceFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let selectStateOrProvinceFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let provinceOrTerritoryFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let provinceOrTerritoryFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let apartmentSuiteFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let apartmentSuiteFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let errorFeedbackEmptyField: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let errorFeedbackIncorrectFormat: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let fieldTitleOptional: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let boletobancarioBtnLabel: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let boletoSendCopyToEmail: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let boletoPersonalDetails: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let boletoSocialSecurityNumber: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let boletoDownloadPdf: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let giftcardCurrencyError: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let giftcardNoBalance: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let giftcardRemoveTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let giftcardRemoveMessage: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let giftcardPaymentMethodTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let partialPaymentRemainingBalance: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let partialPaymentPayRemainingAmount: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardTaxNumberLabel: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardTaxNumberPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardTaxNumberInvalid: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardEncryptedPasswordLabel: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardEncryptedPasswordPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardEncryptedPasswordInvalid: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardTaxNumberLabelShort: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let affirmDeliveryAddressToggleTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let voucherShopperReference: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let voucherAlternativeReference: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardInstallmentsNumberOfInstallments: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardInstallmentsOneTime: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardInstallmentsTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardInstallmentsRevolving: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardInstallmentsMonthsAndPrice: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardInstallmentsMonths: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cardInstallmentsPlan: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let bacsHolderNameFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let bacsBankAccountNumberFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let bacsBankLocationIdFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let bacsLegalConsentToggleTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let bacsAmountConsentToggleTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let bacsSpecifiedAmountConsentToggleTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let bacsHolderNameFieldInvalidMessage: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let bacsBankAccountNumberFieldInvalidMessage: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let bacsBankLocationIdFieldInvalidMessage: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let bacsPaymentButtonTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let bacsDownloadMandate: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let achBankAccountTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let achAccountHolderNameFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let achAccountHolderNameFieldInvalid: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let achAccountNumberFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let achAccountNumberFieldInvalid: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let achAccountLocationFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let achAccountLocationFieldInvalid: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let selectFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let onlineBankingTermsAndConditions: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let qrCodeInstructionMessage: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let qrCodeTimerExpirationMessage: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let paybybankSubtitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let paybybankTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let searchPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let upiModeSelection: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let UPIVpaValidationMessage: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let UPIQrcodeGenerationMessage: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let UPIQrcodeTimerMessage: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let upiCollectConfirmPayment: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let upiVpaWaitingMessage: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let QRCodeGenerateQRCode: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let UPIQRCodeInstructions: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let UPIFirstTabTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let UPISecondTabTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let UPICollectDropdownLabel: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let UPICollectFieldLabel: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let UPIErrorNoAppSelected: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cashAppPayTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let cashAppPayCashtag: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let twintNoAppsInstalledMessage: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DARegistrationTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DABiometrics: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DAFaceID: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DATouchID: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DAOpticID: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DARegistrationDescription: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DARegistrationFirstInfo: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DARegistrationSecondInfo: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DARegistrationThirdInfo: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DARegistrationPositiveButton: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DARegistrationNegativeButton: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DAApprovalTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DAApprovalDescription: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DAApprovalPositiveButton: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DAApprovalNegativeButton: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DAApprovalActionSheetTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DAApprovalActionSheetFallback: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DAApprovalActionSheetRemove: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DAApprovalRemoveAlertTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DAApprovalRemoveAlertDescription: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DAApprovalRemoveAlertPositiveButton: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DAApprovalRemoveAlertNegativeButton: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DAApprovalErrorTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DAApprovalErrorMessage: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DAApprovalErrorButtonTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DARegistrationErrorTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DARegistrationErrorMessage: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DARegistrationErrorButtonTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DADeletionConfirmationTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DADeletionConfirmationMessage: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let threeds2DADeletionConfirmationButtonTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let pickerSearchEmptyTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let pickerSearchEmptySubtitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let addressLookupSearchPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let addressLookupSearchEmptyTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let addressLookupSearchEmptySubtitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let addressLookupSearchEmptyTitleNoResults: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let addressLookupSearchEmptySubtitleNoResults: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let addressLookupItemValidationFailureMessageEmpty: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let addressLookupItemValidationFailureMessageInvalid: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let addressLookupSearchManualEntryItemTitle: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public static let accessibilityLastFourDigits: Adyen.LocalizationKey { get }
```
```javascript
// Parent: LocalizationKey
@_spi(AdyenInternal) public init(key: Swift.String) -> Adyen.LocalizationKey
```
```javascript
// Parent: Root
public protocol AdyenContextAware<Self : AnyObject>
```
```javascript
// Parent: AdyenContextAware
public var context: Adyen.AdyenContext { get }
```
```javascript
// Parent: AdyenContextAware
public var payment: Adyen.Payment? { get }
```
```javascript
// Parent: Root
public struct APIContext : AnyAPIContext
```
```javascript
// Parent: APIContext
public var queryParameters: [Foundation.URLQueryItem] { get }
```
```javascript
// Parent: APIContext
public let headers: [Swift.String : Swift.String] { get }
```
```javascript
// Parent: APIContext
public let environment: any AdyenNetworking.AnyAPIEnvironment { get }
```
```javascript
// Parent: APIContext
public let clientKey: Swift.String { get }
```
```javascript
// Parent: APIContext
public init(environment: any AdyenNetworking.AnyAPIEnvironment, clientKey: Swift.String) throws -> Adyen.APIContext
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum AnalyticsEnvironment : AnyAPIEnvironment, Equatable, Hashable, RawRepresentable
```
```javascript
// Parent: AnalyticsEnvironment
@_spi(AdyenInternal) public case test
```
```javascript
// Parent: AnalyticsEnvironment
@_spi(AdyenInternal) public case liveEurope
```
```javascript
// Parent: AnalyticsEnvironment
@_spi(AdyenInternal) public case liveAustralia
```
```javascript
// Parent: AnalyticsEnvironment
@_spi(AdyenInternal) public case liveUnitedStates
```
```javascript
// Parent: AnalyticsEnvironment
@_spi(AdyenInternal) public case liveApse
```
```javascript
// Parent: AnalyticsEnvironment
@_spi(AdyenInternal) public case liveIndia
```
```javascript
// Parent: AnalyticsEnvironment
@_spi(AdyenInternal) public case beta
```
```javascript
// Parent: AnalyticsEnvironment
@_spi(AdyenInternal) public case local
```
```javascript
// Parent: AnalyticsEnvironment
@_spi(AdyenInternal) public var baseURL: Foundation.URL { get }
```
```javascript
// Parent: AnalyticsEnvironment
@_spi(AdyenInternal) @inlinable public init(rawValue: Swift.String) -> Adyen.AnalyticsEnvironment?
```
```javascript
// Parent: AnalyticsEnvironment
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
// Parent: AnalyticsEnvironment
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
// Parent: Root
public struct Environment : AnyAPIEnvironment, Equatable
```
```javascript
// Parent: Environment
public var baseURL: Foundation.URL { get set }
```
```javascript
// Parent: Environment
public static let test: Adyen.Environment { get }
```
```javascript
// Parent: Environment
@_spi(AdyenInternal) public static let beta: Adyen.Environment { get }
```
```javascript
// Parent: Environment
@_spi(AdyenInternal) public static let local: Adyen.Environment { get }
```
```javascript
// Parent: Environment
public static let live: Adyen.Environment { get }
```
```javascript
// Parent: Environment
public static let liveEurope: Adyen.Environment { get }
```
```javascript
// Parent: Environment
public static let liveAustralia: Adyen.Environment { get }
```
```javascript
// Parent: Environment
public static let liveUnitedStates: Adyen.Environment { get }
```
```javascript
// Parent: Environment
public static let liveApse: Adyen.Environment { get }
```
```javascript
// Parent: Environment
public static let liveIndia: Adyen.Environment { get }
```
```javascript
// Parent: Environment
@_spi(AdyenInternal) public var isLive: Swift.Bool { get }
```
```javascript
// Parent: Environment
@_spi(AdyenInternal) public static func __derived_struct_equals(_: Adyen.Environment, _: Adyen.Environment) -> Swift.Bool
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol APIRequest<Self : AdyenNetworking.Request, Self.ErrorResponseType == Adyen.APIError> : Encodable, Request
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct AppleWalletPassRequest : APIRequest, Encodable, Request
```
```javascript
// Parent: AppleWalletPassRequest
@_spi(AdyenInternal) public typealias ResponseType = Adyen.AppleWalletPassResponse
```
```javascript
// Parent: AppleWalletPassRequest
@_spi(AdyenInternal) public let path: Swift.String { get }
```
```javascript
// Parent: AppleWalletPassRequest
@_spi(AdyenInternal) public var counter: Swift.UInt { get set }
```
```javascript
// Parent: AppleWalletPassRequest
@_spi(AdyenInternal) public let headers: [Swift.String : Swift.String] { get }
```
```javascript
// Parent: AppleWalletPassRequest
@_spi(AdyenInternal) public let queryParameters: [Foundation.URLQueryItem] { get }
```
```javascript
// Parent: AppleWalletPassRequest
@_spi(AdyenInternal) public let method: AdyenNetworking.HTTPMethod { get }
```
```javascript
// Parent: AppleWalletPassRequest
@_spi(AdyenInternal) public let platform: Swift.String { get }
```
```javascript
// Parent: AppleWalletPassRequest
@_spi(AdyenInternal) public let passToken: Swift.String { get }
```
```javascript
// Parent: AppleWalletPassRequest
@_spi(AdyenInternal) public init(passToken: Swift.String) -> Adyen.AppleWalletPassRequest
```
```javascript
// Parent: AppleWalletPassRequest
@_spi(AdyenInternal) public enum CodingKeys : CodingKey, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, Sendable
```
```javascript
// Parent: AppleWalletPassRequest.CodingKeys
@_spi(AdyenInternal) public case platform
```
```javascript
// Parent: AppleWalletPassRequest.CodingKeys
@_spi(AdyenInternal) public case passToken
```
```javascript
// Parent: AppleWalletPassRequest.CodingKeys
@_spi(AdyenInternal) public static func __derived_enum_equals(_: Adyen.AppleWalletPassRequest.CodingKeys, _: Adyen.AppleWalletPassRequest.CodingKeys) -> Swift.Bool
```
```javascript
// Parent: AppleWalletPassRequest.CodingKeys
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: AppleWalletPassRequest.CodingKeys
@_spi(AdyenInternal) public init(stringValue: Swift.String) -> Adyen.AppleWalletPassRequest.CodingKeys?
```
```javascript
// Parent: AppleWalletPassRequest.CodingKeys
@_spi(AdyenInternal) public init(intValue: Swift.Int) -> Adyen.AppleWalletPassRequest.CodingKeys?
```
```javascript
// Parent: AppleWalletPassRequest.CodingKeys
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
// Parent: AppleWalletPassRequest.CodingKeys
@_spi(AdyenInternal) public var intValue: Swift.Int? { get }
```
```javascript
// Parent: AppleWalletPassRequest.CodingKeys
@_spi(AdyenInternal) public var stringValue: Swift.String { get }
```
```javascript
// Parent: AppleWalletPassRequest
@_spi(AdyenInternal) public typealias ErrorResponseType = Adyen.APIError
```
```javascript
// Parent: AppleWalletPassRequest
@_spi(AdyenInternal) public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct ClientKeyRequest : APIRequest, Encodable, Request
```
```javascript
// Parent: ClientKeyRequest
@_spi(AdyenInternal) public typealias ResponseType = Adyen.ClientKeyResponse
```
```javascript
// Parent: ClientKeyRequest
@_spi(AdyenInternal) public var path: Swift.String { get }
```
```javascript
// Parent: ClientKeyRequest
@_spi(AdyenInternal) public let clientKey: Swift.String { get }
```
```javascript
// Parent: ClientKeyRequest
@_spi(AdyenInternal) public var counter: Swift.UInt { get set }
```
```javascript
// Parent: ClientKeyRequest
@_spi(AdyenInternal) public let headers: [Swift.String : Swift.String] { get }
```
```javascript
// Parent: ClientKeyRequest
@_spi(AdyenInternal) public let queryParameters: [Foundation.URLQueryItem] { get }
```
```javascript
// Parent: ClientKeyRequest
@_spi(AdyenInternal) public let method: AdyenNetworking.HTTPMethod { get }
```
```javascript
// Parent: ClientKeyRequest
@_spi(AdyenInternal) public init(clientKey: Swift.String) -> Adyen.ClientKeyRequest
```
```javascript
// Parent: ClientKeyRequest
@_spi(AdyenInternal) public typealias ErrorResponseType = Adyen.APIError
```
```javascript
// Parent: ClientKeyRequest
@_spi(AdyenInternal) public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct OrderStatusRequest : APIRequest, Encodable, Request
```
```javascript
// Parent: OrderStatusRequest
@_spi(AdyenInternal) public typealias ResponseType = Adyen.OrderStatusResponse
```
```javascript
// Parent: OrderStatusRequest
@_spi(AdyenInternal) public var path: Swift.String { get }
```
```javascript
// Parent: OrderStatusRequest
@_spi(AdyenInternal) public var counter: Swift.UInt { get set }
```
```javascript
// Parent: OrderStatusRequest
@_spi(AdyenInternal) public let headers: [Swift.String : Swift.String] { get }
```
```javascript
// Parent: OrderStatusRequest
@_spi(AdyenInternal) public let queryParameters: [Foundation.URLQueryItem] { get }
```
```javascript
// Parent: OrderStatusRequest
@_spi(AdyenInternal) public let method: AdyenNetworking.HTTPMethod { get }
```
```javascript
// Parent: OrderStatusRequest
@_spi(AdyenInternal) public let orderData: Swift.String { get }
```
```javascript
// Parent: OrderStatusRequest
@_spi(AdyenInternal) public init(orderData: Swift.String) -> Adyen.OrderStatusRequest
```
```javascript
// Parent: OrderStatusRequest
@_spi(AdyenInternal) public typealias ErrorResponseType = Adyen.APIError
```
```javascript
// Parent: OrderStatusRequest
@_spi(AdyenInternal) public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct PaymentStatusRequest : APIRequest, Encodable, Request
```
```javascript
// Parent: PaymentStatusRequest
@_spi(AdyenInternal) public typealias ResponseType = Adyen.PaymentStatusResponse
```
```javascript
// Parent: PaymentStatusRequest
@_spi(AdyenInternal) public let path: Swift.String { get }
```
```javascript
// Parent: PaymentStatusRequest
@_spi(AdyenInternal) public var counter: Swift.UInt { get set }
```
```javascript
// Parent: PaymentStatusRequest
@_spi(AdyenInternal) public let headers: [Swift.String : Swift.String] { get }
```
```javascript
// Parent: PaymentStatusRequest
@_spi(AdyenInternal) public let queryParameters: [Foundation.URLQueryItem] { get }
```
```javascript
// Parent: PaymentStatusRequest
@_spi(AdyenInternal) public let method: AdyenNetworking.HTTPMethod { get }
```
```javascript
// Parent: PaymentStatusRequest
@_spi(AdyenInternal) public let paymentData: Swift.String { get }
```
```javascript
// Parent: PaymentStatusRequest
@_spi(AdyenInternal) public init(paymentData: Swift.String) -> Adyen.PaymentStatusRequest
```
```javascript
// Parent: PaymentStatusRequest
@_spi(AdyenInternal) public typealias ErrorResponseType = Adyen.APIError
```
```javascript
// Parent: PaymentStatusRequest
@_spi(AdyenInternal) public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct AppleWalletPassResponse : Decodable, Response
```
```javascript
// Parent: AppleWalletPassResponse
@_spi(AdyenInternal) public let passData: Foundation.Data { get }
```
```javascript
// Parent: AppleWalletPassResponse
@_spi(AdyenInternal) public init(passBase64String: Swift.String) throws -> Adyen.AppleWalletPassResponse
```
```javascript
// Parent: AppleWalletPassResponse
@_spi(AdyenInternal) public init(from: any Swift.Decoder) throws -> Adyen.AppleWalletPassResponse
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct ClientKeyResponse : Decodable, Response
```
```javascript
// Parent: ClientKeyResponse
@_spi(AdyenInternal) public let cardPublicKey: Swift.String { get }
```
```javascript
// Parent: ClientKeyResponse
@_spi(AdyenInternal) public init(from: any Swift.Decoder) throws -> Adyen.ClientKeyResponse
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct OrderStatusResponse : Decodable, Response
```
```javascript
// Parent: OrderStatusResponse
@_spi(AdyenInternal) public let remainingAmount: Adyen.Amount { get }
```
```javascript
// Parent: OrderStatusResponse
@_spi(AdyenInternal) public let paymentMethods: [Adyen.OrderPaymentMethod]? { get }
```
```javascript
// Parent: OrderStatusResponse
@_spi(AdyenInternal) public init(remainingAmount: Adyen.Amount, paymentMethods: [Adyen.OrderPaymentMethod]?) -> Adyen.OrderStatusResponse
```
```javascript
// Parent: OrderStatusResponse
@_spi(AdyenInternal) public init(from: any Swift.Decoder) throws -> Adyen.OrderStatusResponse
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct OrderPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: OrderPaymentMethod
@_spi(AdyenInternal) public var name: Swift.String { get }
```
```javascript
// Parent: OrderPaymentMethod
@_spi(AdyenInternal) public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: OrderPaymentMethod
@_spi(AdyenInternal) public let lastFour: Swift.String { get }
```
```javascript
// Parent: OrderPaymentMethod
@_spi(AdyenInternal) public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: OrderPaymentMethod
@_spi(AdyenInternal) public let transactionLimit: Adyen.Amount? { get }
```
```javascript
// Parent: OrderPaymentMethod
@_spi(AdyenInternal) public let amount: Adyen.Amount { get }
```
```javascript
// Parent: OrderPaymentMethod
@_spi(AdyenInternal) public init(lastFour: Swift.String, type: Adyen.PaymentMethodType, transactionLimit: Adyen.Amount?, amount: Adyen.Amount) -> Adyen.OrderPaymentMethod
```
```javascript
// Parent: OrderPaymentMethod
@_spi(AdyenInternal) public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
// Parent: OrderPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: OrderPaymentMethod
@_spi(AdyenInternal) public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: OrderPaymentMethod
@_spi(AdyenInternal) public init(from: any Swift.Decoder) throws -> Adyen.OrderPaymentMethod
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum PaymentResultCode : Decodable, Equatable, Hashable, RawRepresentable
```
```javascript
// Parent: PaymentResultCode
@_spi(AdyenInternal) public case authorised
```
```javascript
// Parent: PaymentResultCode
@_spi(AdyenInternal) public case refused
```
```javascript
// Parent: PaymentResultCode
@_spi(AdyenInternal) public case pending
```
```javascript
// Parent: PaymentResultCode
@_spi(AdyenInternal) public case cancelled
```
```javascript
// Parent: PaymentResultCode
@_spi(AdyenInternal) public case error
```
```javascript
// Parent: PaymentResultCode
@_spi(AdyenInternal) public case received
```
```javascript
// Parent: PaymentResultCode
@_spi(AdyenInternal) public case redirectShopper
```
```javascript
// Parent: PaymentResultCode
@_spi(AdyenInternal) public case identifyShopper
```
```javascript
// Parent: PaymentResultCode
@_spi(AdyenInternal) public case challengeShopper
```
```javascript
// Parent: PaymentResultCode
@_spi(AdyenInternal) @inlinable public init(rawValue: Swift.String) -> Adyen.PaymentResultCode?
```
```javascript
// Parent: PaymentResultCode
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
// Parent: PaymentResultCode
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct PaymentStatusResponse : Decodable, Response
```
```javascript
// Parent: PaymentStatusResponse
@_spi(AdyenInternal) public let payload: Swift.String { get }
```
```javascript
// Parent: PaymentStatusResponse
@_spi(AdyenInternal) public let resultCode: Adyen.PaymentResultCode { get }
```
```javascript
// Parent: PaymentStatusResponse
@_spi(AdyenInternal) public init(from: any Swift.Decoder) throws -> Adyen.PaymentStatusResponse
```
```javascript
// Parent: Root
public final class AdyenContext : PaymentAware
```
```javascript
// Parent: AdyenContext
public let apiContext: Adyen.APIContext { get }
```
```javascript
// Parent: AdyenContext
public var payment: Adyen.Payment? { get }
```
```javascript
// Parent: AdyenContext
@_spi(AdyenInternal) public let analyticsProvider: (any Adyen.AnalyticsProviderProtocol)? { get }
```
```javascript
// Parent: AdyenContext
public convenience init(apiContext: Adyen.APIContext, payment: Adyen.Payment?, analyticsConfiguration: Adyen.AnalyticsConfiguration = $DEFAULT_ARG) -> Adyen.AdyenContext
```
```javascript
// Parent: AdyenContext
@_spi(AdyenInternal) public func update(payment: Adyen.Payment?) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum PersonalInformation : Equatable
```
```javascript
// Parent: PersonalInformation
@_spi(AdyenInternal) public case firstName
```
```javascript
// Parent: PersonalInformation
@_spi(AdyenInternal) public case lastName
```
```javascript
// Parent: PersonalInformation
@_spi(AdyenInternal) public case email
```
```javascript
// Parent: PersonalInformation
@_spi(AdyenInternal) public case phone
```
```javascript
// Parent: PersonalInformation
@_spi(AdyenInternal) public case address
```
```javascript
// Parent: PersonalInformation
@_spi(AdyenInternal) public case deliveryAddress
```
```javascript
// Parent: PersonalInformation
@_spi(AdyenInternal) public case custom(any Adyen.FormItemInjector)
```
```javascript
// Parent: PersonalInformation
@_spi(AdyenInternal) public static func ==(_: Adyen.PersonalInformation, _: Adyen.PersonalInformation) -> Swift.Bool
```
```javascript
// Parent: Root
open class AbstractPersonalInformationComponent : AdyenContextAware, Component, LoadingComponent, PartialPaymentOrderAware, PaymentAware, PaymentComponent, PaymentMethodAware, PresentableComponent, TrackableComponent, ViewControllerDelegate, ViewControllerPresenter
```
```javascript
// Parent: AbstractPersonalInformationComponent
public typealias Configuration = Adyen.PersonalInformationConfiguration
```
```javascript
// Parent: AbstractPersonalInformationComponent
@_spi(AdyenInternal) public let context: Adyen.AdyenContext { get }
```
```javascript
// Parent: AbstractPersonalInformationComponent
public let paymentMethod: any Adyen.PaymentMethod { get }
```
```javascript
// Parent: AbstractPersonalInformationComponent
public weak var delegate: (any Adyen.PaymentComponentDelegate)? { get set }
```
```javascript
// Parent: AbstractPersonalInformationComponent
public lazy var viewController: UIKit.UIViewController { get set }
```
```javascript
// Parent: AbstractPersonalInformationComponent
public let requiresModalPresentation: Swift.Bool { get }
```
```javascript
// Parent: AbstractPersonalInformationComponent
@_spi(AdyenInternal) public var configuration: Adyen.AbstractPersonalInformationComponent.Configuration { get set }
```
```javascript
// Parent: AbstractPersonalInformationComponent
@_spi(AdyenInternal) public init(paymentMethod: any Adyen.PaymentMethod, context: Adyen.AdyenContext, fields: [Adyen.PersonalInformation], configuration: Adyen.AbstractPersonalInformationComponent.Configuration) -> Adyen.AbstractPersonalInformationComponent
```
```javascript
// Parent: AbstractPersonalInformationComponent
@_spi(AdyenInternal) public var firstNameItem: Adyen.FormTextInputItem? { get }
```
```javascript
// Parent: AbstractPersonalInformationComponent
@_spi(AdyenInternal) public var lastNameItem: Adyen.FormTextInputItem? { get }
```
```javascript
// Parent: AbstractPersonalInformationComponent
@_spi(AdyenInternal) public var emailItem: Adyen.FormTextInputItem? { get }
```
```javascript
// Parent: AbstractPersonalInformationComponent
@_spi(AdyenInternal) public var addressItem: Adyen.FormAddressPickerItem? { get }
```
```javascript
// Parent: AbstractPersonalInformationComponent
@_spi(AdyenInternal) public var deliveryAddressItem: Adyen.FormAddressPickerItem? { get }
```
```javascript
// Parent: AbstractPersonalInformationComponent
@_spi(AdyenInternal) public var phoneItem: Adyen.FormPhoneNumberItem? { get }
```
```javascript
// Parent: AbstractPersonalInformationComponent
@_spi(AdyenInternal) open func submitButtonTitle() -> Swift.String
```
```javascript
// Parent: AbstractPersonalInformationComponent
@_spi(AdyenInternal) open func createPaymentDetails() throws -> any Adyen.PaymentMethodDetails
```
```javascript
// Parent: AbstractPersonalInformationComponent
@_spi(AdyenInternal) open func phoneExtensions() -> [Adyen.PhoneExtension]
```
```javascript
// Parent: AbstractPersonalInformationComponent
@_spi(AdyenInternal) open func addressViewModelBuilder() -> any Adyen.AddressViewModelBuilder
```
```javascript
// Parent: AbstractPersonalInformationComponent
@_spi(AdyenInternal) public func showValidation() -> Swift.Void
```
```javascript
// Parent: AbstractPersonalInformationComponent
public func stopLoading() -> Swift.Void
```
```javascript
// Parent: AbstractPersonalInformationComponent
@_spi(AdyenInternal) public func presentViewController(_: UIKit.UIViewController, animated: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: AbstractPersonalInformationComponent
@_spi(AdyenInternal) public func dismissViewController(animated: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: AbstractPersonalInformationComponent
@_spi(AdyenInternal) public func viewWillAppear(viewController: UIKit.UIViewController) -> Swift.Void
```
```javascript
// Parent: AbstractPersonalInformationComponent
@_spi(AdyenInternal) public func viewDidLoad(viewController: UIKit.UIViewController) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol FormItemInjector
```
```javascript
// Parent: FormItemInjector
@_spi(AdyenInternal) public func inject<Self where Self : Adyen.FormItemInjector>(into: Adyen.FormViewController) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct CustomFormItemInjector<T where T : Adyen.FormItem> : FormItemInjector
```
```javascript
// Parent: CustomFormItemInjector
@_spi(AdyenInternal) public init<T where T : Adyen.FormItem>(item: T) -> Adyen.CustomFormItemInjector<T>
```
```javascript
// Parent: CustomFormItemInjector
@_spi(AdyenInternal) public func inject<T where T : Adyen.FormItem>(into: Adyen.FormViewController) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class AlreadyPaidPaymentComponent : AdyenContextAware, Component, PartialPaymentOrderAware, PaymentComponent, PaymentMethodAware
```
```javascript
// Parent: AlreadyPaidPaymentComponent
@_spi(AdyenInternal) public let context: Adyen.AdyenContext { get }
```
```javascript
// Parent: AlreadyPaidPaymentComponent
@_spi(AdyenInternal) public let paymentMethod: any Adyen.PaymentMethod { get }
```
```javascript
// Parent: AlreadyPaidPaymentComponent
@_spi(AdyenInternal) public weak var delegate: (any Adyen.PaymentComponentDelegate)? { get set }
```
```javascript
// Parent: AlreadyPaidPaymentComponent
@_spi(AdyenInternal) public init(paymentMethod: any Adyen.PaymentMethod, context: Adyen.AdyenContext) -> Adyen.AlreadyPaidPaymentComponent
```
```javascript
// Parent: Root
public protocol AnyCashAppPayConfiguration
```
```javascript
// Parent: AnyCashAppPayConfiguration
public var redirectURL: Foundation.URL { get }
```
```javascript
// Parent: AnyCashAppPayConfiguration
public var referenceId: Swift.String? { get }
```
```javascript
// Parent: AnyCashAppPayConfiguration
public var showsStorePaymentMethodField: Swift.Bool { get }
```
```javascript
// Parent: AnyCashAppPayConfiguration
public var storePaymentMethod: Swift.Bool { get }
```
```javascript
// Parent: Root
public struct ActionComponentData
```
```javascript
// Parent: ActionComponentData
public let details: any Adyen.AdditionalDetails { get }
```
```javascript
// Parent: ActionComponentData
public let paymentData: Swift.String? { get }
```
```javascript
// Parent: ActionComponentData
public init(details: any Adyen.AdditionalDetails, paymentData: Swift.String?) -> Adyen.ActionComponentData
```
```javascript
// Parent: Root
public protocol AnyBasicComponentConfiguration<Self : Adyen.Localizable> : Localizable
```
```javascript
// Parent: Root
public protocol AnyPersonalInformationConfiguration<Self : Adyen.AnyBasicComponentConfiguration> : AnyBasicComponentConfiguration, Localizable
```
```javascript
// Parent: AnyPersonalInformationConfiguration
public var shopperInformation: Adyen.PrefilledShopperInformation? { get }
```
```javascript
// Parent: Root
public struct BasicComponentConfiguration : AnyBasicComponentConfiguration, Localizable
```
```javascript
// Parent: BasicComponentConfiguration
public var style: Adyen.FormComponentStyle { get set }
```
```javascript
// Parent: BasicComponentConfiguration
public var localizationParameters: Adyen.LocalizationParameters? { get set }
```
```javascript
// Parent: BasicComponentConfiguration
public init(style: Adyen.FormComponentStyle = $DEFAULT_ARG, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG) -> Adyen.BasicComponentConfiguration
```
```javascript
// Parent: Root
public struct PersonalInformationConfiguration : AnyBasicComponentConfiguration, AnyPersonalInformationConfiguration, Localizable
```
```javascript
// Parent: PersonalInformationConfiguration
public var style: Adyen.FormComponentStyle { get set }
```
```javascript
// Parent: PersonalInformationConfiguration
public var shopperInformation: Adyen.PrefilledShopperInformation? { get set }
```
```javascript
// Parent: PersonalInformationConfiguration
public var localizationParameters: Adyen.LocalizationParameters? { get set }
```
```javascript
// Parent: PersonalInformationConfiguration
public init(style: Adyen.FormComponentStyle = $DEFAULT_ARG, shopperInformation: Adyen.PrefilledShopperInformation? = $DEFAULT_ARG, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG) -> Adyen.PersonalInformationConfiguration
```
```javascript
// Parent: Root
public enum PartialPaymentError : Equatable, Error, Hashable, LocalizedError, Sendable
```
```javascript
// Parent: PartialPaymentError
public case zeroRemainingAmount
```
```javascript
// Parent: PartialPaymentError
public case missingOrderData
```
```javascript
// Parent: PartialPaymentError
public case notSupportedForComponent
```
```javascript
// Parent: PartialPaymentError
public var errorDescription: Swift.String? { get }
```
```javascript
// Parent: PartialPaymentError
public static func __derived_enum_equals(_: Adyen.PartialPaymentError, _: Adyen.PartialPaymentError) -> Swift.Bool
```
```javascript
// Parent: PartialPaymentError
public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: PartialPaymentError
public var hashValue: Swift.Int { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class PresentableComponentWrapper : AdyenContextAware, Cancellable, Component, FinalizableComponent, LoadingComponent, PresentableComponent
```
```javascript
// Parent: PresentableComponentWrapper
@_spi(AdyenInternal) public var apiContext: Adyen.APIContext { get }
```
```javascript
// Parent: PresentableComponentWrapper
@_spi(AdyenInternal) public var context: Adyen.AdyenContext { get }
```
```javascript
// Parent: PresentableComponentWrapper
@_spi(AdyenInternal) public let viewController: UIKit.UIViewController { get }
```
```javascript
// Parent: PresentableComponentWrapper
@_spi(AdyenInternal) public let component: any Adyen.Component { get }
```
```javascript
// Parent: PresentableComponentWrapper
@_spi(AdyenInternal) public var requiresModalPresentation: Swift.Bool { get set }
```
```javascript
// Parent: PresentableComponentWrapper
@_spi(AdyenInternal) public var navBarType: Adyen.NavigationBarType { get set }
```
```javascript
// Parent: PresentableComponentWrapper
@_spi(AdyenInternal) public init(component: any Adyen.Component, viewController: UIKit.UIViewController, navBarType: Adyen.NavigationBarType = $DEFAULT_ARG) -> Adyen.PresentableComponentWrapper
```
```javascript
// Parent: PresentableComponentWrapper
@_spi(AdyenInternal) public func didCancel() -> Swift.Void
```
```javascript
// Parent: PresentableComponentWrapper
@_spi(AdyenInternal) public func didFinalize(with: Swift.Bool, completion: (() -> Swift.Void)?) -> Swift.Void
```
```javascript
// Parent: PresentableComponentWrapper
@_spi(AdyenInternal) public func stopLoading() -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol InstallmentConfigurationAware<Self : Adyen.AdyenSessionAware> : AdyenSessionAware
```
```javascript
// Parent: InstallmentConfigurationAware
@_spi(AdyenInternal) public var installmentConfiguration: Adyen.InstallmentConfiguration? { get }
```
```javascript
// Parent: Root
public struct InstallmentOptions : Decodable, Encodable, Equatable
```
```javascript
// Parent: InstallmentOptions
@_spi(AdyenInternal) public let regularInstallmentMonths: [Swift.UInt] { get }
```
```javascript
// Parent: InstallmentOptions
@_spi(AdyenInternal) public let includesRevolving: Swift.Bool { get }
```
```javascript
// Parent: InstallmentOptions
public init(monthValues: [Swift.UInt], includesRevolving: Swift.Bool) -> Adyen.InstallmentOptions
```
```javascript
// Parent: InstallmentOptions
public init(maxInstallmentMonth: Swift.UInt, includesRevolving: Swift.Bool) -> Adyen.InstallmentOptions
```
```javascript
// Parent: InstallmentOptions
@_spi(AdyenInternal) public init(from: any Swift.Decoder) throws -> Adyen.InstallmentOptions
```
```javascript
// Parent: InstallmentOptions
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: InstallmentOptions
public static func __derived_struct_equals(_: Adyen.InstallmentOptions, _: Adyen.InstallmentOptions) -> Swift.Bool
```
```javascript
// Parent: Root
public struct InstallmentConfiguration : Decodable
```
```javascript
// Parent: InstallmentConfiguration
@_spi(AdyenInternal) public let defaultOptions: Adyen.InstallmentOptions? { get }
```
```javascript
// Parent: InstallmentConfiguration
@_spi(AdyenInternal) public let cardBasedOptions: [Adyen.CardType : Adyen.InstallmentOptions]? { get }
```
```javascript
// Parent: InstallmentConfiguration
@_spi(AdyenInternal) public var showInstallmentAmount: Swift.Bool { get set }
```
```javascript
// Parent: InstallmentConfiguration
public init(cardBasedOptions: [Adyen.CardType : Adyen.InstallmentOptions], defaultOptions: Adyen.InstallmentOptions, showInstallmentAmount: Swift.Bool = $DEFAULT_ARG) -> Adyen.InstallmentConfiguration
```
```javascript
// Parent: InstallmentConfiguration
public init(cardBasedOptions: [Adyen.CardType : Adyen.InstallmentOptions], showInstallmentAmount: Swift.Bool = $DEFAULT_ARG) -> Adyen.InstallmentConfiguration
```
```javascript
// Parent: InstallmentConfiguration
public init(defaultOptions: Adyen.InstallmentOptions, showInstallmentAmount: Swift.Bool = $DEFAULT_ARG) -> Adyen.InstallmentConfiguration
```
```javascript
// Parent: InstallmentConfiguration
@_spi(AdyenInternal) public init(from: any Swift.Decoder) throws -> Adyen.InstallmentConfiguration
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol PaymentInitiable
```
```javascript
// Parent: PaymentInitiable
@_spi(AdyenInternal) public func initiatePayment<Self where Self : Adyen.PaymentInitiable>() -> Swift.Void
```
```javascript
// Parent: Root
public final class InstantPaymentComponent : AdyenContextAware, Component, PartialPaymentOrderAware, PaymentComponent, PaymentInitiable, PaymentMethodAware
```
```javascript
// Parent: InstantPaymentComponent
@_spi(AdyenInternal) public let context: Adyen.AdyenContext { get }
```
```javascript
// Parent: InstantPaymentComponent
public let paymentData: Adyen.PaymentComponentData { get }
```
```javascript
// Parent: InstantPaymentComponent
public let paymentMethod: any Adyen.PaymentMethod { get }
```
```javascript
// Parent: InstantPaymentComponent
public weak var delegate: (any Adyen.PaymentComponentDelegate)? { get set }
```
```javascript
// Parent: InstantPaymentComponent
public init(paymentMethod: any Adyen.PaymentMethod, context: Adyen.AdyenContext, paymentData: Adyen.PaymentComponentData) -> Adyen.InstantPaymentComponent
```
```javascript
// Parent: InstantPaymentComponent
public init(paymentMethod: any Adyen.PaymentMethod, context: Adyen.AdyenContext, order: Adyen.PartialPaymentOrder?) -> Adyen.InstantPaymentComponent
```
```javascript
// Parent: InstantPaymentComponent
public func initiatePayment() -> Swift.Void
```
```javascript
// Parent: Root
public struct InstantPaymentDetails : Details, Encodable, OpaqueEncodable, PaymentMethodDetails
```
```javascript
// Parent: InstantPaymentDetails
@_spi(AdyenInternal) public var checkoutAttemptId: Swift.String? { get set }
```
```javascript
// Parent: InstantPaymentDetails
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: InstantPaymentDetails
public init(type: Adyen.PaymentMethodType) -> Adyen.InstantPaymentDetails
```
```javascript
// Parent: InstantPaymentDetails
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Root
public final class StoredPaymentMethodComponent : AdyenContextAware, Component, PartialPaymentOrderAware, PaymentAware, PaymentComponent, PaymentMethodAware, PresentableComponent, TrackableComponent
```
```javascript
// Parent: StoredPaymentMethodComponent
public var configuration: Adyen.StoredPaymentMethodComponent.Configuration { get set }
```
```javascript
// Parent: StoredPaymentMethodComponent
public let context: Adyen.AdyenContext { get }
```
```javascript
// Parent: StoredPaymentMethodComponent
public var paymentMethod: any Adyen.PaymentMethod { get }
```
```javascript
// Parent: StoredPaymentMethodComponent
public weak var delegate: (any Adyen.PaymentComponentDelegate)? { get set }
```
```javascript
// Parent: StoredPaymentMethodComponent
public init(paymentMethod: any Adyen.StoredPaymentMethod, context: Adyen.AdyenContext, configuration: Adyen.StoredPaymentMethodComponent.Configuration = $DEFAULT_ARG) -> Adyen.StoredPaymentMethodComponent
```
```javascript
// Parent: StoredPaymentMethodComponent
public lazy var viewController: UIKit.UIViewController { get set }
```
```javascript
// Parent: StoredPaymentMethodComponent
public struct Configuration : AnyBasicComponentConfiguration, Localizable
```
```javascript
// Parent: StoredPaymentMethodComponent.Configuration
public var localizationParameters: Adyen.LocalizationParameters? { get set }
```
```javascript
// Parent: StoredPaymentMethodComponent.Configuration
public init(localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG) -> Adyen.StoredPaymentMethodComponent.Configuration
```
```javascript
// Parent: Root
public struct StoredPaymentDetails : Details, Encodable, OpaqueEncodable, PaymentMethodDetails
```
```javascript
// Parent: StoredPaymentDetails
@_spi(AdyenInternal) public var checkoutAttemptId: Swift.String? { get set }
```
```javascript
// Parent: StoredPaymentDetails
public init(paymentMethod: any Adyen.StoredPaymentMethod) -> Adyen.StoredPaymentDetails
```
```javascript
// Parent: StoredPaymentDetails
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Root
public protocol ActionComponent<Self : Adyen.Component> : AdyenContextAware, Component
```
```javascript
// Parent: ActionComponent
public var delegate: (any Adyen.ActionComponentDelegate)? { get set }
```
```javascript
// Parent: Root
public protocol ActionComponentDelegate<Self : AnyObject>
```
```javascript
// Parent: ActionComponentDelegate
public func didOpenExternalApplication<Self where Self : Adyen.ActionComponentDelegate>(component: any Adyen.ActionComponent) -> Swift.Void
```
```javascript
// Parent: ActionComponentDelegate
public func didProvide<Self where Self : Adyen.ActionComponentDelegate>(_: Adyen.ActionComponentData, from: any Adyen.ActionComponent) -> Swift.Void
```
```javascript
// Parent: ActionComponentDelegate
public func didComplete<Self where Self : Adyen.ActionComponentDelegate>(from: any Adyen.ActionComponent) -> Swift.Void
```
```javascript
// Parent: ActionComponentDelegate
public func didFail<Self where Self : Adyen.ActionComponentDelegate>(with: any Swift.Error, from: any Adyen.ActionComponent) -> Swift.Void
```
```javascript
// Parent: ActionComponentDelegate
public func didOpenExternalApplication<Self where Self : Adyen.ActionComponentDelegate>(component: any Adyen.ActionComponent) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol AdyenSessionAware
```
```javascript
// Parent: AdyenSessionAware
@_spi(AdyenInternal) public var isSession: Swift.Bool { get }
```
```javascript
// Parent: Root
public protocol AnyDropInComponent<Self : Adyen.PresentableComponent> : AdyenContextAware, Component, PresentableComponent
```
```javascript
// Parent: AnyDropInComponent
public var delegate: (any Adyen.DropInComponentDelegate)? { get set }
```
```javascript
// Parent: AnyDropInComponent
public func reload<Self where Self : Adyen.AnyDropInComponent>(with: Adyen.PartialPaymentOrder, _: Adyen.PaymentMethods) throws -> Swift.Void
```
```javascript
// Parent: Root
public protocol Component<Self : Adyen.AdyenContextAware> : AdyenContextAware
```
```javascript
// Parent: Component
public func finalizeIfNeeded<Self where Self : Adyen.Component>(with: Swift.Bool, completion: (() -> Swift.Void)?) -> Swift.Void
```
```javascript
// Parent: Component
public func cancelIfNeeded<Self where Self : Adyen.Component>() -> Swift.Void
```
```javascript
// Parent: Component
public func stopLoadingIfNeeded<Self where Self : Adyen.Component>() -> Swift.Void
```
```javascript
// Parent: Component
@_spi(AdyenInternal) public var _isDropIn: Swift.Bool { get set }
```
```javascript
// Parent: Root
public protocol FinalizableComponent<Self : Adyen.Component> : AdyenContextAware, Component
```
```javascript
// Parent: FinalizableComponent
public func didFinalize<Self where Self : Adyen.FinalizableComponent>(with: Swift.Bool, completion: (() -> Swift.Void)?) -> Swift.Void
```
```javascript
// Parent: Root
public protocol Details<Self : Adyen.OpaqueEncodable> : Encodable, OpaqueEncodable
```
```javascript
// Parent: Root
public protocol PaymentMethodDetails<Self : Adyen.Details> : Details, Encodable, OpaqueEncodable
```
```javascript
// Parent: PaymentMethodDetails
@_spi(AdyenInternal) public var checkoutAttemptId: Swift.String? { get set }
```
```javascript
// Parent: PaymentMethodDetails
@_spi(AdyenInternal) public var checkoutAttemptId: Swift.String? { get set }
```
```javascript
// Parent: Root
public protocol AdditionalDetails<Self : Adyen.Details> : Details, Encodable, OpaqueEncodable
```
```javascript
// Parent: Root
public protocol DeviceDependent
```
```javascript
// Parent: DeviceDependent
public static func isDeviceSupported<Self where Self : Adyen.DeviceDependent>() -> Swift.Bool
```
```javascript
// Parent: Root
public protocol DropInComponentDelegate<Self : AnyObject>
```
```javascript
// Parent: DropInComponentDelegate
public func didSubmit<Self where Self : Adyen.DropInComponentDelegate>(_: Adyen.PaymentComponentData, from: any Adyen.PaymentComponent, in: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
// Parent: DropInComponentDelegate
public func didFail<Self where Self : Adyen.DropInComponentDelegate>(with: any Swift.Error, from: any Adyen.PaymentComponent, in: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
// Parent: DropInComponentDelegate
public func didProvide<Self where Self : Adyen.DropInComponentDelegate>(_: Adyen.ActionComponentData, from: any Adyen.ActionComponent, in: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
// Parent: DropInComponentDelegate
public func didComplete<Self where Self : Adyen.DropInComponentDelegate>(from: any Adyen.ActionComponent, in: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
// Parent: DropInComponentDelegate
public func didFail<Self where Self : Adyen.DropInComponentDelegate>(with: any Swift.Error, from: any Adyen.ActionComponent, in: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
// Parent: DropInComponentDelegate
public func didOpenExternalApplication<Self where Self : Adyen.DropInComponentDelegate>(component: any Adyen.ActionComponent, in: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
// Parent: DropInComponentDelegate
public func didFail<Self where Self : Adyen.DropInComponentDelegate>(with: any Swift.Error, from: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
// Parent: DropInComponentDelegate
public func didCancel<Self where Self : Adyen.DropInComponentDelegate>(component: any Adyen.PaymentComponent, from: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
// Parent: DropInComponentDelegate
public func didCancel<Self where Self : Adyen.DropInComponentDelegate>(component: any Adyen.PaymentComponent, from: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
// Parent: DropInComponentDelegate
public func didOpenExternalApplication<Self where Self : Adyen.DropInComponentDelegate>(component: any Adyen.ActionComponent, in: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
// Parent: Root
public protocol ComponentLoader<Self : Adyen.LoadingComponent> : LoadingComponent
```
```javascript
// Parent: ComponentLoader
public func startLoading<Self where Self : Adyen.ComponentLoader>(for: any Adyen.PaymentComponent) -> Swift.Void
```
```javascript
// Parent: Root
public protocol LoadingComponent
```
```javascript
// Parent: LoadingComponent
public func stopLoading<Self where Self : Adyen.LoadingComponent>() -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol PartialPaymentComponent<Self : Adyen.PaymentComponent> : AdyenContextAware, Component, PartialPaymentOrderAware, PaymentComponent, PaymentMethodAware
```
```javascript
// Parent: PartialPaymentComponent
@_spi(AdyenInternal) public var partialPaymentDelegate: (any Adyen.PartialPaymentDelegate)? { get set }
```
```javascript
// Parent: PartialPaymentComponent
@_spi(AdyenInternal) public var readyToSubmitComponentDelegate: (any Adyen.ReadyToSubmitPaymentComponentDelegate)? { get set }
```
```javascript
// Parent: Root
public protocol PartialPaymentDelegate<Self : AnyObject>
```
```javascript
// Parent: PartialPaymentDelegate
public func checkBalance<Self where Self : Adyen.PartialPaymentDelegate>(with: Adyen.PaymentComponentData, component: any Adyen.Component, completion: (Swift.Result<Adyen.Balance, any Swift.Error>) -> Swift.Void) -> Swift.Void
```
```javascript
// Parent: PartialPaymentDelegate
public func requestOrder<Self where Self : Adyen.PartialPaymentDelegate>(for: any Adyen.Component, completion: (Swift.Result<Adyen.PartialPaymentOrder, any Swift.Error>) -> Swift.Void) -> Swift.Void
```
```javascript
// Parent: PartialPaymentDelegate
public func cancelOrder<Self where Self : Adyen.PartialPaymentDelegate>(_: Adyen.PartialPaymentOrder, component: any Adyen.Component) -> Swift.Void
```
```javascript
// Parent: Root
public protocol PartialPaymentOrderAware
```
```javascript
// Parent: PartialPaymentOrderAware
public var order: Adyen.PartialPaymentOrder? { get set }
```
```javascript
// Parent: PartialPaymentOrderAware
@_spi(AdyenInternal) public var order: Adyen.PartialPaymentOrder? { get set }
```
```javascript
// Parent: Root
public protocol PaymentAware
```
```javascript
// Parent: PaymentAware
public var payment: Adyen.Payment? { get }
```
```javascript
// Parent: Root
public protocol PaymentMethodAware
```
```javascript
// Parent: PaymentMethodAware
public var paymentMethod: any Adyen.PaymentMethod { get }
```
```javascript
// Parent: Root
public protocol PaymentComponent<Self : Adyen.Component, Self : Adyen.PartialPaymentOrderAware, Self : Adyen.PaymentMethodAware> : AdyenContextAware, Component, PartialPaymentOrderAware, PaymentMethodAware
```
```javascript
// Parent: PaymentComponent
public var delegate: (any Adyen.PaymentComponentDelegate)? { get set }
```
```javascript
// Parent: PaymentComponent
@_spi(AdyenInternal) public func submit<Self where Self : Adyen.PaymentComponent>(data: Adyen.PaymentComponentData, component: (any Adyen.PaymentComponent)? = $DEFAULT_ARG) -> Swift.Void
```
```javascript
// Parent: Root
public protocol PaymentComponentDelegate<Self : AnyObject>
```
```javascript
// Parent: PaymentComponentDelegate
public func didSubmit<Self where Self : Adyen.PaymentComponentDelegate>(_: Adyen.PaymentComponentData, from: any Adyen.PaymentComponent) -> Swift.Void
```
```javascript
// Parent: PaymentComponentDelegate
public func didFail<Self where Self : Adyen.PaymentComponentDelegate>(with: any Swift.Error, from: any Adyen.PaymentComponent) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol PaymentComponentBuilder<Self : Adyen.AdyenContextAware> : AdyenContextAware
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.StoredCardPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: any Adyen.StoredPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.StoredBCMCPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.StoredACHDirectDebitPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.CardPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.BCMCPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.IssuerListPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.SEPADirectDebitPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.BACSDirectDebitPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.ACHDirectDebitPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.ApplePayPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.WeChatPayPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.QiwiWalletPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.MBWayPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.BLIKPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.DokuPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.EContextPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.GiftCardPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.MealVoucherPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.BoletoPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.AffirmPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.AtomePaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.OnlineBankingPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.UPIPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.CashAppPayPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.StoredCashAppPayPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.TwintPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentComponentBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: any Adyen.PaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: Root
public protocol PaymentMethod<Self : Swift.Decodable, Self : Swift.Encodable> : Decodable, Encodable
```
```javascript
// Parent: PaymentMethod
public var type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: PaymentMethod
public var name: Swift.String { get }
```
```javascript
// Parent: PaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: PaymentMethod
@_spi(AdyenInternal) public func defaultDisplayInformation<Self where Self : Adyen.PaymentMethod>(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
// Parent: PaymentMethod
@_spi(AdyenInternal) public func buildComponent<Self where Self : Adyen.PaymentMethod>(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentMethod
@_spi(AdyenInternal) public func buildComponent<Self where Self : Adyen.PaymentMethod>(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: PaymentMethod
@_spi(AdyenInternal) public func displayInformation<Self where Self : Adyen.PaymentMethod>(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
// Parent: PaymentMethod
@_spi(AdyenInternal) public func defaultDisplayInformation<Self where Self : Adyen.PaymentMethod>(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
// Parent: Root
public protocol PartialPaymentMethod<Self : Adyen.PaymentMethod> : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: Root
public protocol StoredPaymentMethod<Self : Adyen.PaymentMethod> : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: StoredPaymentMethod
public var identifier: Swift.String { get }
```
```javascript
// Parent: StoredPaymentMethod
public var supportedShopperInteractions: [Adyen.ShopperInteraction] { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public func ==(_: any Adyen.StoredPaymentMethod, _: any Adyen.StoredPaymentMethod) -> Swift.Bool
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public func !=(_: any Adyen.StoredPaymentMethod, _: any Adyen.StoredPaymentMethod) -> Swift.Bool
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public func ==(_: any Adyen.PaymentMethod, _: any Adyen.PaymentMethod) -> Swift.Bool
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public func !=(_: any Adyen.PaymentMethod, _: any Adyen.PaymentMethod) -> Swift.Bool
```
```javascript
// Parent: Root
public protocol Localizable
```
```javascript
// Parent: Localizable
public var localizationParameters: Adyen.LocalizationParameters? { get set }
```
```javascript
// Parent: Root
public protocol Cancellable<Self : AnyObject>
```
```javascript
// Parent: Cancellable
public func didCancel<Self where Self : Adyen.Cancellable>() -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol AnyNavigationBar<Self : UIKit.UIView>
```
```javascript
// Parent: AnyNavigationBar
@_spi(AdyenInternal) public var onCancelHandler: (() -> Swift.Void)? { get set }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum NavigationBarType
```
```javascript
// Parent: NavigationBarType
@_spi(AdyenInternal) public case regular
```
```javascript
// Parent: NavigationBarType
@_spi(AdyenInternal) public case custom(any Adyen.AnyNavigationBar)
```
```javascript
// Parent: Root
public protocol PresentableComponent<Self : Adyen.Component> : AdyenContextAware, Component
```
```javascript
// Parent: PresentableComponent
public var requiresModalPresentation: Swift.Bool { get }
```
```javascript
// Parent: PresentableComponent
public var viewController: UIKit.UIViewController { get }
```
```javascript
// Parent: PresentableComponent
@_spi(AdyenInternal) public var navBarType: Adyen.NavigationBarType { get }
```
```javascript
// Parent: PresentableComponent
@_spi(AdyenInternal) public var requiresModalPresentation: Swift.Bool { get }
```
```javascript
// Parent: PresentableComponent
@_spi(AdyenInternal) public var navBarType: Adyen.NavigationBarType { get }
```
```javascript
// Parent: Root
public protocol PresentationDelegate<Self : AnyObject>
```
```javascript
// Parent: PresentationDelegate
public func present<Self where Self : Adyen.PresentationDelegate>(component: any Adyen.PresentableComponent) -> Swift.Void
```
```javascript
// Parent: Root
public protocol ReadyToSubmitPaymentComponentDelegate<Self : AnyObject>
```
```javascript
// Parent: ReadyToSubmitPaymentComponentDelegate
public func showConfirmation<Self where Self : Adyen.ReadyToSubmitPaymentComponentDelegate>(for: Adyen.InstantPaymentComponent, with: Adyen.PartialPaymentOrder?) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol StorePaymentMethodFieldAware<Self : Adyen.AdyenSessionAware> : AdyenSessionAware
```
```javascript
// Parent: StorePaymentMethodFieldAware
@_spi(AdyenInternal) public var showStorePaymentMethodField: Swift.Bool? { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol SessionStoredPaymentMethodsDelegate<Self : Adyen.AdyenSessionAware, Self : Adyen.StoredPaymentMethodsDelegate> : AdyenSessionAware, StoredPaymentMethodsDelegate
```
```javascript
// Parent: SessionStoredPaymentMethodsDelegate
@_spi(AdyenInternal) public var showRemovePaymentMethodButton: Swift.Bool { get }
```
```javascript
// Parent: SessionStoredPaymentMethodsDelegate
@_spi(AdyenInternal) public func disable<Self where Self : Adyen.SessionStoredPaymentMethodsDelegate>(storedPaymentMethod: any Adyen.StoredPaymentMethod, dropInComponent: any Adyen.AnyDropInComponent, completion: Adyen.Completion<Swift.Bool>) -> Swift.Void
```
```javascript
// Parent: Root
public protocol StoredPaymentMethodsDelegate<Self : AnyObject>
```
```javascript
// Parent: StoredPaymentMethodsDelegate
public func disable<Self where Self : Adyen.StoredPaymentMethodsDelegate>(storedPaymentMethod: any Adyen.StoredPaymentMethod, completion: Adyen.Completion<Swift.Bool>) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol TrackableComponent<Self : Adyen.Component> : AdyenContextAware, Component
```
```javascript
// Parent: TrackableComponent
@_spi(AdyenInternal) public var analyticsFlavor: Adyen.AnalyticsFlavor { get }
```
```javascript
// Parent: TrackableComponent
@_spi(AdyenInternal) public func sendInitialAnalytics<Self where Self : Adyen.TrackableComponent>() -> Swift.Void
```
```javascript
// Parent: TrackableComponent
@_spi(AdyenInternal) public func sendDidLoadEvent<Self where Self : Adyen.TrackableComponent>() -> Swift.Void
```
```javascript
// Parent: TrackableComponent
@_spi(AdyenInternal) public func viewDidLoad<Self where Self : Adyen.TrackableComponent, Self : Adyen.ViewControllerDelegate>(viewController: UIKit.UIViewController) -> Swift.Void
```
```javascript
// Parent: TrackableComponent
@_spi(AdyenInternal) public func sendInitialAnalytics<Self where Self : Adyen.TrackableComponent>() -> Swift.Void
```
```javascript
// Parent: TrackableComponent
@_spi(AdyenInternal) public var analyticsFlavor: Adyen.AnalyticsFlavor { get }
```
```javascript
// Parent: TrackableComponent
@_spi(AdyenInternal) public func sendDidLoadEvent<Self where Self : Adyen.PaymentMethodAware, Self : Adyen.TrackableComponent>() -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol ViewControllerPresenter<Self : AnyObject>
```
```javascript
// Parent: ViewControllerPresenter
@_spi(AdyenInternal) public func presentViewController<Self where Self : Adyen.ViewControllerPresenter>(_: UIKit.UIViewController, animated: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: ViewControllerPresenter
@_spi(AdyenInternal) public func dismissViewController<Self where Self : Adyen.ViewControllerPresenter>(animated: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public class WeakReferenceViewControllerPresenter : ViewControllerPresenter
```
```javascript
// Parent: WeakReferenceViewControllerPresenter
@_spi(AdyenInternal) public init(_: any Adyen.ViewControllerPresenter) -> Adyen.WeakReferenceViewControllerPresenter
```
```javascript
// Parent: WeakReferenceViewControllerPresenter
@_spi(AdyenInternal) public func presentViewController(_: UIKit.UIViewController, animated: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: WeakReferenceViewControllerPresenter
@_spi(AdyenInternal) public func dismissViewController(animated: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct APIError : Decodable, Error, ErrorResponse, LocalizedError, Response, Sendable
```
```javascript
// Parent: APIError
@_spi(AdyenInternal) public let status: Swift.Int? { get }
```
```javascript
// Parent: APIError
@_spi(AdyenInternal) public let errorCode: Swift.String { get }
```
```javascript
// Parent: APIError
@_spi(AdyenInternal) public let errorMessage: Swift.String { get }
```
```javascript
// Parent: APIError
@_spi(AdyenInternal) public let type: Adyen.APIErrorType { get }
```
```javascript
// Parent: APIError
@_spi(AdyenInternal) public var errorDescription: Swift.String? { get }
```
```javascript
// Parent: APIError
@_spi(AdyenInternal) public init(from: any Swift.Decoder) throws -> Adyen.APIError
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum APIErrorType : Decodable, Equatable, Hashable, RawRepresentable
```
```javascript
// Parent: APIErrorType
@_spi(AdyenInternal) public case internal
```
```javascript
// Parent: APIErrorType
@_spi(AdyenInternal) public case validation
```
```javascript
// Parent: APIErrorType
@_spi(AdyenInternal) public case security
```
```javascript
// Parent: APIErrorType
@_spi(AdyenInternal) public case configuration
```
```javascript
// Parent: APIErrorType
@_spi(AdyenInternal) public case urlError
```
```javascript
// Parent: APIErrorType
@_spi(AdyenInternal) public case noInternet
```
```javascript
// Parent: APIErrorType
@_spi(AdyenInternal) public case sessionExpired
```
```javascript
// Parent: APIErrorType
@_spi(AdyenInternal) @inlinable public init(rawValue: Swift.String) -> Adyen.APIErrorType?
```
```javascript
// Parent: APIErrorType
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
// Parent: APIErrorType
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
// Parent: Root
public enum AppleWalletError : Equatable, Error, Hashable, LocalizedError, Sendable
```
```javascript
// Parent: AppleWalletError
public case failedToAddToAppleWallet
```
```javascript
// Parent: AppleWalletError
public static func __derived_enum_equals(_: Adyen.AppleWalletError, _: Adyen.AppleWalletError) -> Swift.Bool
```
```javascript
// Parent: AppleWalletError
public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: AppleWalletError
public var hashValue: Swift.Int { get }
```
```javascript
// Parent: Root
public enum ComponentError : Equatable, Error, Hashable, Sendable
```
```javascript
// Parent: ComponentError
public case cancelled
```
```javascript
// Parent: ComponentError
public case paymentMethodNotSupported
```
```javascript
// Parent: ComponentError
public static func __derived_enum_equals(_: Adyen.ComponentError, _: Adyen.ComponentError) -> Swift.Bool
```
```javascript
// Parent: ComponentError
public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: ComponentError
public var hashValue: Swift.Int { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct UnknownError : Error, LocalizedError, Sendable
```
```javascript
// Parent: UnknownError
@_spi(AdyenInternal) public var errorDescription: Swift.String? { get set }
```
```javascript
// Parent: UnknownError
@_spi(AdyenInternal) public init(errorDescription: Swift.String? = $DEFAULT_ARG) -> Adyen.UnknownError
```
```javascript
// Parent: Root
public enum CardType : Decodable, Encodable, Equatable, Hashable, RawRepresentable
```
```javascript
// Parent: CardType
public case accel
```
```javascript
// Parent: CardType
public case alphaBankBonusMasterCard
```
```javascript
// Parent: CardType
public case alphaBankBonusVISA
```
```javascript
// Parent: CardType
public case argencard
```
```javascript
// Parent: CardType
public case americanExpress
```
```javascript
// Parent: CardType
public case bcmc
```
```javascript
// Parent: CardType
public case bijenkorfCard
```
```javascript
// Parent: CardType
public case cabal
```
```javascript
// Parent: CardType
public case carteBancaire
```
```javascript
// Parent: CardType
public case cencosud
```
```javascript
// Parent: CardType
public case chequeDejeneur
```
```javascript
// Parent: CardType
public case chinaUnionPay
```
```javascript
// Parent: CardType
public case codensa
```
```javascript
// Parent: CardType
public case creditUnion24
```
```javascript
// Parent: CardType
public case dankort
```
```javascript
// Parent: CardType
public case dankortVISA
```
```javascript
// Parent: CardType
public case diners
```
```javascript
// Parent: CardType
public case discover
```
```javascript
// Parent: CardType
public case elo
```
```javascript
// Parent: CardType
public case forbrugsforeningen
```
```javascript
// Parent: CardType
public case hiper
```
```javascript
// Parent: CardType
public case hipercard
```
```javascript
// Parent: CardType
public case jcb
```
```javascript
// Parent: CardType
public case karenMillen
```
```javascript
// Parent: CardType
public case kcp
```
```javascript
// Parent: CardType
public case koreanLocalCard
```
```javascript
// Parent: CardType
public case laser
```
```javascript
// Parent: CardType
public case maestro
```
```javascript
// Parent: CardType
public case maestroUK
```
```javascript
// Parent: CardType
public case masterCard
```
```javascript
// Parent: CardType
public case mir
```
```javascript
// Parent: CardType
public case naranja
```
```javascript
// Parent: CardType
public case netplus
```
```javascript
// Parent: CardType
public case nyce
```
```javascript
// Parent: CardType
public case oasis
```
```javascript
// Parent: CardType
public case pulse
```
```javascript
// Parent: CardType
public case shopping
```
```javascript
// Parent: CardType
public case solo
```
```javascript
// Parent: CardType
public case star
```
```javascript
// Parent: CardType
public case troy
```
```javascript
// Parent: CardType
public case uatp
```
```javascript
// Parent: CardType
public case visa
```
```javascript
// Parent: CardType
public case warehouse
```
```javascript
// Parent: CardType
public case other(named: Swift.String)
```
```javascript
// Parent: CardType
public init(rawValue: Swift.String) -> Adyen.CardType
```
```javascript
// Parent: CardType
public var rawValue: Swift.String { get }
```
```javascript
// Parent: CardType
@_spi(AdyenInternal) public var name: Swift.String { get }
```
```javascript
// Parent: CardType
public typealias RawValue = Swift.String
```
```javascript
// Parent: CardType
@_spi(AdyenInternal) public func matches(cardNumber: Swift.String) -> Swift.Bool
```
```javascript
// Parent: Root
public struct DisplayInformation : Equatable
```
```javascript
// Parent: DisplayInformation
public let title: Swift.String { get }
```
```javascript
// Parent: DisplayInformation
public let subtitle: Swift.String? { get }
```
```javascript
// Parent: DisplayInformation
@_spi(AdyenInternal) public let logoName: Swift.String { get }
```
```javascript
// Parent: DisplayInformation
@_spi(AdyenInternal) public let disclosureText: Swift.String? { get }
```
```javascript
// Parent: DisplayInformation
@_spi(AdyenInternal) public let footnoteText: Swift.String? { get }
```
```javascript
// Parent: DisplayInformation
@_spi(AdyenInternal) public let accessibilityLabel: Swift.String? { get }
```
```javascript
// Parent: DisplayInformation
public init(title: Swift.String, subtitle: Swift.String?, logoName: Swift.String, disclosureText: Swift.String? = $DEFAULT_ARG, footnoteText: Swift.String? = $DEFAULT_ARG, accessibilityLabel: Swift.String? = $DEFAULT_ARG) -> Adyen.DisplayInformation
```
```javascript
// Parent: DisplayInformation
public static func __derived_struct_equals(_: Adyen.DisplayInformation, _: Adyen.DisplayInformation) -> Swift.Bool
```
```javascript
// Parent: Root
public struct MerchantCustomDisplayInformation
```
```javascript
// Parent: MerchantCustomDisplayInformation
public let title: Swift.String { get }
```
```javascript
// Parent: MerchantCustomDisplayInformation
public let subtitle: Swift.String? { get }
```
```javascript
// Parent: MerchantCustomDisplayInformation
public init(title: Swift.String, subtitle: Swift.String? = $DEFAULT_ARG) -> Adyen.MerchantCustomDisplayInformation
```
```javascript
// Parent: Root
public enum ShopperInteraction : Decodable, Encodable, Equatable, Hashable, RawRepresentable
```
```javascript
// Parent: ShopperInteraction
public case shopperPresent
```
```javascript
// Parent: ShopperInteraction
public case shopperNotPresent
```
```javascript
// Parent: ShopperInteraction
@inlinable public init(rawValue: Swift.String) -> Adyen.ShopperInteraction?
```
```javascript
// Parent: ShopperInteraction
public typealias RawValue = Swift.String
```
```javascript
// Parent: ShopperInteraction
public var rawValue: Swift.String { get }
```
```javascript
// Parent: Root
public struct ACHDirectDebitPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: ACHDirectDebitPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: ACHDirectDebitPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: ACHDirectDebitPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: ACHDirectDebitPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: ACHDirectDebitPaymentMethod
@_spi(AdyenInternal) public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
// Parent: ACHDirectDebitPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: ACHDirectDebitPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.ACHDirectDebitPaymentMethod
```
```javascript
// Parent: Root
public struct StoredACHDirectDebitPaymentMethod : Decodable, Encodable, PaymentMethod, StoredPaymentMethod
```
```javascript
// Parent: StoredACHDirectDebitPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: StoredACHDirectDebitPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: StoredACHDirectDebitPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: StoredACHDirectDebitPaymentMethod
public let identifier: Swift.String { get }
```
```javascript
// Parent: StoredACHDirectDebitPaymentMethod
public let supportedShopperInteractions: [Adyen.ShopperInteraction] { get }
```
```javascript
// Parent: StoredACHDirectDebitPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: StoredACHDirectDebitPaymentMethod
@_spi(AdyenInternal) public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
// Parent: StoredACHDirectDebitPaymentMethod
public let bankAccountNumber: Swift.String { get }
```
```javascript
// Parent: StoredACHDirectDebitPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: StoredACHDirectDebitPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.StoredACHDirectDebitPaymentMethod
```
```javascript
// Parent: Root
public protocol AnyCardPaymentMethod<Self : Adyen.PaymentMethod> : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: AnyCardPaymentMethod
public var brands: [Adyen.CardType] { get }
```
```javascript
// Parent: AnyCardPaymentMethod
public var fundingSource: Adyen.CardFundingSource? { get }
```
```javascript
// Parent: Root
public enum CardFundingSource : Decodable, Encodable, Equatable, Hashable, RawRepresentable
```
```javascript
// Parent: CardFundingSource
public case debit
```
```javascript
// Parent: CardFundingSource
public case credit
```
```javascript
// Parent: CardFundingSource
@inlinable public init(rawValue: Swift.String) -> Adyen.CardFundingSource?
```
```javascript
// Parent: CardFundingSource
public typealias RawValue = Swift.String
```
```javascript
// Parent: CardFundingSource
public var rawValue: Swift.String { get }
```
```javascript
// Parent: Root
public enum PaymentMethodType : Decodable, Encodable, Equatable, Hashable, RawRepresentable
```
```javascript
// Parent: PaymentMethodType
public case card
```
```javascript
// Parent: PaymentMethodType
public case scheme
```
```javascript
// Parent: PaymentMethodType
public case ideal
```
```javascript
// Parent: PaymentMethodType
public case entercash
```
```javascript
// Parent: PaymentMethodType
public case eps
```
```javascript
// Parent: PaymentMethodType
public case dotpay
```
```javascript
// Parent: PaymentMethodType
public case onlineBankingPoland
```
```javascript
// Parent: PaymentMethodType
public case openBankingUK
```
```javascript
// Parent: PaymentMethodType
public case molPayEBankingFPXMY
```
```javascript
// Parent: PaymentMethodType
public case molPayEBankingTH
```
```javascript
// Parent: PaymentMethodType
public case molPayEBankingVN
```
```javascript
// Parent: PaymentMethodType
public case sepaDirectDebit
```
```javascript
// Parent: PaymentMethodType
public case applePay
```
```javascript
// Parent: PaymentMethodType
public case payPal
```
```javascript
// Parent: PaymentMethodType
public case bcmc
```
```javascript
// Parent: PaymentMethodType
public case bcmcMobile
```
```javascript
// Parent: PaymentMethodType
public case qiwiWallet
```
```javascript
// Parent: PaymentMethodType
public case weChatPaySDK
```
```javascript
// Parent: PaymentMethodType
public case mbWay
```
```javascript
// Parent: PaymentMethodType
public case blik
```
```javascript
// Parent: PaymentMethodType
public case dokuWallet
```
```javascript
// Parent: PaymentMethodType
public case dokuAlfamart
```
```javascript
// Parent: PaymentMethodType
public case dokuIndomaret
```
```javascript
// Parent: PaymentMethodType
public case giftcard
```
```javascript
// Parent: PaymentMethodType
public case doku
```
```javascript
// Parent: PaymentMethodType
public case econtextSevenEleven
```
```javascript
// Parent: PaymentMethodType
public case econtextStores
```
```javascript
// Parent: PaymentMethodType
public case econtextATM
```
```javascript
// Parent: PaymentMethodType
public case econtextOnline
```
```javascript
// Parent: PaymentMethodType
public case boleto
```
```javascript
// Parent: PaymentMethodType
public case affirm
```
```javascript
// Parent: PaymentMethodType
public case oxxo
```
```javascript
// Parent: PaymentMethodType
public case bacsDirectDebit
```
```javascript
// Parent: PaymentMethodType
public case achDirectDebit
```
```javascript
// Parent: PaymentMethodType
public case multibanco
```
```javascript
// Parent: PaymentMethodType
public case atome
```
```javascript
// Parent: PaymentMethodType
public case onlineBankingCZ
```
```javascript
// Parent: PaymentMethodType
public case onlineBankingSK
```
```javascript
// Parent: PaymentMethodType
public case mealVoucherNatixis
```
```javascript
// Parent: PaymentMethodType
public case mealVoucherGroupeUp
```
```javascript
// Parent: PaymentMethodType
public case mealVoucherSodexo
```
```javascript
// Parent: PaymentMethodType
public case upi
```
```javascript
// Parent: PaymentMethodType
public case cashAppPay
```
```javascript
// Parent: PaymentMethodType
public case twint
```
```javascript
// Parent: PaymentMethodType
public case other(Swift.String)
```
```javascript
// Parent: PaymentMethodType
public case bcmcMobileQR
```
```javascript
// Parent: PaymentMethodType
public case weChatMiniProgram
```
```javascript
// Parent: PaymentMethodType
public case weChatQR
```
```javascript
// Parent: PaymentMethodType
public case weChatPayWeb
```
```javascript
// Parent: PaymentMethodType
public case googlePay
```
```javascript
// Parent: PaymentMethodType
public case afterpay
```
```javascript
// Parent: PaymentMethodType
public case androidPay
```
```javascript
// Parent: PaymentMethodType
public case amazonPay
```
```javascript
// Parent: PaymentMethodType
public case upiCollect
```
```javascript
// Parent: PaymentMethodType
public case upiIntent
```
```javascript
// Parent: PaymentMethodType
public case upiQr
```
```javascript
// Parent: PaymentMethodType
public case bizum
```
```javascript
// Parent: PaymentMethodType
public init(rawValue: Swift.String) -> Adyen.PaymentMethodType?
```
```javascript
// Parent: PaymentMethodType
public var rawValue: Swift.String { get }
```
```javascript
// Parent: PaymentMethodType
public typealias RawValue = Swift.String
```
```javascript
// Parent: PaymentMethodType
@_spi(AdyenInternal) public var name: Swift.String { get }
```
```javascript
// Parent: Root
public struct PaymentMethods : Decodable, Encodable
```
```javascript
// Parent: PaymentMethods
public var paid: [any Adyen.PaymentMethod] { get set }
```
```javascript
// Parent: PaymentMethods
public var regular: [any Adyen.PaymentMethod] { get set }
```
```javascript
// Parent: PaymentMethods
public var stored: [any Adyen.StoredPaymentMethod] { get set }
```
```javascript
// Parent: PaymentMethods
public init(regular: [any Adyen.PaymentMethod], stored: [any Adyen.StoredPaymentMethod]) -> Adyen.PaymentMethods
```
```javascript
// Parent: PaymentMethods
public mutating func overrideDisplayInformation<T where T : Adyen.PaymentMethod>(ofStoredPaymentMethod: Adyen.PaymentMethodType, with: Adyen.MerchantCustomDisplayInformation, where: (T) -> Swift.Bool) -> Swift.Void
```
```javascript
// Parent: PaymentMethods
public mutating func overrideDisplayInformation(ofStoredPaymentMethod: Adyen.PaymentMethodType, with: Adyen.MerchantCustomDisplayInformation) -> Swift.Void
```
```javascript
// Parent: PaymentMethods
public mutating func overrideDisplayInformation<T where T : Adyen.PaymentMethod>(ofRegularPaymentMethod: Adyen.PaymentMethodType, with: Adyen.MerchantCustomDisplayInformation, where: (T) -> Swift.Bool) -> Swift.Void
```
```javascript
// Parent: PaymentMethods
public mutating func overrideDisplayInformation(ofRegularPaymentMethod: Adyen.PaymentMethodType, with: Adyen.MerchantCustomDisplayInformation) -> Swift.Void
```
```javascript
// Parent: PaymentMethods
public func paymentMethod<T where T : Adyen.PaymentMethod>(ofType: T.Type) -> T?
```
```javascript
// Parent: PaymentMethods
public func paymentMethod<T where T : Adyen.PaymentMethod>(ofType: T.Type, where: (T) -> Swift.Bool) -> T?
```
```javascript
// Parent: PaymentMethods
public func paymentMethod(ofType: Adyen.PaymentMethodType) -> (any Adyen.PaymentMethod)?
```
```javascript
// Parent: PaymentMethods
public func paymentMethod<T where T : Adyen.PaymentMethod>(ofType: Adyen.PaymentMethodType, where: (T) -> Swift.Bool) -> T?
```
```javascript
// Parent: PaymentMethods
public init(from: any Swift.Decoder) throws -> Adyen.PaymentMethods
```
```javascript
// Parent: PaymentMethods
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Root
public struct AffirmPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: AffirmPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: AffirmPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: AffirmPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: AffirmPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: AffirmPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: AffirmPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.AffirmPaymentMethod
```
```javascript
// Parent: Root
public struct ApplePayPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: ApplePayPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: ApplePayPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: ApplePayPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: ApplePayPaymentMethod
public let brands: [Swift.String]? { get }
```
```javascript
// Parent: ApplePayPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: ApplePayPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: ApplePayPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.ApplePayPaymentMethod
```
```javascript
// Parent: Root
public struct AtomePaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: AtomePaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: AtomePaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: AtomePaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: AtomePaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: AtomePaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: AtomePaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.AtomePaymentMethod
```
```javascript
// Parent: Root
public struct BACSDirectDebitPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: BACSDirectDebitPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: BACSDirectDebitPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: BACSDirectDebitPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: BACSDirectDebitPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: BACSDirectDebitPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: BACSDirectDebitPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.BACSDirectDebitPaymentMethod
```
```javascript
// Parent: Root
public struct BCMCPaymentMethod : AnyCardPaymentMethod, Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: BCMCPaymentMethod
public var type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: BCMCPaymentMethod
public var name: Swift.String { get }
```
```javascript
// Parent: BCMCPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: BCMCPaymentMethod
public var brands: [Adyen.CardType] { get }
```
```javascript
// Parent: BCMCPaymentMethod
public var fundingSource: Adyen.CardFundingSource? { get }
```
```javascript
// Parent: BCMCPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.BCMCPaymentMethod
```
```javascript
// Parent: BCMCPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: BCMCPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: Root
public struct BLIKPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: BLIKPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: BLIKPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: BLIKPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: BLIKPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: BLIKPaymentMethod
public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
// Parent: BLIKPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: BLIKPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.BLIKPaymentMethod
```
```javascript
// Parent: Root
public struct BoletoPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: BoletoPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: BoletoPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: BoletoPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: BoletoPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: BoletoPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: BoletoPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.BoletoPaymentMethod
```
```javascript
// Parent: Root
public struct CardPaymentMethod : AnyCardPaymentMethod, Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: CardPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: CardPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: CardPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: CardPaymentMethod
public let fundingSource: Adyen.CardFundingSource? { get }
```
```javascript
// Parent: CardPaymentMethod
public let brands: [Adyen.CardType] { get }
```
```javascript
// Parent: CardPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.CardPaymentMethod
```
```javascript
// Parent: CardPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: CardPaymentMethod
public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
// Parent: CardPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Root
public struct StoredCardPaymentMethod : AnyCardPaymentMethod, Decodable, Encodable, PaymentMethod, StoredPaymentMethod
```
```javascript
// Parent: StoredCardPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: StoredCardPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: StoredCardPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: StoredCardPaymentMethod
public let identifier: Swift.String { get }
```
```javascript
// Parent: StoredCardPaymentMethod
public var brands: [Adyen.CardType] { get }
```
```javascript
// Parent: StoredCardPaymentMethod
public var fundingSource: Adyen.CardFundingSource? { get set }
```
```javascript
// Parent: StoredCardPaymentMethod
public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
// Parent: StoredCardPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: StoredCardPaymentMethod
public let supportedShopperInteractions: [Adyen.ShopperInteraction] { get }
```
```javascript
// Parent: StoredCardPaymentMethod
public let brand: Adyen.CardType { get }
```
```javascript
// Parent: StoredCardPaymentMethod
public let lastFour: Swift.String { get }
```
```javascript
// Parent: StoredCardPaymentMethod
public let expiryMonth: Swift.String { get }
```
```javascript
// Parent: StoredCardPaymentMethod
public let expiryYear: Swift.String { get }
```
```javascript
// Parent: StoredCardPaymentMethod
public let holderName: Swift.String? { get }
```
```javascript
// Parent: StoredCardPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: StoredCardPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.StoredCardPaymentMethod
```
```javascript
// Parent: Root
public struct CashAppPayPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: CashAppPayPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: CashAppPayPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: CashAppPayPaymentMethod
public let clientId: Swift.String { get }
```
```javascript
// Parent: CashAppPayPaymentMethod
public let scopeId: Swift.String { get }
```
```javascript
// Parent: CashAppPayPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: CashAppPayPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.CashAppPayPaymentMethod
```
```javascript
// Parent: CashAppPayPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: CashAppPayPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: Root
public struct DokuPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: DokuPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: DokuPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: DokuPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: DokuPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: DokuPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: DokuPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.DokuPaymentMethod
```
```javascript
// Parent: Root
public typealias DokuWalletPaymentMethod = Adyen.DokuPaymentMethod
```
```javascript
// Parent: Root
public typealias AlfamartPaymentMethod = Adyen.DokuPaymentMethod
```
```javascript
// Parent: Root
public typealias IndomaretPaymentMethod = Adyen.DokuPaymentMethod
```
```javascript
// Parent: Root
public struct EContextPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: EContextPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: EContextPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: EContextPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: EContextPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: EContextPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: EContextPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.EContextPaymentMethod
```
```javascript
// Parent: Root
public typealias SevenElevenPaymentMethod = Adyen.EContextPaymentMethod
```
```javascript
// Parent: Root
public struct GiftCardPaymentMethod : Decodable, Encodable, PartialPaymentMethod, PaymentMethod
```
```javascript
// Parent: GiftCardPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: GiftCardPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: GiftCardPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: GiftCardPaymentMethod
public let brand: Swift.String { get }
```
```javascript
// Parent: GiftCardPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: GiftCardPaymentMethod
public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
// Parent: GiftCardPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: GiftCardPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.GiftCardPaymentMethod
```
```javascript
// Parent: Root
public struct InstantPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: InstantPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: InstantPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: InstantPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: InstantPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: InstantPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: InstantPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.InstantPaymentMethod
```
```javascript
// Parent: Root
public struct IssuerListPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: IssuerListPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: IssuerListPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: IssuerListPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: IssuerListPaymentMethod
public let issuers: [Adyen.Issuer] { get }
```
```javascript
// Parent: IssuerListPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.IssuerListPaymentMethod
```
```javascript
// Parent: IssuerListPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: IssuerListPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: Root
public struct MBWayPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: MBWayPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: MBWayPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: MBWayPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: MBWayPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: MBWayPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: MBWayPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.MBWayPaymentMethod
```
```javascript
// Parent: Root
public struct MealVoucherPaymentMethod : Decodable, Encodable, PartialPaymentMethod, PaymentMethod
```
```javascript
// Parent: MealVoucherPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: MealVoucherPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: MealVoucherPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: MealVoucherPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: MealVoucherPaymentMethod
public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
// Parent: MealVoucherPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: MealVoucherPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.MealVoucherPaymentMethod
```
```javascript
// Parent: Root
public struct Issuer : CustomStringConvertible, Decodable, Encodable, Equatable
```
```javascript
// Parent: Issuer
public let identifier: Swift.String { get }
```
```javascript
// Parent: Issuer
public let name: Swift.String { get }
```
```javascript
// Parent: Issuer
public var description: Swift.String { get }
```
```javascript
// Parent: Issuer
public static func __derived_struct_equals(_: Adyen.Issuer, _: Adyen.Issuer) -> Swift.Bool
```
```javascript
// Parent: Issuer
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Issuer
public init(from: any Swift.Decoder) throws -> Adyen.Issuer
```
```javascript
// Parent: Root
public struct OnlineBankingPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: OnlineBankingPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: OnlineBankingPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: OnlineBankingPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: OnlineBankingPaymentMethod
public let issuers: [Adyen.Issuer] { get }
```
```javascript
// Parent: OnlineBankingPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: OnlineBankingPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: OnlineBankingPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.OnlineBankingPaymentMethod
```
```javascript
// Parent: Root
public struct QiwiWalletPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: QiwiWalletPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: QiwiWalletPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: QiwiWalletPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: QiwiWalletPaymentMethod
public let phoneExtensions: [Adyen.PhoneExtension] { get }
```
```javascript
// Parent: QiwiWalletPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.QiwiWalletPaymentMethod
```
```javascript
// Parent: QiwiWalletPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: QiwiWalletPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: Root
public struct PhoneExtension : Decodable, Encodable, Equatable, FormPickable
```
```javascript
// Parent: PhoneExtension
public let value: Swift.String { get }
```
```javascript
// Parent: PhoneExtension
public let countryCode: Swift.String { get }
```
```javascript
// Parent: PhoneExtension
public var countryDisplayName: Swift.String { get }
```
```javascript
// Parent: PhoneExtension
public init(value: Swift.String, countryCode: Swift.String) -> Adyen.PhoneExtension
```
```javascript
// Parent: PhoneExtension
public static func __derived_struct_equals(_: Adyen.PhoneExtension, _: Adyen.PhoneExtension) -> Swift.Bool
```
```javascript
// Parent: PhoneExtension
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: PhoneExtension
public init(from: any Swift.Decoder) throws -> Adyen.PhoneExtension
```
```javascript
// Parent: PhoneExtension
@_spi(AdyenInternal) public var identifier: Swift.String { get }
```
```javascript
// Parent: PhoneExtension
@_spi(AdyenInternal) public var icon: UIKit.UIImage? { get }
```
```javascript
// Parent: PhoneExtension
@_spi(AdyenInternal) public var title: Swift.String { get }
```
```javascript
// Parent: PhoneExtension
@_spi(AdyenInternal) public var subtitle: Swift.String? { get }
```
```javascript
// Parent: PhoneExtension
@_spi(AdyenInternal) public var trailingText: Swift.String? { get }
```
```javascript
// Parent: Root
public struct SEPADirectDebitPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: SEPADirectDebitPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: SEPADirectDebitPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: SEPADirectDebitPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: SEPADirectDebitPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: SEPADirectDebitPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: SEPADirectDebitPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.SEPADirectDebitPaymentMethod
```
```javascript
// Parent: Root
public struct StoredBCMCPaymentMethod : Decodable, Encodable, PaymentMethod, StoredPaymentMethod
```
```javascript
// Parent: StoredBCMCPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: StoredBCMCPaymentMethod
public var name: Swift.String { get }
```
```javascript
// Parent: StoredBCMCPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: StoredBCMCPaymentMethod
public var identifier: Swift.String { get }
```
```javascript
// Parent: StoredBCMCPaymentMethod
public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
// Parent: StoredBCMCPaymentMethod
public var supportedShopperInteractions: [Adyen.ShopperInteraction] { get }
```
```javascript
// Parent: StoredBCMCPaymentMethod
public let brand: Swift.String { get }
```
```javascript
// Parent: StoredBCMCPaymentMethod
public var lastFour: Swift.String { get }
```
```javascript
// Parent: StoredBCMCPaymentMethod
public var expiryMonth: Swift.String { get }
```
```javascript
// Parent: StoredBCMCPaymentMethod
public var expiryYear: Swift.String { get }
```
```javascript
// Parent: StoredBCMCPaymentMethod
public var holderName: Swift.String? { get }
```
```javascript
// Parent: StoredBCMCPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: StoredBCMCPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.StoredBCMCPaymentMethod
```
```javascript
// Parent: StoredBCMCPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Root
public struct StoredBLIKPaymentMethod : Decodable, Encodable, PaymentMethod, StoredPaymentMethod
```
```javascript
// Parent: StoredBLIKPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: StoredBLIKPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: StoredBLIKPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: StoredBLIKPaymentMethod
public let identifier: Swift.String { get }
```
```javascript
// Parent: StoredBLIKPaymentMethod
public let supportedShopperInteractions: [Adyen.ShopperInteraction] { get }
```
```javascript
// Parent: StoredBLIKPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: StoredBLIKPaymentMethod
@_spi(AdyenInternal) public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
// Parent: StoredBLIKPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: StoredBLIKPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.StoredBLIKPaymentMethod
```
```javascript
// Parent: Root
public struct StoredCashAppPayPaymentMethod : Decodable, Encodable, PaymentMethod, StoredPaymentMethod
```
```javascript
// Parent: StoredCashAppPayPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: StoredCashAppPayPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: StoredCashAppPayPaymentMethod
public let cashtag: Swift.String { get }
```
```javascript
// Parent: StoredCashAppPayPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: StoredCashAppPayPaymentMethod
public let identifier: Swift.String { get }
```
```javascript
// Parent: StoredCashAppPayPaymentMethod
public let supportedShopperInteractions: [Adyen.ShopperInteraction] { get }
```
```javascript
// Parent: StoredCashAppPayPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: StoredCashAppPayPaymentMethod
@_spi(AdyenInternal) public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
// Parent: StoredCashAppPayPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: StoredCashAppPayPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.StoredCashAppPayPaymentMethod
```
```javascript
// Parent: Root
public struct StoredInstantPaymentMethod : Decodable, Encodable, PaymentMethod, StoredPaymentMethod
```
```javascript
// Parent: StoredInstantPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: StoredInstantPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: StoredInstantPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: StoredInstantPaymentMethod
public let identifier: Swift.String { get }
```
```javascript
// Parent: StoredInstantPaymentMethod
public let supportedShopperInteractions: [Adyen.ShopperInteraction] { get }
```
```javascript
// Parent: StoredInstantPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: StoredInstantPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: StoredInstantPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.StoredInstantPaymentMethod
```
```javascript
// Parent: Root
public struct StoredPayPalPaymentMethod : Decodable, Encodable, PaymentMethod, StoredPaymentMethod
```
```javascript
// Parent: StoredPayPalPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: StoredPayPalPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: StoredPayPalPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: StoredPayPalPaymentMethod
public let identifier: Swift.String { get }
```
```javascript
// Parent: StoredPayPalPaymentMethod
public let supportedShopperInteractions: [Adyen.ShopperInteraction] { get }
```
```javascript
// Parent: StoredPayPalPaymentMethod
public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
// Parent: StoredPayPalPaymentMethod
public let emailAddress: Swift.String { get }
```
```javascript
// Parent: StoredPayPalPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: StoredPayPalPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: StoredPayPalPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.StoredPayPalPaymentMethod
```
```javascript
// Parent: Root
public struct TwintPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: TwintPaymentMethod
public var type: Adyen.PaymentMethodType { get set }
```
```javascript
// Parent: TwintPaymentMethod
public var name: Swift.String { get set }
```
```javascript
// Parent: TwintPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: TwintPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: TwintPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: TwintPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.TwintPaymentMethod
```
```javascript
// Parent: Root
public struct UPIPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: UPIPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: UPIPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: UPIPaymentMethod
public let apps: [Adyen.Issuer]? { get }
```
```javascript
// Parent: UPIPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: UPIPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: UPIPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: UPIPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.UPIPaymentMethod
```
```javascript
// Parent: Root
public struct WeChatPayPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
// Parent: WeChatPayPaymentMethod
public let type: Adyen.PaymentMethodType { get }
```
```javascript
// Parent: WeChatPayPaymentMethod
public let name: Swift.String { get }
```
```javascript
// Parent: WeChatPayPaymentMethod
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
// Parent: WeChatPayPaymentMethod
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
// Parent: WeChatPayPaymentMethod
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: WeChatPayPaymentMethod
public init(from: any Swift.Decoder) throws -> Adyen.WeChatPayPaymentMethod
```
```javascript
// Parent: Root
@_spi(AdyenInternal) @objc public final class CancellingToolBar : AdyenCompatible, AnyNavigationBar, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: CancellingToolBar
@_spi(AdyenInternal) override public init(title: Swift.String?, style: Adyen.NavigationStyle) -> Adyen.CancellingToolBar
```
```javascript
// Parent: Root
@_spi(AdyenInternal) @objc public class ModalToolbar : AdyenCompatible, AnyNavigationBar, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: ModalToolbar
@_spi(AdyenInternal) public var onCancelHandler: (() -> Swift.Void)? { get set }
```
```javascript
// Parent: ModalToolbar
@_spi(AdyenInternal) public init(title: Swift.String?, style: Adyen.NavigationStyle) -> Adyen.ModalToolbar
```
```javascript
// Parent: ModalToolbar
@_spi(AdyenInternal) @objc override public dynamic init(frame: CoreFoundation.CGRect) -> Adyen.ModalToolbar
```
```javascript
// Parent: Root
public final class AmountFormatter
```
```javascript
// Parent: AmountFormatter
public static func formatted(amount: Swift.Int, currencyCode: Swift.String, localeIdentifier: Swift.String? = $DEFAULT_ARG) -> Swift.String?
```
```javascript
// Parent: AmountFormatter
public static func minorUnitAmount(from: Swift.Double, currencyCode: Swift.String, localeIdentifier: Swift.String? = $DEFAULT_ARG) -> Swift.Int
```
```javascript
// Parent: AmountFormatter
public static func minorUnitAmount(from: Foundation.Decimal, currencyCode: Swift.String, localeIdentifier: Swift.String? = $DEFAULT_ARG) -> Swift.Int
```
```javascript
// Parent: AmountFormatter
public static func decimalAmount(_: Swift.Int, currencyCode: Swift.String, localeIdentifier: Swift.String? = $DEFAULT_ARG) -> Foundation.NSDecimalNumber
```
```javascript
// Parent: Root
public final class BrazilSocialSecurityNumberFormatter : Formatter, Sanitizer
```
```javascript
// Parent: BrazilSocialSecurityNumberFormatter
override public func formattedValue(for: Swift.String) -> Swift.String
```
```javascript
// Parent: BrazilSocialSecurityNumberFormatter
override public init() -> Adyen.BrazilSocialSecurityNumberFormatter
```
```javascript
// Parent: Root
public protocol Formatter<Self : Adyen.Sanitizer> : Sanitizer
```
```javascript
// Parent: Formatter
public func formattedValue<Self where Self : Adyen.Formatter>(for: Swift.String) -> Swift.String
```
```javascript
// Parent: Root
public protocol Sanitizer
```
```javascript
// Parent: Sanitizer
public func sanitizedValue<Self where Self : Adyen.Sanitizer>(for: Swift.String) -> Swift.String
```
```javascript
// Parent: Root
public final class IBANFormatter : Formatter, Sanitizer
```
```javascript
// Parent: IBANFormatter
public init() -> Adyen.IBANFormatter
```
```javascript
// Parent: IBANFormatter
public func formattedValue(for: Swift.String) -> Swift.String
```
```javascript
// Parent: IBANFormatter
public func sanitizedValue(for: Swift.String) -> Swift.String
```
```javascript
// Parent: Root
open class NumericFormatter : Formatter, Sanitizer
```
```javascript
// Parent: NumericFormatter
public init() -> Adyen.NumericFormatter
```
```javascript
// Parent: NumericFormatter
open func formattedValue(for: Swift.String) -> Swift.String
```
```javascript
// Parent: NumericFormatter
open func sanitizedValue(for: Swift.String) -> Swift.String
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol AdyenCancellable
```
```javascript
// Parent: AdyenCancellable
@_spi(AdyenInternal) public func cancel<Self where Self : Adyen.AdyenCancellable>() -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public class AdyenTask : AdyenCancellable
```
```javascript
// Parent: AdyenTask
@_spi(AdyenInternal) public var isCancelled: Swift.Bool { get }
```
```javascript
// Parent: AdyenTask
@_spi(AdyenInternal) public func cancel() -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct AdyenDependencyValues
```
```javascript
// Parent: AdyenDependencyValues
@_spi(AdyenInternal) public subscript<K where K : Adyen.AdyenDependencyKey>(_: K.Type) -> K.Value { get set }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct AdyenDependency<T>
```
```javascript
// Parent: AdyenDependency
@_spi(AdyenInternal) public var wrappedValue: T { get }
```
```javascript
// Parent: AdyenDependency
@_spi(AdyenInternal) public init<T>(_: Swift.KeyPath<Adyen.AdyenDependencyValues, T>) -> Adyen.AdyenDependency<T>
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol AdyenDependencyKey
```
```javascript
// Parent: AdyenDependencyKey
@_spi(AdyenInternal) public associatedtype Value
```
```javascript
// Parent: AdyenDependencyKey
@_spi(AdyenInternal) public static var liveValue: Self.Value { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct AdyenScope<Base>
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public let base: Base { get }
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public init<Base>(base: Base) -> Adyen.AdyenScope<Base>
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public subscript<Base, T where Base == [T]>(safeIndex: Swift.Int) -> T? { get }
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public func isSchemeConfigured<Base where Base : Foundation.Bundle>(_: Swift.String) -> Swift.Bool
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public func with<Base where Base : UIKit.NSLayoutConstraint>(priority: UIKit.UILayoutPriority) -> UIKit.NSLayoutConstraint
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public var caAlignmentMode: QuartzCore.CATextLayerAlignmentMode { get }
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public var isNullOrEmpty: Swift.Bool { get }
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public var nilIfEmpty: Swift.String? { get }
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public var nilIfEmpty: Swift.String? { get }
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public func truncate<Base where Base == Swift.String>(to: Swift.Int) -> Swift.String
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public func components<Base where Base == Swift.String>(withLengths: [Swift.Int]) -> [Swift.String]
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public func components<Base where Base == Swift.String>(withLength: Swift.Int) -> [Swift.String]
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public subscript<Base where Base == Swift.String>(_: Swift.Int) -> Swift.String { get }
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public subscript<Base where Base == Swift.String>(_: Swift.Range<Swift.Int>) -> Swift.String { get }
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public subscript<Base where Base == Swift.String>(_: Swift.ClosedRange<Swift.Int>) -> Swift.String { get }
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public var linkRanges: [Foundation.NSRange] { get }
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public func timeLeftString<Base where Base == Swift.Double>() -> Swift.String?
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public var mainKeyWindow: UIKit.UIWindow? { get }
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public func font<Base where Base : UIKit.UIFont>(with: UIKit.UIFont.Weight) -> UIKit.UIFont
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public func cancelAnimations<Base where Base : UIKit.UIView>(with: Swift.String) -> Swift.Void
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public func animate<Base where Base : UIKit.UIView>(context: Adyen.AnimationContext) -> Swift.Void
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) @discardableResult public func anchor<Base where Base : UIKit.UIView>(inside: UIKit.UIView, with: UIKit.UIEdgeInsets = $DEFAULT_ARG) -> [UIKit.NSLayoutConstraint]
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) @discardableResult public func anchor<Base where Base : UIKit.UIView>(inside: UIKit.UILayoutGuide, with: UIKit.UIEdgeInsets = $DEFAULT_ARG) -> [UIKit.NSLayoutConstraint]
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) @discardableResult public func anchor<Base where Base : UIKit.UIView>(inside: Adyen.AdyenScope<Base>.LayoutAnchorSource, edgeInsets: Adyen.AdyenScope<Base>.EdgeInsets = $DEFAULT_ARG) -> [UIKit.NSLayoutConstraint]
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public func wrapped<Base where Base : UIKit.UIView>(with: UIKit.UIEdgeInsets = $DEFAULT_ARG) -> UIKit.UIView
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public enum LayoutAnchorSource<Base where Base : UIKit.UIView>
```
```javascript
// Parent: AdyenScope.LayoutAnchorSource
@_spi(AdyenInternal) public case view(UIKit.UIView)
```
```javascript
// Parent: AdyenScope.LayoutAnchorSource
@_spi(AdyenInternal) public case layoutGuide(UIKit.UILayoutGuide)
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public struct EdgeInsets<Base where Base : UIKit.UIView>
```
```javascript
// Parent: AdyenScope.EdgeInsets
@_spi(AdyenInternal) public var top: CoreGraphics.CGFloat? { get set }
```
```javascript
// Parent: AdyenScope.EdgeInsets
@_spi(AdyenInternal) public var left: CoreGraphics.CGFloat? { get set }
```
```javascript
// Parent: AdyenScope.EdgeInsets
@_spi(AdyenInternal) public var bottom: CoreGraphics.CGFloat? { get set }
```
```javascript
// Parent: AdyenScope.EdgeInsets
@_spi(AdyenInternal) public var right: CoreGraphics.CGFloat? { get set }
```
```javascript
// Parent: AdyenScope.EdgeInsets
@_spi(AdyenInternal) public static var zero: Adyen.AdyenScope<Base>.EdgeInsets { get }
```
```javascript
// Parent: AdyenScope.EdgeInsets
@_spi(AdyenInternal) public init<Base where Base : UIKit.UIView>(top: CoreGraphics.CGFloat? = $DEFAULT_ARG, left: CoreGraphics.CGFloat? = $DEFAULT_ARG, bottom: CoreGraphics.CGFloat? = $DEFAULT_ARG, right: CoreGraphics.CGFloat? = $DEFAULT_ARG) -> Adyen.AdyenScope<Base>.EdgeInsets
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public var topPresenter: UIKit.UIViewController { get }
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) @discardableResult public func snapShot<Base where Base : UIKit.UIView>(forceRedraw: Swift.Bool = $DEFAULT_ARG) -> UIKit.UIImage?
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public func hide<Base where Base : UIKit.UIView>(animationKey: Swift.String, hidden: Swift.Bool, animated: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public var minimalSize: CoreFoundation.CGSize { get }
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public func round<Base where Base : UIKit.UIView>(corners: UIKit.UIRectCorner, radius: CoreGraphics.CGFloat) -> Swift.Void
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public func round<Base where Base : UIKit.UIView>(corners: UIKit.UIRectCorner, percentage: CoreGraphics.CGFloat) -> Swift.Void
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public func round<Base where Base : UIKit.UIView>(corners: UIKit.UIRectCorner, rounding: Adyen.CornerRounding) -> Swift.Void
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public func round<Base where Base : UIKit.UIView>(using: Adyen.CornerRounding) -> Swift.Void
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public var queryParameters: [Swift.String : Swift.String] { get }
```
```javascript
// Parent: AdyenScope
@_spi(AdyenInternal) public var isHttp: Swift.Bool { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol AdyenCompatible
```
```javascript
// Parent: AdyenCompatible
@_spi(AdyenInternal) public associatedtype AdyenBase
```
```javascript
// Parent: AdyenCompatible
@_spi(AdyenInternal) public var adyen: Adyen.AdyenScope<Self.AdyenBase> { get }
```
```javascript
// Parent: AdyenCompatible
@_spi(AdyenInternal) public var adyen: Adyen.AdyenScope<Self> { get }
```
```javascript
// Parent: Root
public let adyenSdkVersion: Swift.String
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol ImageLoading
```
```javascript
// Parent: ImageLoading
@_spi(AdyenInternal) @discardableResult public func load<Self where Self : Adyen.ImageLoading>(url: Foundation.URL, completion: ((UIKit.UIImage?) -> Swift.Void)) -> any Adyen.AdyenCancellable
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class ImageLoader : ImageLoading
```
```javascript
// Parent: ImageLoader
@_spi(AdyenInternal) public init(urlSession: Foundation.URLSession = $DEFAULT_ARG) -> Adyen.ImageLoader
```
```javascript
// Parent: ImageLoader
@_spi(AdyenInternal) @discardableResult public func load(url: Foundation.URL, completion: ((UIKit.UIImage?) -> Swift.Void)) -> any Adyen.AdyenCancellable
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class ImageLoaderProvider
```
```javascript
// Parent: ImageLoaderProvider
@_spi(AdyenInternal) public static func imageLoader() -> any Adyen.ImageLoading
```
```javascript
// Parent: Root
@_spi(AdyenInternal) @objc public class AnimationContext : CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSObjectProtocol
```
```javascript
// Parent: AnimationContext
@_spi(AdyenInternal) public init(animationKey: Swift.String, duration: Foundation.TimeInterval, delay: Foundation.TimeInterval = $DEFAULT_ARG, options: UIKit.UIView.AnimationOptions = $DEFAULT_ARG, animations: () -> Swift.Void, completion: ((Swift.Bool) -> Swift.Void)? = $DEFAULT_ARG) -> Adyen.AnimationContext
```
```javascript
// Parent: AnimationContext
@_spi(AdyenInternal) @objc override public dynamic init() -> Adyen.AnimationContext
```
```javascript
// Parent: Root
@_spi(AdyenInternal) @objc public final class KeyFrameAnimationContext : CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSObjectProtocol
```
```javascript
// Parent: KeyFrameAnimationContext
@_spi(AdyenInternal) public init(animationKey: Swift.String, duration: Foundation.TimeInterval, delay: Foundation.TimeInterval = $DEFAULT_ARG, options: UIKit.UIView.KeyframeAnimationOptions = $DEFAULT_ARG, animations: () -> Swift.Void, completion: ((Swift.Bool) -> Swift.Void)? = $DEFAULT_ARG) -> Adyen.KeyFrameAnimationContext
```
```javascript
// Parent: KeyFrameAnimationContext
@_spi(AdyenInternal) override public init(animationKey: Swift.String, duration: Foundation.TimeInterval, delay: Foundation.TimeInterval = $DEFAULT_ARG, options: UIKit.UIView.AnimationOptions = $DEFAULT_ARG, animations: () -> Swift.Void, completion: ((Swift.Bool) -> Swift.Void)? = $DEFAULT_ARG) -> Adyen.KeyFrameAnimationContext
```
```javascript
// Parent: Root
@_spi(AdyenInternal) @objc public final class SpringAnimationContext : CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSObjectProtocol
```
```javascript
// Parent: SpringAnimationContext
@_spi(AdyenInternal) public init(animationKey: Swift.String, duration: Foundation.TimeInterval, delay: Foundation.TimeInterval = $DEFAULT_ARG, dampingRatio: CoreGraphics.CGFloat, velocity: CoreGraphics.CGFloat, options: UIKit.UIView.AnimationOptions = $DEFAULT_ARG, animations: () -> Swift.Void, completion: ((Swift.Bool) -> Swift.Void)? = $DEFAULT_ARG) -> Adyen.SpringAnimationContext
```
```javascript
// Parent: SpringAnimationContext
@_spi(AdyenInternal) override public init(animationKey: Swift.String, duration: Foundation.TimeInterval, delay: Foundation.TimeInterval = $DEFAULT_ARG, options: UIKit.UIView.AnimationOptions = $DEFAULT_ARG, animations: () -> Swift.Void, completion: ((Swift.Bool) -> Swift.Void)? = $DEFAULT_ARG) -> Adyen.SpringAnimationContext
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol PreferredContentSizeConsumer
```
```javascript
// Parent: PreferredContentSizeConsumer
@_spi(AdyenInternal) public func didUpdatePreferredContentSize<Self where Self : Adyen.PreferredContentSizeConsumer>() -> Swift.Void
```
```javascript
// Parent: PreferredContentSizeConsumer
@_spi(AdyenInternal) public func willUpdatePreferredContentSize<Self where Self : Adyen.PreferredContentSizeConsumer>() -> Swift.Void
```
```javascript
// Parent: Root
public struct Amount : Comparable, Decodable, Encodable, Equatable
```
```javascript
// Parent: Amount
public let value: Swift.Int { get }
```
```javascript
// Parent: Amount
public let currencyCode: Swift.String { get }
```
```javascript
// Parent: Amount
public var localeIdentifier: Swift.String? { get set }
```
```javascript
// Parent: Amount
public init(value: Swift.Int, currencyCode: Swift.String, localeIdentifier: Swift.String? = $DEFAULT_ARG) -> Adyen.Amount
```
```javascript
// Parent: Amount
public init(value: Foundation.Decimal, currencyCode: Swift.String, localeIdentifier: Swift.String? = $DEFAULT_ARG) -> Adyen.Amount
```
```javascript
// Parent: Amount
public static func __derived_struct_equals(_: Adyen.Amount, _: Adyen.Amount) -> Swift.Bool
```
```javascript
// Parent: Amount
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Amount
public init(from: any Swift.Decoder) throws -> Adyen.Amount
```
```javascript
// Parent: Amount
public var formatted: Swift.String { get }
```
```javascript
// Parent: Amount
@_spi(AdyenInternal) public var formattedComponents: Adyen.AmountComponents { get }
```
```javascript
// Parent: Amount
@_spi(AdyenInternal) public static func <(_: Adyen.Amount, _: Adyen.Amount) -> Swift.Bool
```
```javascript
// Parent: Amount
@_spi(AdyenInternal) public static func <=(_: Adyen.Amount, _: Adyen.Amount) -> Swift.Bool
```
```javascript
// Parent: Amount
@_spi(AdyenInternal) public static func >=(_: Adyen.Amount, _: Adyen.Amount) -> Swift.Bool
```
```javascript
// Parent: Amount
@_spi(AdyenInternal) public static func >(_: Adyen.Amount, _: Adyen.Amount) -> Swift.Bool
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct AmountComponents
```
```javascript
// Parent: AmountComponents
@_spi(AdyenInternal) public let formattedValue: Swift.String { get }
```
```javascript
// Parent: AmountComponents
@_spi(AdyenInternal) public let formattedCurrencySymbol: Swift.String { get }
```
```javascript
// Parent: Root
public protocol OpaqueEncodable<Self : Swift.Encodable> : Encodable
```
```javascript
// Parent: OpaqueEncodable
public var encodable: Adyen.AnyEncodable { get }
```
```javascript
// Parent: OpaqueEncodable
public var encodable: Adyen.AnyEncodable { get }
```
```javascript
// Parent: Root
public struct AnyEncodable : Encodable
```
```javascript
// Parent: AnyEncodable
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Root
public struct Balance
```
```javascript
// Parent: Balance
public let availableAmount: Adyen.Amount { get }
```
```javascript
// Parent: Balance
public let transactionLimit: Adyen.Amount? { get }
```
```javascript
// Parent: Balance
public init(availableAmount: Adyen.Amount, transactionLimit: Adyen.Amount?) -> Adyen.Balance
```
```javascript
// Parent: Root
public struct BrowserInfo : Encodable
```
```javascript
// Parent: BrowserInfo
public var userAgent: Swift.String? { get set }
```
```javascript
// Parent: BrowserInfo
public static func initialize(completion: ((Adyen.BrowserInfo?) -> Swift.Void)) -> Swift.Void
```
```javascript
// Parent: BrowserInfo
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol DelegatedAuthenticationAware
```
```javascript
// Parent: DelegatedAuthenticationAware
@_spi(AdyenInternal) public var delegatedAuthenticationData: Adyen.DelegatedAuthenticationData? { get }
```
```javascript
// Parent: Root
public enum DelegatedAuthenticationData : Decodable, Encodable
```
```javascript
// Parent: DelegatedAuthenticationData
public enum DecodingError : Equatable, Error, Hashable, LocalizedError, Sendable
```
```javascript
// Parent: DelegatedAuthenticationData.DecodingError
public case invalidDelegatedAuthenticationData
```
```javascript
// Parent: DelegatedAuthenticationData.DecodingError
public var errorDescription: Swift.String? { get }
```
```javascript
// Parent: DelegatedAuthenticationData.DecodingError
public static func __derived_enum_equals(_: Adyen.DelegatedAuthenticationData.DecodingError, _: Adyen.DelegatedAuthenticationData.DecodingError) -> Swift.Bool
```
```javascript
// Parent: DelegatedAuthenticationData.DecodingError
public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: DelegatedAuthenticationData.DecodingError
public var hashValue: Swift.Int { get }
```
```javascript
// Parent: DelegatedAuthenticationData
public case sdkOutput(Swift.String)
```
```javascript
// Parent: DelegatedAuthenticationData
public case sdkInput(Swift.String)
```
```javascript
// Parent: DelegatedAuthenticationData
public init(from: any Swift.Decoder) throws -> Adyen.DelegatedAuthenticationData
```
```javascript
// Parent: DelegatedAuthenticationData
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Root
public struct Installments : Encodable, Equatable
```
```javascript
// Parent: Installments
public enum Plan : Equatable, Hashable, RawRepresentable
```
```javascript
// Parent: Installments.Plan
public case regular
```
```javascript
// Parent: Installments.Plan
public case revolving
```
```javascript
// Parent: Installments.Plan
@inlinable public init(rawValue: Swift.String) -> Adyen.Installments.Plan?
```
```javascript
// Parent: Installments.Plan
public typealias RawValue = Swift.String
```
```javascript
// Parent: Installments.Plan
public var rawValue: Swift.String { get }
```
```javascript
// Parent: Installments
public let totalMonths: Swift.Int { get }
```
```javascript
// Parent: Installments
public let plan: Adyen.Installments.Plan { get }
```
```javascript
// Parent: Installments
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Installments
public init(totalMonths: Swift.Int, plan: Adyen.Installments.Plan) -> Adyen.Installments
```
```javascript
// Parent: Installments
public static func __derived_struct_equals(_: Adyen.Installments, _: Adyen.Installments) -> Swift.Bool
```
```javascript
// Parent: Root
public struct PartialPaymentOrder : Decodable, Encodable, Equatable
```
```javascript
// Parent: PartialPaymentOrder
public struct CompactOrder : Encodable, Equatable
```
```javascript
// Parent: PartialPaymentOrder.CompactOrder
public let pspReference: Swift.String { get }
```
```javascript
// Parent: PartialPaymentOrder.CompactOrder
public let orderData: Swift.String? { get }
```
```javascript
// Parent: PartialPaymentOrder.CompactOrder
public static func __derived_struct_equals(_: Adyen.PartialPaymentOrder.CompactOrder, _: Adyen.PartialPaymentOrder.CompactOrder) -> Swift.Bool
```
```javascript
// Parent: PartialPaymentOrder.CompactOrder
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: PartialPaymentOrder
public let compactOrder: Adyen.PartialPaymentOrder.CompactOrder { get }
```
```javascript
// Parent: PartialPaymentOrder
public let pspReference: Swift.String { get }
```
```javascript
// Parent: PartialPaymentOrder
public let orderData: Swift.String? { get }
```
```javascript
// Parent: PartialPaymentOrder
public let reference: Swift.String? { get }
```
```javascript
// Parent: PartialPaymentOrder
public let amount: Adyen.Amount? { get }
```
```javascript
// Parent: PartialPaymentOrder
public let remainingAmount: Adyen.Amount? { get }
```
```javascript
// Parent: PartialPaymentOrder
public let expiresAt: Foundation.Date? { get }
```
```javascript
// Parent: PartialPaymentOrder
public init(pspReference: Swift.String, orderData: Swift.String?, reference: Swift.String? = $DEFAULT_ARG, amount: Adyen.Amount? = $DEFAULT_ARG, remainingAmount: Adyen.Amount? = $DEFAULT_ARG, expiresAt: Foundation.Date? = $DEFAULT_ARG) -> Adyen.PartialPaymentOrder
```
```javascript
// Parent: PartialPaymentOrder
public init(from: any Swift.Decoder) throws -> Adyen.PartialPaymentOrder
```
```javascript
// Parent: PartialPaymentOrder
public static func __derived_struct_equals(_: Adyen.PartialPaymentOrder, _: Adyen.PartialPaymentOrder) -> Swift.Bool
```
```javascript
// Parent: PartialPaymentOrder
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Root
public struct Payment : Decodable, Encodable
```
```javascript
// Parent: Payment
public let amount: Adyen.Amount { get }
```
```javascript
// Parent: Payment
public let countryCode: Swift.String { get }
```
```javascript
// Parent: Payment
public init(amount: Adyen.Amount, countryCode: Swift.String) -> Adyen.Payment
```
```javascript
// Parent: Payment
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: Payment
public init(from: any Swift.Decoder) throws -> Adyen.Payment
```
```javascript
// Parent: Root
public struct PaymentComponentData
```
```javascript
// Parent: PaymentComponentData
public let amount: Adyen.Amount? { get }
```
```javascript
// Parent: PaymentComponentData
public let paymentMethod: any Adyen.PaymentMethodDetails { get }
```
```javascript
// Parent: PaymentComponentData
public let storePaymentMethod: Swift.Bool? { get }
```
```javascript
// Parent: PaymentComponentData
public let order: Adyen.PartialPaymentOrder? { get }
```
```javascript
// Parent: PaymentComponentData
public var amountToPay: Adyen.Amount? { get }
```
```javascript
// Parent: PaymentComponentData
public let installments: Adyen.Installments? { get }
```
```javascript
// Parent: PaymentComponentData
public let supportNativeRedirect: Swift.Bool { get }
```
```javascript
// Parent: PaymentComponentData
public var shopperName: Adyen.ShopperName? { get }
```
```javascript
// Parent: PaymentComponentData
public var emailAddress: Swift.String? { get }
```
```javascript
// Parent: PaymentComponentData
public var telephoneNumber: Swift.String? { get }
```
```javascript
// Parent: PaymentComponentData
public let browserInfo: Adyen.BrowserInfo? { get }
```
```javascript
// Parent: PaymentComponentData
public var checkoutAttemptId: Swift.String? { get }
```
```javascript
// Parent: PaymentComponentData
public var billingAddress: Adyen.PostalAddress? { get }
```
```javascript
// Parent: PaymentComponentData
public var deliveryAddress: Adyen.PostalAddress? { get }
```
```javascript
// Parent: PaymentComponentData
public var socialSecurityNumber: Swift.String? { get }
```
```javascript
// Parent: PaymentComponentData
public var delegatedAuthenticationData: Adyen.DelegatedAuthenticationData? { get }
```
```javascript
// Parent: PaymentComponentData
@_spi(AdyenInternal) public init(paymentMethodDetails: some Adyen.PaymentMethodDetails, amount: Adyen.Amount?, order: Adyen.PartialPaymentOrder?, storePaymentMethod: Swift.Bool? = $DEFAULT_ARG, browserInfo: Adyen.BrowserInfo? = $DEFAULT_ARG, installments: Adyen.Installments? = $DEFAULT_ARG) -> Adyen.PaymentComponentData
```
```javascript
// Parent: PaymentComponentData
@_spi(AdyenInternal) public func replacing(order: Adyen.PartialPaymentOrder) -> Adyen.PaymentComponentData
```
```javascript
// Parent: PaymentComponentData
@_spi(AdyenInternal) public func replacing(amount: Adyen.Amount) -> Adyen.PaymentComponentData
```
```javascript
// Parent: PaymentComponentData
@_spi(AdyenInternal) public func replacing(checkoutAttemptId: Swift.String?) -> Adyen.PaymentComponentData
```
```javascript
// Parent: PaymentComponentData
@_spi(AdyenInternal) public func dataByAddingBrowserInfo(completion: ((Adyen.PaymentComponentData) -> Swift.Void)) -> Swift.Void
```
```javascript
// Parent: Root
public struct PostalAddress : Encodable, Equatable
```
```javascript
// Parent: PostalAddress
public init(city: Swift.String? = $DEFAULT_ARG, country: Swift.String? = $DEFAULT_ARG, houseNumberOrName: Swift.String? = $DEFAULT_ARG, postalCode: Swift.String? = $DEFAULT_ARG, stateOrProvince: Swift.String? = $DEFAULT_ARG, street: Swift.String? = $DEFAULT_ARG, apartment: Swift.String? = $DEFAULT_ARG) -> Adyen.PostalAddress
```
```javascript
// Parent: PostalAddress
public var city: Swift.String? { get set }
```
```javascript
// Parent: PostalAddress
public var country: Swift.String? { get set }
```
```javascript
// Parent: PostalAddress
public var houseNumberOrName: Swift.String? { get set }
```
```javascript
// Parent: PostalAddress
public var postalCode: Swift.String? { get set }
```
```javascript
// Parent: PostalAddress
public var stateOrProvince: Swift.String? { get set }
```
```javascript
// Parent: PostalAddress
public var street: Swift.String? { get set }
```
```javascript
// Parent: PostalAddress
public var apartment: Swift.String? { get set }
```
```javascript
// Parent: PostalAddress
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: PostalAddress
public static func ==(_: Adyen.PostalAddress, _: Adyen.PostalAddress) -> Swift.Bool
```
```javascript
// Parent: PostalAddress
public var isEmpty: Swift.Bool { get }
```
```javascript
// Parent: PostalAddress
@_spi(AdyenInternal) public func formatted(using: Adyen.LocalizationParameters?) -> Swift.String
```
```javascript
// Parent: PostalAddress
@_spi(AdyenInternal) public var formattedStreet: Swift.String { get }
```
```javascript
// Parent: PostalAddress
@_spi(AdyenInternal) public func formattedLocation(using: Adyen.LocalizationParameters?) -> Swift.String
```
```javascript
// Parent: PostalAddress
@_spi(AdyenInternal) public func satisfies(requiredFields: Swift.Set<Adyen.AddressField>) -> Swift.Bool
```
```javascript
// Parent: Root
public struct PhoneNumber
```
```javascript
// Parent: PhoneNumber
public let value: Swift.String { get }
```
```javascript
// Parent: PhoneNumber
public let callingCode: Swift.String? { get }
```
```javascript
// Parent: PhoneNumber
public init(value: Swift.String, callingCode: Swift.String?) -> Adyen.PhoneNumber
```
```javascript
// Parent: Root
public struct PrefilledShopperInformation : ShopperInformation
```
```javascript
// Parent: PrefilledShopperInformation
public var shopperName: Adyen.ShopperName? { get set }
```
```javascript
// Parent: PrefilledShopperInformation
public var emailAddress: Swift.String? { get set }
```
```javascript
// Parent: PrefilledShopperInformation
public var telephoneNumber: Swift.String? { get set }
```
```javascript
// Parent: PrefilledShopperInformation
public var phoneNumber: Adyen.PhoneNumber? { get set }
```
```javascript
// Parent: PrefilledShopperInformation
public var billingAddress: Adyen.PostalAddress? { get set }
```
```javascript
// Parent: PrefilledShopperInformation
public var deliveryAddress: Adyen.PostalAddress? { get set }
```
```javascript
// Parent: PrefilledShopperInformation
public var socialSecurityNumber: Swift.String? { get set }
```
```javascript
// Parent: PrefilledShopperInformation
public var card: Adyen.PrefilledShopperInformation.CardInformation? { get set }
```
```javascript
// Parent: PrefilledShopperInformation
public init(shopperName: Adyen.ShopperName? = $DEFAULT_ARG, emailAddress: Swift.String? = $DEFAULT_ARG, telephoneNumber: Swift.String? = $DEFAULT_ARG, billingAddress: Adyen.PostalAddress? = $DEFAULT_ARG, deliveryAddress: Adyen.PostalAddress? = $DEFAULT_ARG, socialSecurityNumber: Swift.String? = $DEFAULT_ARG, card: Adyen.PrefilledShopperInformation.CardInformation? = $DEFAULT_ARG) -> Adyen.PrefilledShopperInformation
```
```javascript
// Parent: PrefilledShopperInformation
public init(shopperName: Adyen.ShopperName? = $DEFAULT_ARG, emailAddress: Swift.String? = $DEFAULT_ARG, phoneNumber: Adyen.PhoneNumber? = $DEFAULT_ARG, billingAddress: Adyen.PostalAddress? = $DEFAULT_ARG, deliveryAddress: Adyen.PostalAddress? = $DEFAULT_ARG, socialSecurityNumber: Swift.String? = $DEFAULT_ARG, card: Adyen.PrefilledShopperInformation.CardInformation? = $DEFAULT_ARG) -> Adyen.PrefilledShopperInformation
```
```javascript
// Parent: PrefilledShopperInformation
public struct CardInformation
```
```javascript
// Parent: PrefilledShopperInformation.CardInformation
public let holderName: Swift.String { get }
```
```javascript
// Parent: PrefilledShopperInformation.CardInformation
public init(holderName: Swift.String) -> Adyen.PrefilledShopperInformation.CardInformation
```
```javascript
// Parent: Root
public protocol ShopperInformation
```
```javascript
// Parent: ShopperInformation
public var shopperName: Adyen.ShopperName? { get }
```
```javascript
// Parent: ShopperInformation
public var emailAddress: Swift.String? { get }
```
```javascript
// Parent: ShopperInformation
public var telephoneNumber: Swift.String? { get }
```
```javascript
// Parent: ShopperInformation
public var billingAddress: Adyen.PostalAddress? { get }
```
```javascript
// Parent: ShopperInformation
public var deliveryAddress: Adyen.PostalAddress? { get }
```
```javascript
// Parent: ShopperInformation
public var socialSecurityNumber: Swift.String? { get }
```
```javascript
// Parent: ShopperInformation
@_spi(AdyenInternal) public var shopperName: Adyen.ShopperName? { get }
```
```javascript
// Parent: ShopperInformation
@_spi(AdyenInternal) public var emailAddress: Swift.String? { get }
```
```javascript
// Parent: ShopperInformation
@_spi(AdyenInternal) public var telephoneNumber: Swift.String? { get }
```
```javascript
// Parent: ShopperInformation
@_spi(AdyenInternal) public var billingAddress: Adyen.PostalAddress? { get }
```
```javascript
// Parent: ShopperInformation
@_spi(AdyenInternal) public var deliveryAddress: Adyen.PostalAddress? { get }
```
```javascript
// Parent: ShopperInformation
@_spi(AdyenInternal) public var socialSecurityNumber: Swift.String? { get }
```
```javascript
// Parent: Root
public struct ShopperName : Decodable, Encodable, Equatable
```
```javascript
// Parent: ShopperName
public let firstName: Swift.String { get }
```
```javascript
// Parent: ShopperName
public let lastName: Swift.String { get }
```
```javascript
// Parent: ShopperName
public init(firstName: Swift.String, lastName: Swift.String) -> Adyen.ShopperName
```
```javascript
// Parent: ShopperName
public static func __derived_struct_equals(_: Adyen.ShopperName, _: Adyen.ShopperName) -> Swift.Bool
```
```javascript
// Parent: ShopperName
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
// Parent: ShopperName
public init(from: any Swift.Decoder) throws -> Adyen.ShopperName
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum Dimensions
```
```javascript
// Parent: Dimensions
@_spi(AdyenInternal) public static var leastPresentableScale: CoreGraphics.CGFloat { get set }
```
```javascript
// Parent: Dimensions
@_spi(AdyenInternal) public static var greatestPresentableHeightScale: CoreGraphics.CGFloat { get set }
```
```javascript
// Parent: Dimensions
@_spi(AdyenInternal) public static var maxAdaptiveWidth: CoreGraphics.CGFloat { get set }
```
```javascript
// Parent: Dimensions
@_spi(AdyenInternal) public static var greatestPresentableScale: CoreGraphics.CGFloat { get }
```
```javascript
// Parent: Dimensions
@_spi(AdyenInternal) public static func expectedWidth(for: UIKit.UIWindow? = $DEFAULT_ARG) -> CoreGraphics.CGFloat
```
```javascript
// Parent: Dimensions
@_spi(AdyenInternal) public static func keyWindowSize(for: UIKit.UIWindow? = $DEFAULT_ARG) -> CoreFoundation.CGRect
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct FormItemViewBuilder
```
```javascript
// Parent: FormItemViewBuilder
@_spi(AdyenInternal) public func build(with: Adyen.FormToggleItem) -> Adyen.FormItemView<Adyen.FormToggleItem>
```
```javascript
// Parent: FormItemViewBuilder
@_spi(AdyenInternal) public func build(with: Adyen.FormSplitItem) -> Adyen.FormItemView<Adyen.FormSplitItem>
```
```javascript
// Parent: FormItemViewBuilder
@_spi(AdyenInternal) public func build(with: Adyen.FormPhoneNumberItem) -> Adyen.FormItemView<Adyen.FormPhoneNumberItem>
```
```javascript
// Parent: FormItemViewBuilder
@_spi(AdyenInternal) public func build(with: Adyen.FormIssuersPickerItem) -> Adyen.BaseFormPickerItemView<Adyen.Issuer>
```
```javascript
// Parent: FormItemViewBuilder
@_spi(AdyenInternal) public func build(with: Adyen.FormTextInputItem) -> Adyen.FormItemView<Adyen.FormTextInputItem>
```
```javascript
// Parent: FormItemViewBuilder
@_spi(AdyenInternal) public func build(with: Adyen.ListItem) -> Adyen.ListItemView
```
```javascript
// Parent: FormItemViewBuilder
@_spi(AdyenInternal) public func build(with: Adyen.SelectableFormItem) -> Adyen.FormItemView<Adyen.SelectableFormItem>
```
```javascript
// Parent: FormItemViewBuilder
@_spi(AdyenInternal) public func build(with: Adyen.FormButtonItem) -> Adyen.FormItemView<Adyen.FormButtonItem>
```
```javascript
// Parent: FormItemViewBuilder
@_spi(AdyenInternal) public func build(with: Adyen.FormImageItem) -> Adyen.FormItemView<Adyen.FormImageItem>
```
```javascript
// Parent: FormItemViewBuilder
@_spi(AdyenInternal) public func build(with: Adyen.FormSeparatorItem) -> Adyen.FormItemView<Adyen.FormSeparatorItem>
```
```javascript
// Parent: FormItemViewBuilder
@_spi(AdyenInternal) public func build(with: Adyen.FormErrorItem) -> Adyen.FormItemView<Adyen.FormErrorItem>
```
```javascript
// Parent: FormItemViewBuilder
@_spi(AdyenInternal) public func build(with: Adyen.FormAddressItem) -> Adyen.FormItemView<Adyen.FormAddressItem>
```
```javascript
// Parent: FormItemViewBuilder
@_spi(AdyenInternal) public func build(with: Adyen.FormSpacerItem) -> Adyen.FormItemView<Adyen.FormSpacerItem>
```
```javascript
// Parent: FormItemViewBuilder
@_spi(AdyenInternal) public func build(with: Adyen.FormPostalCodeItem) -> Adyen.FormItemView<Adyen.FormPostalCodeItem>
```
```javascript
// Parent: FormItemViewBuilder
@_spi(AdyenInternal) public func build(with: Adyen.FormSearchButtonItem) -> Adyen.FormItemView<Adyen.FormSearchButtonItem>
```
```javascript
// Parent: FormItemViewBuilder
@_spi(AdyenInternal) public func build(with: Adyen.FormAddressPickerItem) -> Adyen.FormItemView<Adyen.FormAddressPickerItem>
```
```javascript
// Parent: FormItemViewBuilder
@_spi(AdyenInternal) public func build<Value where Value : Adyen.FormPickable>(with: Adyen.FormPickerItem<Value>) -> Adyen.FormItemView<Adyen.FormPickerItem<Value>>
```
```javascript
// Parent: FormItemViewBuilder
@_spi(AdyenInternal) public func build(with: Adyen.FormPhoneExtensionPickerItem) -> Adyen.FormPhoneExtensionPickerItemView
```
```javascript
// Parent: FormItemViewBuilder
@_spi(AdyenInternal) public static func build(_: any Adyen.FormItem) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol FormViewProtocol
```
```javascript
// Parent: FormViewProtocol
@_spi(AdyenInternal) public func add<Self, T where Self : Adyen.FormViewProtocol, T : Adyen.FormItem>(item: T?) -> Swift.Void
```
```javascript
// Parent: FormViewProtocol
@_spi(AdyenInternal) public func displayValidation<Self where Self : Adyen.FormViewProtocol>() -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) @objc open class FormViewController : AdyenCompatible, AdyenObserver, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, FormTextItemViewDelegate, FormViewProtocol, Hashable, NSCoding, NSExtensionRequestHandling, NSObjectProtocol, PreferredContentSizeConsumer, Sendable, UIActivityItemsConfigurationProviding, UIAppearanceContainer, UIContentContainer, UIFocusEnvironment, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UIStateRestoring, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring, ViewControllerPresenter
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) public var requiresKeyboardInput: Swift.Bool { get }
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) public let style: any Adyen.ViewStyle { get }
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) public weak var delegate: (any Adyen.ViewControllerDelegate)? { get set }
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) public init(style: any Adyen.ViewStyle, localizationParameters: Adyen.LocalizationParameters?) -> Adyen.FormViewController
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) @objc override open dynamic func viewDidLoad() -> Swift.Void
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) @objc override open dynamic func viewWillAppear(_: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) @objc override open dynamic func viewDidAppear(_: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) @objc override open dynamic func viewWillDisappear(_: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) @objc override open dynamic func viewDidDisappear(_: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) @objc override public dynamic var preferredContentSize: CoreFoundation.CGSize { get set }
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) public func willUpdatePreferredContentSize() -> Swift.Void
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) public func didUpdatePreferredContentSize() -> Swift.Void
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) public func append(_: some Adyen.FormItem) -> Swift.Void
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) public let localizationParameters: Adyen.LocalizationParameters? { get }
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) public func validate() -> Swift.Bool
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) public func showValidation() -> Swift.Void
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) public func resetForm() -> Swift.Void
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) @discardableResult @objc override public dynamic func resignFirstResponder() -> Swift.Bool
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) @objc override public dynamic init(nibName: Swift.String?, bundle: Foundation.Bundle?) -> Adyen.FormViewController
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) public func add(item: (some Adyen.FormItem)?) -> Swift.Void
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) public func displayValidation() -> Swift.Void
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) public func didReachMaximumLength(in: Adyen.FormTextItemView<some Adyen.FormTextItem>) -> Swift.Void
```
```javascript
// Parent: FormViewController
@_spi(AdyenInternal) public func didSelectReturnKey(in: Adyen.FormTextItemView<some Adyen.FormTextItem>) -> Swift.Void
```
```javascript
// Parent: Root
public struct AddressStyle : FormValueItemStyle, TintableStyle, ViewStyle
```
```javascript
// Parent: AddressStyle
public var title: Adyen.TextStyle { get set }
```
```javascript
// Parent: AddressStyle
public var textField: Adyen.FormTextItemStyle { get set }
```
```javascript
// Parent: AddressStyle
public var tintColor: UIKit.UIColor? { get set }
```
```javascript
// Parent: AddressStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: AddressStyle
public var separatorColor: UIKit.UIColor? { get }
```
```javascript
// Parent: AddressStyle
public init(title: Adyen.TextStyle, textField: Adyen.FormTextItemStyle, tintColor: UIKit.UIColor? = $DEFAULT_ARG, backgroundColor: UIKit.UIColor = $DEFAULT_ARG) -> Adyen.AddressStyle
```
```javascript
// Parent: AddressStyle
public init() -> Adyen.AddressStyle
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum AddressField : CaseIterable, Equatable, Hashable, RawRepresentable
```
```javascript
// Parent: AddressField
@_spi(AdyenInternal) public case street
```
```javascript
// Parent: AddressField
@_spi(AdyenInternal) public case houseNumberOrName
```
```javascript
// Parent: AddressField
@_spi(AdyenInternal) public case apartment
```
```javascript
// Parent: AddressField
@_spi(AdyenInternal) public case postalCode
```
```javascript
// Parent: AddressField
@_spi(AdyenInternal) public case city
```
```javascript
// Parent: AddressField
@_spi(AdyenInternal) public case stateOrProvince
```
```javascript
// Parent: AddressField
@_spi(AdyenInternal) public case country
```
```javascript
// Parent: AddressField
@_spi(AdyenInternal) @inlinable public init(rawValue: Swift.String) -> Adyen.AddressField?
```
```javascript
// Parent: AddressField
@_spi(AdyenInternal) public typealias AllCases = [Adyen.AddressField]
```
```javascript
// Parent: AddressField
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
// Parent: AddressField
@_spi(AdyenInternal) public static var allCases: [Adyen.AddressField] { get }
```
```javascript
// Parent: AddressField
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum AddressFormScheme
```
```javascript
// Parent: AddressFormScheme
@_spi(AdyenInternal) public var children: [Adyen.AddressField] { get }
```
```javascript
// Parent: AddressFormScheme
@_spi(AdyenInternal) public case item(Adyen.AddressField)
```
```javascript
// Parent: AddressFormScheme
@_spi(AdyenInternal) public case split(Adyen.AddressField, Adyen.AddressField)
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct AddressViewModel
```
```javascript
// Parent: AddressViewModel
@_spi(AdyenInternal) public var optionalFields: [Adyen.AddressField] { get set }
```
```javascript
// Parent: AddressViewModel
@_spi(AdyenInternal) public var scheme: [Adyen.AddressFormScheme] { get set }
```
```javascript
// Parent: AddressViewModel
@_spi(AdyenInternal) public init(labels: [Adyen.AddressField : Adyen.LocalizationKey], placeholder: [Adyen.AddressField : Adyen.LocalizationKey], optionalFields: [Adyen.AddressField], scheme: [Adyen.AddressFormScheme]) -> Adyen.AddressViewModel
```
```javascript
// Parent: AddressViewModel
@_spi(AdyenInternal) public var requiredFields: Swift.Set<Adyen.AddressField> { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct AddressViewModelBuilderContext
```
```javascript
// Parent: AddressViewModelBuilderContext
@_spi(AdyenInternal) public var countryCode: Swift.String { get set }
```
```javascript
// Parent: AddressViewModelBuilderContext
@_spi(AdyenInternal) public var isOptional: Swift.Bool { get set }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol AddressViewModelBuilder
```
```javascript
// Parent: AddressViewModelBuilder
@_spi(AdyenInternal) public func build<Self where Self : Adyen.AddressViewModelBuilder>(context: Adyen.AddressViewModelBuilderContext) -> Adyen.AddressViewModel
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct DefaultAddressViewModelBuilder : AddressViewModelBuilder
```
```javascript
// Parent: DefaultAddressViewModelBuilder
@_spi(AdyenInternal) public init() -> Adyen.DefaultAddressViewModelBuilder
```
```javascript
// Parent: DefaultAddressViewModelBuilder
@_spi(AdyenInternal) public func build(context: Adyen.AddressViewModelBuilderContext) -> Adyen.AddressViewModel
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormAddressItem : AdyenObserver, FormItem, Hidable
```
```javascript
// Parent: FormAddressItem
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get set }
```
```javascript
// Parent: FormAddressItem
@_spi(AdyenInternal) override public var value: Adyen.PostalAddress { get set }
```
```javascript
// Parent: FormAddressItem
@_spi(AdyenInternal) override public var subitems: [any Adyen.FormItem] { get }
```
```javascript
// Parent: FormAddressItem
@_spi(AdyenInternal) public var addressViewModel: Adyen.AddressViewModel { get }
```
```javascript
// Parent: FormAddressItem
@_spi(AdyenInternal) override public var title: Swift.String? { get set }
```
```javascript
// Parent: FormAddressItem
@_spi(AdyenInternal) public init(initialCountry: Swift.String, configuration: Adyen.FormAddressItem.Configuration, identifier: Swift.String? = $DEFAULT_ARG, presenter: (any Adyen.ViewControllerPresenter)?, addressViewModelBuilder: any Adyen.AddressViewModelBuilder) -> Adyen.FormAddressItem
```
```javascript
// Parent: FormAddressItem
@_spi(AdyenInternal) public func updateOptionalStatus(isOptional: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: FormAddressItem
@_spi(AdyenInternal) override public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: FormAddressItem
@_spi(AdyenInternal) public func reset() -> Swift.Void
```
```javascript
// Parent: FormAddressItem
@_spi(AdyenInternal) public struct Configuration
```
```javascript
// Parent: FormAddressItem.Configuration
@_spi(AdyenInternal) public init(style: Adyen.AddressStyle = $DEFAULT_ARG, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, supportedCountryCodes: [Swift.String]? = $DEFAULT_ARG, showsHeader: Swift.Bool = $DEFAULT_ARG) -> Adyen.FormAddressItem.Configuration
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormPostalCodeItem : FormItem, InputViewRequiringFormItem, ValidatableFormItem
```
```javascript
// Parent: FormPostalCodeItem
@_spi(AdyenInternal) public init(style: Adyen.FormTextItemStyle = $DEFAULT_ARG, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG) -> Adyen.FormPostalCodeItem
```
```javascript
// Parent: FormPostalCodeItem
@_spi(AdyenInternal) public func updateOptionalStatus(isOptional: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: FormPostalCodeItem
@_spi(AdyenInternal) override public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: FormPostalCodeItem
@_spi(AdyenInternal) override public init(style: Adyen.FormTextItemStyle) -> Adyen.FormPostalCodeItem
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormRegionPickerItem : FormItem, ValidatableFormItem
```
```javascript
// Parent: FormRegionPickerItem
@_spi(AdyenInternal) public required init(preselectedRegion: Adyen.Region?, selectableRegions: [Adyen.Region], validationFailureMessage: Swift.String?, title: Swift.String, placeholder: Swift.String, style: Adyen.FormTextItemStyle, presenter: (any Adyen.ViewControllerPresenter)?, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormRegionPickerItem
```
```javascript
// Parent: FormRegionPickerItem
@_spi(AdyenInternal) public func updateValue(with: Adyen.Region?) -> Swift.Void
```
```javascript
// Parent: FormRegionPickerItem
@_spi(AdyenInternal) override public func resetValue() -> Swift.Void
```
```javascript
// Parent: FormRegionPickerItem
@_spi(AdyenInternal) override public func updateValidationFailureMessage() -> Swift.Void
```
```javascript
// Parent: FormRegionPickerItem
@_spi(AdyenInternal) override public func updateFormattedValue() -> Swift.Void
```
```javascript
// Parent: FormRegionPickerItem
@_spi(AdyenInternal) override public init(preselectedValue: Adyen.FormPickerElement?, selectableValues: [Adyen.FormPickerElement], title: Swift.String, placeholder: Swift.String, style: Adyen.FormTextItemStyle, presenter: (any Adyen.ViewControllerPresenter)?, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormRegionPickerItem
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormAddressPickerItem : FormItem, Hidable, ValidatableFormItem
```
```javascript
// Parent: FormAddressPickerItem
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get set }
```
```javascript
// Parent: FormAddressPickerItem
@_spi(AdyenInternal) public enum AddressType : Equatable, Hashable
```
```javascript
// Parent: FormAddressPickerItem.AddressType
@_spi(AdyenInternal) public case billing
```
```javascript
// Parent: FormAddressPickerItem.AddressType
@_spi(AdyenInternal) public case delivery
```
```javascript
// Parent: FormAddressPickerItem.AddressType
@_spi(AdyenInternal) public static func __derived_enum_equals(_: Adyen.FormAddressPickerItem.AddressType, _: Adyen.FormAddressPickerItem.AddressType) -> Swift.Bool
```
```javascript
// Parent: FormAddressPickerItem.AddressType
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: FormAddressPickerItem.AddressType
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
// Parent: FormAddressPickerItem.AddressType
@_spi(AdyenInternal) public func placeholder(with: Adyen.LocalizationParameters?) -> Swift.String
```
```javascript
// Parent: FormAddressPickerItem.AddressType
@_spi(AdyenInternal) public func title(with: Adyen.LocalizationParameters?) -> Swift.String
```
```javascript
// Parent: FormAddressPickerItem
@_spi(AdyenInternal) public var addressViewModel: Adyen.AddressViewModel { get }
```
```javascript
// Parent: FormAddressPickerItem
@_spi(AdyenInternal) override public var value: Adyen.PostalAddress? { get set }
```
```javascript
// Parent: FormAddressPickerItem
@_spi(AdyenInternal) public init(for: Adyen.FormAddressPickerItem.AddressType, initialCountry: Swift.String, supportedCountryCodes: [Swift.String]?, prefillAddress: Adyen.PostalAddress?, style: Adyen.FormComponentStyle, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, identifier: Swift.String? = $DEFAULT_ARG, addressViewModelBuilder: any Adyen.AddressViewModelBuilder = $DEFAULT_ARG, presenter: any Adyen.ViewControllerPresenter, lookupProvider: (any Adyen.AddressLookupProvider)? = $DEFAULT_ARG) -> Adyen.FormAddressPickerItem
```
```javascript
// Parent: FormAddressPickerItem
@_spi(AdyenInternal) public func updateOptionalStatus(isOptional: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: FormAddressPickerItem
@_spi(AdyenInternal) override public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: FormAddressPickerItem
@_spi(AdyenInternal) override public func isValid() -> Swift.Bool
```
```javascript
// Parent: FormAddressPickerItem
@_spi(AdyenInternal) override public func validationStatus() -> Adyen.ValidationStatus?
```
```javascript
// Parent: FormAddressPickerItem
@_spi(AdyenInternal) override public init(value: Adyen.PostalAddress?, style: Adyen.FormTextItemStyle, placeholder: Swift.String) -> Adyen.FormAddressPickerItem
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public class FormAttributedLabelItem : FormItem
```
```javascript
// Parent: FormAttributedLabelItem
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
// Parent: FormAttributedLabelItem
@_spi(AdyenInternal) public init(originalText: Swift.String, links: [Swift.String], style: Adyen.TextStyle, linkTextStyle: Adyen.TextStyle, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormAttributedLabelItem
```
```javascript
// Parent: FormAttributedLabelItem
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
// Parent: FormAttributedLabelItem
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public class FormContainerItem : FormItem, Hidable
```
```javascript
// Parent: FormContainerItem
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get set }
```
```javascript
// Parent: FormContainerItem
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
// Parent: FormContainerItem
@_spi(AdyenInternal) public init(content: any Adyen.FormItem, padding: UIKit.UIEdgeInsets = $DEFAULT_ARG, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormContainerItem
```
```javascript
// Parent: FormContainerItem
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
// Parent: FormContainerItem
@_spi(AdyenInternal) public var content: any Adyen.FormItem { get }
```
```javascript
// Parent: FormContainerItem
@_spi(AdyenInternal) public var padding: UIKit.UIEdgeInsets { get set }
```
```javascript
// Parent: FormContainerItem
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public class FormLabelItem : FormItem
```
```javascript
// Parent: FormLabelItem
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
// Parent: FormLabelItem
@_spi(AdyenInternal) public init(text: Swift.String, style: Adyen.TextStyle, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormLabelItem
```
```javascript
// Parent: FormLabelItem
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
// Parent: FormLabelItem
@_spi(AdyenInternal) public var style: Adyen.TextStyle { get set }
```
```javascript
// Parent: FormLabelItem
@_spi(AdyenInternal) public var text: Swift.String { get set }
```
```javascript
// Parent: FormLabelItem
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: Root
@_spi(AdyenInternal) open class FormVerticalStackItemView<FormItemType where FormItemType : Adyen.FormItem> : AdyenCompatible, AdyenObserver, AnyFormItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: FormVerticalStackItemView
@_spi(AdyenInternal) public var views: [any Adyen.AnyFormItemView] { get }
```
```javascript
// Parent: FormVerticalStackItemView
@_spi(AdyenInternal) public required init<FormItemType where FormItemType : Adyen.FormItem>(item: FormItemType) -> Adyen.FormVerticalStackItemView<FormItemType>
```
```javascript
// Parent: FormVerticalStackItemView
@_spi(AdyenInternal) public convenience init<FormItemType where FormItemType : Adyen.FormItem>(item: FormItemType, itemSpacing: CoreGraphics.CGFloat) -> Adyen.FormVerticalStackItemView<FormItemType>
```
```javascript
// Parent: FormVerticalStackItemView
@_spi(AdyenInternal) override public var childItemViews: [any Adyen.AnyFormItemView] { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormButtonItem : FormItem
```
```javascript
// Parent: FormButtonItem
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
// Parent: FormButtonItem
@_spi(AdyenInternal) public let style: Adyen.FormButtonItemStyle { get }
```
```javascript
// Parent: FormButtonItem
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
// Parent: FormButtonItem
@_spi(AdyenInternal) public var title: Swift.String? { get set }
```
```javascript
// Parent: FormButtonItem
@_spi(AdyenInternal) public var $title: Adyen.AdyenObservable<Swift.String?> { get }
```
```javascript
// Parent: FormButtonItem
@_spi(AdyenInternal) public var showsActivityIndicator: Swift.Bool { get set }
```
```javascript
// Parent: FormButtonItem
@_spi(AdyenInternal) public var $showsActivityIndicator: Adyen.AdyenObservable<Swift.Bool> { get }
```
```javascript
// Parent: FormButtonItem
@_spi(AdyenInternal) public var enabled: Swift.Bool { get set }
```
```javascript
// Parent: FormButtonItem
@_spi(AdyenInternal) public var $enabled: Adyen.AdyenObservable<Swift.Bool> { get }
```
```javascript
// Parent: FormButtonItem
@_spi(AdyenInternal) public var buttonSelectionHandler: (() -> Swift.Void)? { get set }
```
```javascript
// Parent: FormButtonItem
@_spi(AdyenInternal) public init(style: Adyen.FormButtonItemStyle) -> Adyen.FormButtonItem
```
```javascript
// Parent: FormButtonItem
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: Root
public struct FormButtonItemStyle : ViewStyle
```
```javascript
// Parent: FormButtonItemStyle
public var button: Adyen.ButtonStyle { get set }
```
```javascript
// Parent: FormButtonItemStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: FormButtonItemStyle
public init(button: Adyen.ButtonStyle) -> Adyen.FormButtonItemStyle
```
```javascript
// Parent: FormButtonItemStyle
public init(button: Adyen.ButtonStyle, background: UIKit.UIColor) -> Adyen.FormButtonItemStyle
```
```javascript
// Parent: FormButtonItemStyle
public static func main(font: UIKit.UIFont, textColor: UIKit.UIColor, mainColor: UIKit.UIColor, cornerRadius: CoreGraphics.CGFloat) -> Adyen.FormButtonItemStyle
```
```javascript
// Parent: FormButtonItemStyle
public static func main(font: UIKit.UIFont, textColor: UIKit.UIColor, mainColor: UIKit.UIColor) -> Adyen.FormButtonItemStyle
```
```javascript
// Parent: FormButtonItemStyle
public static func main(font: UIKit.UIFont, textColor: UIKit.UIColor, mainColor: UIKit.UIColor, cornerRounding: Adyen.CornerRounding) -> Adyen.FormButtonItemStyle
```
```javascript
// Parent: FormButtonItemStyle
public static func secondary(font: UIKit.UIFont, textColor: UIKit.UIColor) -> Adyen.FormButtonItemStyle
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormSearchButtonItem : FormItem
```
```javascript
// Parent: FormSearchButtonItem
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
// Parent: FormSearchButtonItem
@_spi(AdyenInternal) public let style: any Adyen.ViewStyle { get }
```
```javascript
// Parent: FormSearchButtonItem
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
// Parent: FormSearchButtonItem
@_spi(AdyenInternal) public var placeholder: Swift.String? { get set }
```
```javascript
// Parent: FormSearchButtonItem
@_spi(AdyenInternal) public var $placeholder: Adyen.AdyenObservable<Swift.String?> { get }
```
```javascript
// Parent: FormSearchButtonItem
@_spi(AdyenInternal) public let selectionHandler: () -> Swift.Void { get }
```
```javascript
// Parent: FormSearchButtonItem
@_spi(AdyenInternal) public init(placeholder: Swift.String, style: any Adyen.ViewStyle, identifier: Swift.String, selectionHandler: () -> Swift.Void) -> Adyen.FormSearchButtonItem
```
```javascript
// Parent: FormSearchButtonItem
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormErrorItem : FormItem, Hidable
```
```javascript
// Parent: FormErrorItem
@_spi(AdyenInternal) public var message: Swift.String? { get set }
```
```javascript
// Parent: FormErrorItem
@_spi(AdyenInternal) public var $message: Adyen.AdyenObservable<Swift.String?> { get }
```
```javascript
// Parent: FormErrorItem
@_spi(AdyenInternal) public let iconName: Swift.String { get }
```
```javascript
// Parent: FormErrorItem
@_spi(AdyenInternal) public let style: Adyen.FormErrorItemStyle { get }
```
```javascript
// Parent: FormErrorItem
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
// Parent: FormErrorItem
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get set }
```
```javascript
// Parent: FormErrorItem
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
// Parent: FormErrorItem
@_spi(AdyenInternal) public init(message: Swift.String? = $DEFAULT_ARG, iconName: Swift.String = $DEFAULT_ARG, style: Adyen.FormErrorItemStyle = $DEFAULT_ARG) -> Adyen.FormErrorItem
```
```javascript
// Parent: FormErrorItem
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: Root
public struct FormErrorItemStyle : ViewStyle
```
```javascript
// Parent: FormErrorItemStyle
public var message: Adyen.TextStyle { get set }
```
```javascript
// Parent: FormErrorItemStyle
public var cornerRounding: Adyen.CornerRounding { get set }
```
```javascript
// Parent: FormErrorItemStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: FormErrorItemStyle
public init(message: Adyen.TextStyle) -> Adyen.FormErrorItemStyle
```
```javascript
// Parent: FormErrorItemStyle
public init() -> Adyen.FormErrorItemStyle
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public class FormImageItem : FormItem, Hidable
```
```javascript
// Parent: FormImageItem
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get set }
```
```javascript
// Parent: FormImageItem
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
// Parent: FormImageItem
@_spi(AdyenInternal) public var name: Swift.String { get set }
```
```javascript
// Parent: FormImageItem
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
// Parent: FormImageItem
@_spi(AdyenInternal) public var size: CoreFoundation.CGSize { get set }
```
```javascript
// Parent: FormImageItem
@_spi(AdyenInternal) public var style: Adyen.ImageStyle? { get set }
```
```javascript
// Parent: FormImageItem
@_spi(AdyenInternal) public init(name: Swift.String, size: CoreFoundation.CGSize? = $DEFAULT_ARG, style: Adyen.ImageStyle? = $DEFAULT_ARG, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormImageItem
```
```javascript
// Parent: FormImageItem
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol Hidable
```
```javascript
// Parent: Hidable
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get }
```
```javascript
// Parent: Hidable
@_spi(AdyenInternal) public var isVisible: Swift.Bool { get set }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol FormItem<Self : AnyObject>
```
```javascript
// Parent: FormItem
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
// Parent: FormItem
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get }
```
```javascript
// Parent: FormItem
@_spi(AdyenInternal) public func build<Self where Self : Adyen.FormItem>(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: FormItem
@_spi(AdyenInternal) public func addingDefaultMargins<Self where Self : Adyen.FormItem>() -> Adyen.FormContainerItem
```
```javascript
// Parent: FormItem
@_spi(AdyenInternal) public var flatSubitems: [any Adyen.FormItem] { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol ValidatableFormItem<Self : Adyen.FormItem> : FormItem
```
```javascript
// Parent: ValidatableFormItem
@_spi(AdyenInternal) public var validationFailureMessage: Swift.String? { get set }
```
```javascript
// Parent: ValidatableFormItem
@_spi(AdyenInternal) public func isValid<Self where Self : Adyen.ValidatableFormItem>() -> Swift.Bool
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol InputViewRequiringFormItem<Self : Adyen.FormItem> : FormItem
```
```javascript
// Parent: Root
@_spi(AdyenInternal) open class FormItemView<ItemType where ItemType : Adyen.FormItem> : AdyenCompatible, AdyenObserver, AnyFormItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: FormItemView
@_spi(AdyenInternal) public let item: ItemType { get }
```
```javascript
// Parent: FormItemView
@_spi(AdyenInternal) public required init<ItemType where ItemType : Adyen.FormItem>(item: ItemType) -> Adyen.FormItemView<ItemType>
```
```javascript
// Parent: FormItemView
@_spi(AdyenInternal) open var childItemViews: [any Adyen.AnyFormItemView] { get }
```
```javascript
// Parent: FormItemView
@_spi(AdyenInternal) public func reset<ItemType where ItemType : Adyen.FormItem>() -> Swift.Void
```
```javascript
// Parent: FormItemView
@_spi(AdyenInternal) @objc override public dynamic init<ItemType where ItemType : Adyen.FormItem>(frame: CoreFoundation.CGRect) -> Adyen.FormItemView<ItemType>
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol AnyFormItemView<Self : UIKit.UIView>
```
```javascript
// Parent: AnyFormItemView
@_spi(AdyenInternal) public var parentItemView: (any Adyen.AnyFormItemView)? { get }
```
```javascript
// Parent: AnyFormItemView
@_spi(AdyenInternal) public var childItemViews: [any Adyen.AnyFormItemView] { get }
```
```javascript
// Parent: AnyFormItemView
@_spi(AdyenInternal) public func reset<Self where Self : Adyen.AnyFormItemView>() -> Swift.Void
```
```javascript
// Parent: AnyFormItemView
@_spi(AdyenInternal) public var parentItemView: (any Adyen.AnyFormItemView)? { get }
```
```javascript
// Parent: AnyFormItemView
@_spi(AdyenInternal) public var flatSubitemViews: [any Adyen.AnyFormItemView] { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormPhoneNumberItem : FormItem, InputViewRequiringFormItem, ValidatableFormItem
```
```javascript
// Parent: FormPhoneNumberItem
@_spi(AdyenInternal) public var prefix: Swift.String { get }
```
```javascript
// Parent: FormPhoneNumberItem
@_spi(AdyenInternal) public var phoneNumber: Swift.String { get }
```
```javascript
// Parent: FormPhoneNumberItem
@_spi(AdyenInternal) public init(phoneNumber: Adyen.PhoneNumber?, selectableValues: [Adyen.PhoneExtension], style: Adyen.FormTextItemStyle, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, presenter: Adyen.WeakReferenceViewControllerPresenter) -> Adyen.FormPhoneNumberItem
```
```javascript
// Parent: FormPhoneNumberItem
@_spi(AdyenInternal) override public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: FormPhoneNumberItem
@_spi(AdyenInternal) override public init(style: Adyen.FormTextItemStyle) -> Adyen.FormPhoneNumberItem
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormPhoneExtensionPickerItem : FormItem, ValidatableFormItem
```
```javascript
// Parent: FormPhoneExtensionPickerItem
@_spi(AdyenInternal) public required init(preselectedExtension: Adyen.PhoneExtension?, selectableExtensions: [Adyen.PhoneExtension], validationFailureMessage: Swift.String?, style: Adyen.FormTextItemStyle, presenter: Adyen.WeakReferenceViewControllerPresenter, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormPhoneExtensionPickerItem
```
```javascript
// Parent: FormPhoneExtensionPickerItem
@_spi(AdyenInternal) override public func resetValue() -> Swift.Void
```
```javascript
// Parent: FormPhoneExtensionPickerItem
@_spi(AdyenInternal) override public func updateValidationFailureMessage() -> Swift.Void
```
```javascript
// Parent: FormPhoneExtensionPickerItem
@_spi(AdyenInternal) override public func updateFormattedValue() -> Swift.Void
```
```javascript
// Parent: FormPhoneExtensionPickerItem
@_spi(AdyenInternal) override public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: FormPhoneExtensionPickerItem
@_spi(AdyenInternal) override public init(preselectedValue: Adyen.PhoneExtension?, selectableValues: [Adyen.PhoneExtension], title: Swift.String, placeholder: Swift.String, style: Adyen.FormTextItemStyle, presenter: (any Adyen.ViewControllerPresenter)?, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormPhoneExtensionPickerItem
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormPhoneExtensionPickerItemView : AdyenCompatible, AdyenObserver, AnyFormItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: FormPhoneExtensionPickerItemView
@_spi(AdyenInternal) @objc override public var accessibilityIdentifier: Swift.String? { get set }
```
```javascript
// Parent: FormPhoneExtensionPickerItemView
@_spi(AdyenInternal) public required init(item: Adyen.FormPhoneExtensionPickerItem) -> Adyen.FormPhoneExtensionPickerItemView
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormSegmentedControlItem : FormItem
```
```javascript
// Parent: FormSegmentedControlItem
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
// Parent: FormSegmentedControlItem
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
// Parent: FormSegmentedControlItem
@_spi(AdyenInternal) public var style: Adyen.SegmentedControlStyle { get set }
```
```javascript
// Parent: FormSegmentedControlItem
@_spi(AdyenInternal) public var selectionHandler: ((Swift.Int) -> Swift.Void)? { get set }
```
```javascript
// Parent: FormSegmentedControlItem
@_spi(AdyenInternal) public init(items: [Swift.String], style: Adyen.SegmentedControlStyle, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormSegmentedControlItem
```
```javascript
// Parent: FormSegmentedControlItem
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public class SelectableFormItem : FormItem, Hidable
```
```javascript
// Parent: SelectableFormItem
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
// Parent: SelectableFormItem
@_spi(AdyenInternal) public var title: Swift.String { get set }
```
```javascript
// Parent: SelectableFormItem
@_spi(AdyenInternal) public var imageUrl: Foundation.URL? { get set }
```
```javascript
// Parent: SelectableFormItem
@_spi(AdyenInternal) public var isSelected: Swift.Bool { get set }
```
```javascript
// Parent: SelectableFormItem
@_spi(AdyenInternal) public var $isSelected: Adyen.AdyenObservable<Swift.Bool> { get }
```
```javascript
// Parent: SelectableFormItem
@_spi(AdyenInternal) public var selectionHandler: (() -> Swift.Void)? { get set }
```
```javascript
// Parent: SelectableFormItem
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
// Parent: SelectableFormItem
@_spi(AdyenInternal) public let accessibilityLabel: Swift.String { get }
```
```javascript
// Parent: SelectableFormItem
@_spi(AdyenInternal) public let style: Adyen.SelectableFormItemStyle { get }
```
```javascript
// Parent: SelectableFormItem
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get set }
```
```javascript
// Parent: SelectableFormItem
@_spi(AdyenInternal) public init(title: Swift.String, imageUrl: Foundation.URL? = $DEFAULT_ARG, isSelected: Swift.Bool = $DEFAULT_ARG, style: Adyen.SelectableFormItemStyle, identifier: Swift.String? = $DEFAULT_ARG, accessibilityLabel: Swift.String? = $DEFAULT_ARG, selectionHandler: (() -> Swift.Void)? = $DEFAULT_ARG) -> Adyen.SelectableFormItem
```
```javascript
// Parent: SelectableFormItem
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct SelectableFormItemStyle : Equatable, ViewStyle
```
```javascript
// Parent: SelectableFormItemStyle
@_spi(AdyenInternal) public var title: Adyen.TextStyle { get set }
```
```javascript
// Parent: SelectableFormItemStyle
@_spi(AdyenInternal) public var imageStyle: Adyen.ImageStyle { get set }
```
```javascript
// Parent: SelectableFormItemStyle
@_spi(AdyenInternal) public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: SelectableFormItemStyle
@_spi(AdyenInternal) public init(title: Adyen.TextStyle) -> Adyen.SelectableFormItemStyle
```
```javascript
// Parent: SelectableFormItemStyle
@_spi(AdyenInternal) public static func ==(_: Adyen.SelectableFormItemStyle, _: Adyen.SelectableFormItemStyle) -> Swift.Bool
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class SelectableFormItemView : AdyenCompatible, AdyenObserver, AnyFormItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: SelectableFormItemView
@_spi(AdyenInternal) public required init(item: Adyen.SelectableFormItem) -> Adyen.SelectableFormItemView
```
```javascript
// Parent: SelectableFormItemView
@_spi(AdyenInternal) @objc override public func didMoveToWindow() -> Swift.Void
```
```javascript
// Parent: SelectableFormItemView
@_spi(AdyenInternal) @objc override public func layoutSubviews() -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormSeparatorItem : FormItem
```
```javascript
// Parent: FormSeparatorItem
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
// Parent: FormSeparatorItem
@_spi(AdyenInternal) public let color: UIKit.UIColor { get }
```
```javascript
// Parent: FormSeparatorItem
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
// Parent: FormSeparatorItem
@_spi(AdyenInternal) public init(color: UIKit.UIColor) -> Adyen.FormSeparatorItem
```
```javascript
// Parent: FormSeparatorItem
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormSpacerItem : FormItem
```
```javascript
// Parent: FormSpacerItem
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
// Parent: FormSpacerItem
@_spi(AdyenInternal) public let subitems: [any Adyen.FormItem] { get }
```
```javascript
// Parent: FormSpacerItem
@_spi(AdyenInternal) public let standardSpaceMultiplier: Swift.Int { get }
```
```javascript
// Parent: FormSpacerItem
@_spi(AdyenInternal) public init(numberOfSpaces: Swift.Int = $DEFAULT_ARG) -> Adyen.FormSpacerItem
```
```javascript
// Parent: FormSpacerItem
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormSpacerItemView : AdyenCompatible, AdyenObserver, AnyFormItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormSplitItem : FormItem
```
```javascript
// Parent: FormSplitItem
@_spi(AdyenInternal) public let style: any Adyen.ViewStyle { get }
```
```javascript
// Parent: FormSplitItem
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
// Parent: FormSplitItem
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get }
```
```javascript
// Parent: FormSplitItem
@_spi(AdyenInternal) public init(items: any Adyen.FormItem..., style: any Adyen.ViewStyle) -> Adyen.FormSplitItem
```
```javascript
// Parent: FormSplitItem
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormTextInputItem : FormItem, Hidable, InputViewRequiringFormItem, ValidatableFormItem
```
```javascript
// Parent: FormTextInputItem
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get set }
```
```javascript
// Parent: FormTextInputItem
@_spi(AdyenInternal) public var isEnabled: Swift.Bool { get set }
```
```javascript
// Parent: FormTextInputItem
@_spi(AdyenInternal) public var $isEnabled: Adyen.AdyenObservable<Swift.Bool> { get }
```
```javascript
// Parent: FormTextInputItem
@_spi(AdyenInternal) override public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: FormTextInputItem
@_spi(AdyenInternal) override public init(style: Adyen.FormTextItemStyle = $DEFAULT_ARG) -> Adyen.FormTextInputItem
```
```javascript
// Parent: FormTextInputItem
@_spi(AdyenInternal) override public func isValid() -> Swift.Bool
```
```javascript
// Parent: FormTextInputItem
@_spi(AdyenInternal) public func focus() -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormTextInputItemView : AdyenCompatible, AdyenObserver, AnyFormItemView, AnyFormTextItemView, AnyFormValidatableValueItemView, AnyFormValueItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITextFieldDelegate, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: FormTextInputItemView
@_spi(AdyenInternal) public required init(item: Adyen.FormTextInputItem) -> Adyen.FormTextInputItemView
```
```javascript
// Parent: Root
@_spi(AdyenInternal) open class FormTextItem : FormItem, InputViewRequiringFormItem, ValidatableFormItem
```
```javascript
// Parent: FormTextItem
@_spi(AdyenInternal) public var placeholder: Swift.String? { get set }
```
```javascript
// Parent: FormTextItem
@_spi(AdyenInternal) public var $placeholder: Adyen.AdyenObservable<Swift.String?> { get }
```
```javascript
// Parent: FormTextItem
@_spi(AdyenInternal) override public var value: Swift.String { get set }
```
```javascript
// Parent: FormTextItem
@_spi(AdyenInternal) public var formatter: (any Adyen.Formatter)? { get set }
```
```javascript
// Parent: FormTextItem
@_spi(AdyenInternal) public var validator: (any Adyen.Validator)? { get set }
```
```javascript
// Parent: FormTextItem
@_spi(AdyenInternal) public var autocapitalizationType: UIKit.UITextAutocapitalizationType { get set }
```
```javascript
// Parent: FormTextItem
@_spi(AdyenInternal) public var autocorrectionType: UIKit.UITextAutocorrectionType { get set }
```
```javascript
// Parent: FormTextItem
@_spi(AdyenInternal) public var keyboardType: UIKit.UIKeyboardType { get set }
```
```javascript
// Parent: FormTextItem
@_spi(AdyenInternal) public var contentType: UIKit.UITextContentType? { get set }
```
```javascript
// Parent: FormTextItem
@_spi(AdyenInternal) public var allowsValidationWhileEditing: Swift.Bool { get set }
```
```javascript
// Parent: FormTextItem
@_spi(AdyenInternal) public var onDidBeginEditing: (() -> Swift.Void)? { get set }
```
```javascript
// Parent: FormTextItem
@_spi(AdyenInternal) public var onDidEndEditing: (() -> Swift.Void)? { get set }
```
```javascript
// Parent: FormTextItem
@_spi(AdyenInternal) public init(style: Adyen.FormTextItemStyle) -> Adyen.FormTextItem
```
```javascript
// Parent: FormTextItem
@_spi(AdyenInternal) override public func isValid() -> Swift.Bool
```
```javascript
// Parent: FormTextItem
@_spi(AdyenInternal) override public func validationStatus() -> Adyen.ValidationStatus?
```
```javascript
// Parent: Root
public struct FormTextItemStyle : FormValueItemStyle, TintableStyle, ViewStyle
```
```javascript
// Parent: FormTextItemStyle
public var title: Adyen.TextStyle { get set }
```
```javascript
// Parent: FormTextItemStyle
public var text: Adyen.TextStyle { get set }
```
```javascript
// Parent: FormTextItemStyle
public var placeholderText: Adyen.TextStyle? { get set }
```
```javascript
// Parent: FormTextItemStyle
public var icon: Adyen.ImageStyle { get set }
```
```javascript
// Parent: FormTextItemStyle
public var tintColor: UIKit.UIColor? { get set }
```
```javascript
// Parent: FormTextItemStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: FormTextItemStyle
public var errorColor: UIKit.UIColor { get set }
```
```javascript
// Parent: FormTextItemStyle
public var separatorColor: UIKit.UIColor? { get set }
```
```javascript
// Parent: FormTextItemStyle
public init(title: Adyen.TextStyle, text: Adyen.TextStyle, placeholderText: Adyen.TextStyle? = $DEFAULT_ARG, icon: Adyen.ImageStyle) -> Adyen.FormTextItemStyle
```
```javascript
// Parent: FormTextItemStyle
public init(tintColor: UIKit.UIColor) -> Adyen.FormTextItemStyle
```
```javascript
// Parent: FormTextItemStyle
public init() -> Adyen.FormTextItemStyle
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol FormTextItemViewDelegate<Self : AnyObject>
```
```javascript
// Parent: FormTextItemViewDelegate
@_spi(AdyenInternal) public func didReachMaximumLength<Self, T where Self : Adyen.FormTextItemViewDelegate, T : Adyen.FormTextItem>(in: Adyen.FormTextItemView<T>) -> Swift.Void
```
```javascript
// Parent: FormTextItemViewDelegate
@_spi(AdyenInternal) public func didSelectReturnKey<Self, T where Self : Adyen.FormTextItemViewDelegate, T : Adyen.FormTextItem>(in: Adyen.FormTextItemView<T>) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol AnyFormTextItemView<Self : Adyen.AnyFormItemView> : AnyFormItemView
```
```javascript
// Parent: AnyFormTextItemView
@_spi(AdyenInternal) public var delegate: (any Adyen.FormTextItemViewDelegate)? { get set }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) open class FormTextItemView<ItemType where ItemType : Adyen.FormTextItem> : AdyenCompatible, AdyenObserver, AnyFormItemView, AnyFormTextItemView, AnyFormValidatableValueItemView, AnyFormValueItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITextFieldDelegate, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) override public var accessibilityLabelView: UIKit.UIView? { get }
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) public required init<ItemType where ItemType : Adyen.FormTextItem>(item: ItemType) -> Adyen.FormTextItemView<ItemType>
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) override public func reset<ItemType where ItemType : Adyen.FormTextItem>() -> Swift.Void
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) public weak var delegate: (any Adyen.FormTextItemViewDelegate)? { get set }
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) public lazy var textField: Adyen.TextField { get set }
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) public var accessory: Adyen.FormTextItemView<ItemType>.AccessoryType { get set }
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) override public var isValid: Swift.Bool { get }
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) override public func showValidation<ItemType where ItemType : Adyen.FormTextItem>() -> Swift.Void
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) override open func configureSeparatorView<ItemType where ItemType : Adyen.FormTextItem>() -> Swift.Void
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) @objc override open dynamic var lastBaselineAnchor: UIKit.NSLayoutYAxisAnchor { get }
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) @objc override open dynamic var canBecomeFirstResponder: Swift.Bool { get }
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) @discardableResult @objc override open dynamic func becomeFirstResponder<ItemType where ItemType : Adyen.FormTextItem>() -> Swift.Bool
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) @discardableResult @objc override open dynamic func resignFirstResponder<ItemType where ItemType : Adyen.FormTextItem>() -> Swift.Bool
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) @objc override open dynamic var isFirstResponder: Swift.Bool { get }
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) @objc public func textFieldShouldReturn<ItemType where ItemType : Adyen.FormTextItem>(_: UIKit.UITextField) -> Swift.Bool
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) @objc open func textFieldDidEndEditing<ItemType where ItemType : Adyen.FormTextItem>(_: UIKit.UITextField) -> Swift.Void
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) @objc open func textFieldDidBeginEditing<ItemType where ItemType : Adyen.FormTextItem>(_: UIKit.UITextField) -> Swift.Void
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) override open func updateValidationStatus<ItemType where ItemType : Adyen.FormTextItem>(forced: Swift.Bool = $DEFAULT_ARG) -> Swift.Void
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) public func notifyDelegateOfMaxLengthIfNeeded<ItemType where ItemType : Adyen.FormTextItem>() -> Swift.Void
```
```javascript
// Parent: FormTextItemView
@_spi(AdyenInternal) public enum AccessoryType<ItemType where ItemType : Adyen.FormTextItem> : Equatable
```
```javascript
// Parent: FormTextItemView.AccessoryType
@_spi(AdyenInternal) public case invalid
```
```javascript
// Parent: FormTextItemView.AccessoryType
@_spi(AdyenInternal) public case valid
```
```javascript
// Parent: FormTextItemView.AccessoryType
@_spi(AdyenInternal) public case customView(UIKit.UIView)
```
```javascript
// Parent: FormTextItemView.AccessoryType
@_spi(AdyenInternal) public case none
```
```javascript
// Parent: FormTextItemView.AccessoryType
@_spi(AdyenInternal) public static func __derived_enum_equals<ItemType where ItemType : Adyen.FormTextItem>(_: Adyen.FormTextItemView<ItemType>.AccessoryType, _: Adyen.FormTextItemView<ItemType>.AccessoryType) -> Swift.Bool
```
```javascript
// Parent: Root
@_spi(AdyenInternal) @objc public final class TextField : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UIContentSizeCategoryAdjusting, UIContextMenuInteractionDelegate, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UIKeyInput, UILargeContentViewerItem, UILetterformAwareAdjusting, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITextDraggable, UITextDroppable, UITextInput, UITextInputTraits, UITextPasteConfigurationSupporting, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: TextField
@_spi(AdyenInternal) public var allowsEditingActions: Swift.Bool { get set }
```
```javascript
// Parent: TextField
@_spi(AdyenInternal) @objc override public var accessibilityValue: Swift.String? { get set }
```
```javascript
// Parent: TextField
@_spi(AdyenInternal) @objc override public var font: UIKit.UIFont? { get set }
```
```javascript
// Parent: TextField
@_spi(AdyenInternal) @objc override public func canPerformAction(_: ObjectiveC.Selector, withSender: Any?) -> Swift.Bool
```
```javascript
// Parent: TextField
@_spi(AdyenInternal) @objc override public dynamic init(frame: CoreFoundation.CGRect) -> Adyen.TextField
```
```javascript
// Parent: TextField
@_spi(AdyenInternal) @objc public required dynamic init(coder: Foundation.NSCoder) -> Adyen.TextField?
```
```javascript
// Parent: TextField
@_spi(AdyenInternal) public func apply(placeholderText: Swift.String?, with: Adyen.TextStyle?) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormToggleItem : FormItem, Hidable
```
```javascript
// Parent: FormToggleItem
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get set }
```
```javascript
// Parent: FormToggleItem
@_spi(AdyenInternal) public init(style: Adyen.FormToggleItemStyle = $DEFAULT_ARG) -> Adyen.FormToggleItem
```
```javascript
// Parent: FormToggleItem
@_spi(AdyenInternal) override public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: Root
public struct FormToggleItemStyle : FormValueItemStyle, TintableStyle, ViewStyle
```
```javascript
// Parent: FormToggleItemStyle
public var title: Adyen.TextStyle { get set }
```
```javascript
// Parent: FormToggleItemStyle
public var tintColor: UIKit.UIColor? { get set }
```
```javascript
// Parent: FormToggleItemStyle
public var separatorColor: UIKit.UIColor? { get set }
```
```javascript
// Parent: FormToggleItemStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: FormToggleItemStyle
public init(title: Adyen.TextStyle) -> Adyen.FormToggleItemStyle
```
```javascript
// Parent: FormToggleItemStyle
public init() -> Adyen.FormToggleItemStyle
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormToggleItemView : AdyenCompatible, AdyenObserver, AnyFormItemView, AnyFormValueItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: FormToggleItemView
@_spi(AdyenInternal) public required init(item: Adyen.FormToggleItem) -> Adyen.FormToggleItemView
```
```javascript
// Parent: FormToggleItemView
@_spi(AdyenInternal) @discardableResult @objc override public func accessibilityActivate() -> Swift.Bool
```
```javascript
// Parent: FormToggleItemView
@_spi(AdyenInternal) override public func reset() -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol PickerElement<Self : Swift.CustomStringConvertible, Self : Swift.Equatable> : CustomStringConvertible, Equatable
```
```javascript
// Parent: PickerElement
@_spi(AdyenInternal) public var identifier: Swift.String { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct BasePickerElement<ElementType where ElementType : Swift.CustomStringConvertible> : CustomStringConvertible, Equatable, PickerElement
```
```javascript
// Parent: BasePickerElement
@_spi(AdyenInternal) public let identifier: Swift.String { get }
```
```javascript
// Parent: BasePickerElement
@_spi(AdyenInternal) public let element: ElementType { get }
```
```javascript
// Parent: BasePickerElement
@_spi(AdyenInternal) public static func ==<ElementType where ElementType : Swift.CustomStringConvertible>(_: Adyen.BasePickerElement<ElementType>, _: Adyen.BasePickerElement<ElementType>) -> Swift.Bool
```
```javascript
// Parent: BasePickerElement
@_spi(AdyenInternal) public var description: Swift.String { get }
```
```javascript
// Parent: BasePickerElement
@_spi(AdyenInternal) public init<ElementType where ElementType : Swift.CustomStringConvertible>(identifier: Swift.String, element: ElementType) -> Adyen.BasePickerElement<ElementType>
```
```javascript
// Parent: Root
@_spi(AdyenInternal) open class BaseFormPickerItem<ElementType where ElementType : Swift.CustomStringConvertible> : FormItem, Hidable, InputViewRequiringFormItem
```
```javascript
// Parent: BaseFormPickerItem
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get set }
```
```javascript
// Parent: BaseFormPickerItem
@_spi(AdyenInternal) public var selectableValues: [Adyen.BasePickerElement<ElementType>] { get set }
```
```javascript
// Parent: BaseFormPickerItem
@_spi(AdyenInternal) public var $selectableValues: Adyen.AdyenObservable<[Adyen.BasePickerElement<ElementType>]> { get }
```
```javascript
// Parent: BaseFormPickerItem
@_spi(AdyenInternal) public init<ElementType where ElementType : Swift.CustomStringConvertible>(preselectedValue: Adyen.BasePickerElement<ElementType>, selectableValues: [Adyen.BasePickerElement<ElementType>], style: Adyen.FormTextItemStyle) -> Adyen.BaseFormPickerItem<ElementType>
```
```javascript
// Parent: Root
@_spi(AdyenInternal) open class BaseFormPickerItemView<T where T : Swift.CustomStringConvertible, T : Swift.Equatable> : AdyenCompatible, AdyenObserver, AnyFormItemView, AnyFormValueItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: BaseFormPickerItemView
@_spi(AdyenInternal) public required init<T where T : Swift.CustomStringConvertible, T : Swift.Equatable>(item: Adyen.BaseFormPickerItem<T>) -> Adyen.BaseFormPickerItemView<T>
```
```javascript
// Parent: BaseFormPickerItemView
@_spi(AdyenInternal) @objc override open dynamic var canBecomeFirstResponder: Swift.Bool { get }
```
```javascript
// Parent: BaseFormPickerItemView
@_spi(AdyenInternal) @discardableResult @objc override open dynamic func becomeFirstResponder<T where T : Swift.CustomStringConvertible, T : Swift.Equatable>() -> Swift.Bool
```
```javascript
// Parent: BaseFormPickerItemView
@_spi(AdyenInternal) @discardableResult @objc override open dynamic func resignFirstResponder<T where T : Swift.CustomStringConvertible, T : Swift.Equatable>() -> Swift.Bool
```
```javascript
// Parent: BaseFormPickerItemView
@_spi(AdyenInternal) open func initialize<T where T : Swift.CustomStringConvertible, T : Swift.Equatable>() -> Swift.Void
```
```javascript
// Parent: BaseFormPickerItemView
@_spi(AdyenInternal) public lazy var inputControl: any Adyen.PickerTextInputControl { get set }
```
```javascript
// Parent: BaseFormPickerItemView
@_spi(AdyenInternal) @objc public func numberOfComponents<T where T : Swift.CustomStringConvertible, T : Swift.Equatable>(in: UIKit.UIPickerView) -> Swift.Int
```
```javascript
// Parent: BaseFormPickerItemView
@_spi(AdyenInternal) @objc public func pickerView<T where T : Swift.CustomStringConvertible, T : Swift.Equatable>(_: UIKit.UIPickerView, numberOfRowsInComponent: Swift.Int) -> Swift.Int
```
```javascript
// Parent: BaseFormPickerItemView
@_spi(AdyenInternal) @objc public func pickerView<T where T : Swift.CustomStringConvertible, T : Swift.Equatable>(_: UIKit.UIPickerView, titleForRow: Swift.Int, forComponent: Swift.Int) -> Swift.String?
```
```javascript
// Parent: BaseFormPickerItemView
@_spi(AdyenInternal) @objc public func pickerView<T where T : Swift.CustomStringConvertible, T : Swift.Equatable>(_: UIKit.UIPickerView, didSelectRow: Swift.Int, inComponent: Swift.Int) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol PickerTextInputControl<Self : UIKit.UIView>
```
```javascript
// Parent: PickerTextInputControl
@_spi(AdyenInternal) public var onDidResignFirstResponder: (() -> Swift.Void)? { get set }
```
```javascript
// Parent: PickerTextInputControl
@_spi(AdyenInternal) public var onDidBecomeFirstResponder: (() -> Swift.Void)? { get set }
```
```javascript
// Parent: PickerTextInputControl
@_spi(AdyenInternal) public var onDidTap: (() -> Swift.Void)? { get set }
```
```javascript
// Parent: PickerTextInputControl
@_spi(AdyenInternal) public var showChevron: Swift.Bool { get set }
```
```javascript
// Parent: PickerTextInputControl
@_spi(AdyenInternal) public var label: Swift.String? { get set }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public typealias IssuerPickerItem = Adyen.BasePickerElement<Adyen.Issuer>
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormIssuersPickerItem : FormItem, Hidable, InputViewRequiringFormItem
```
```javascript
// Parent: FormIssuersPickerItem
@_spi(AdyenInternal) override public init(preselectedValue: Adyen.IssuerPickerItem, selectableValues: [Adyen.IssuerPickerItem], style: Adyen.FormTextItemStyle) -> Adyen.FormIssuersPickerItem
```
```javascript
// Parent: FormIssuersPickerItem
@_spi(AdyenInternal) override public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: Root
public protocol FormValueItemStyle<Self : Adyen.TintableStyle> : TintableStyle, ViewStyle
```
```javascript
// Parent: FormValueItemStyle
public var separatorColor: UIKit.UIColor? { get }
```
```javascript
// Parent: FormValueItemStyle
public var title: Adyen.TextStyle { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) open class FormValueItem<ValueType, StyleType where ValueType : Swift.Equatable, StyleType : Adyen.FormValueItemStyle> : FormItem
```
```javascript
// Parent: FormValueItem
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get }
```
```javascript
// Parent: FormValueItem
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
// Parent: FormValueItem
@_spi(AdyenInternal) public var value: ValueType { get set }
```
```javascript
// Parent: FormValueItem
@_spi(AdyenInternal) public var publisher: Adyen.AdyenObservable<ValueType> { get set }
```
```javascript
// Parent: FormValueItem
@_spi(AdyenInternal) public var style: StyleType { get set }
```
```javascript
// Parent: FormValueItem
@_spi(AdyenInternal) public var title: Swift.String? { get set }
```
```javascript
// Parent: FormValueItem
@_spi(AdyenInternal) public var $title: Adyen.AdyenObservable<Swift.String?> { get }
```
```javascript
// Parent: FormValueItem
@_spi(AdyenInternal) open func build<ValueType, StyleType where ValueType : Swift.Equatable, StyleType : Adyen.FormValueItemStyle>(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: Root
@_spi(AdyenInternal) open class FormValueItemView<ValueType, Style, ItemType where ValueType : Swift.Equatable, Style : Adyen.FormValueItemStyle, ItemType : Adyen.FormValueItem<ValueType, Style>> : AdyenCompatible, AdyenObserver, AnyFormItemView, AnyFormValueItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: FormValueItemView
@_spi(AdyenInternal) public lazy var titleLabel: UIKit.UILabel { get set }
```
```javascript
// Parent: FormValueItemView
@_spi(AdyenInternal) public required init<ValueType, Style, ItemType where ValueType : Swift.Equatable, Style : Adyen.FormValueItemStyle, ItemType : Adyen.FormValueItem<ValueType, Style>>(item: ItemType) -> Adyen.FormValueItemView<ValueType, Style, ItemType>
```
```javascript
// Parent: FormValueItemView
@_spi(AdyenInternal) @objc override open dynamic func didAddSubview<ValueType, Style, ItemType where ValueType : Swift.Equatable, Style : Adyen.FormValueItemStyle, ItemType : Adyen.FormValueItem<ValueType, Style>>(_: UIKit.UIView) -> Swift.Void
```
```javascript
// Parent: FormValueItemView
@_spi(AdyenInternal) open var isEditing: Swift.Bool { get set }
```
```javascript
// Parent: FormValueItemView
@_spi(AdyenInternal) public var showsSeparator: Swift.Bool { get set }
```
```javascript
// Parent: FormValueItemView
@_spi(AdyenInternal) open func configureSeparatorView<ValueType, Style, ItemType where ValueType : Swift.Equatable, Style : Adyen.FormValueItemStyle, ItemType : Adyen.FormValueItem<ValueType, Style>>() -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol AnyFormValueItemView<Self : Adyen.AnyFormItemView> : AnyFormItemView
```
```javascript
// Parent: AnyFormValueItemView
@_spi(AdyenInternal) public var isEditing: Swift.Bool { get set }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol FormPickable<Self : Swift.Equatable> : Equatable
```
```javascript
// Parent: FormPickable
@_spi(AdyenInternal) public var identifier: Swift.String { get }
```
```javascript
// Parent: FormPickable
@_spi(AdyenInternal) public var icon: UIKit.UIImage? { get }
```
```javascript
// Parent: FormPickable
@_spi(AdyenInternal) public var title: Swift.String { get }
```
```javascript
// Parent: FormPickable
@_spi(AdyenInternal) public var subtitle: Swift.String? { get }
```
```javascript
// Parent: FormPickable
@_spi(AdyenInternal) public var trailingText: Swift.String? { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct FormPickerElement : Equatable, FormPickable
```
```javascript
// Parent: FormPickerElement
@_spi(AdyenInternal) public let identifier: Swift.String { get }
```
```javascript
// Parent: FormPickerElement
@_spi(AdyenInternal) public let icon: UIKit.UIImage? { get }
```
```javascript
// Parent: FormPickerElement
@_spi(AdyenInternal) public let title: Swift.String { get }
```
```javascript
// Parent: FormPickerElement
@_spi(AdyenInternal) public let subtitle: Swift.String? { get }
```
```javascript
// Parent: FormPickerElement
@_spi(AdyenInternal) public let trailingText: Swift.String? { get }
```
```javascript
// Parent: FormPickerElement
@_spi(AdyenInternal) public init(identifier: Swift.String, icon: UIKit.UIImage? = $DEFAULT_ARG, title: Swift.String, subtitle: Swift.String? = $DEFAULT_ARG, trailingText: Swift.String? = $DEFAULT_ARG) -> Adyen.FormPickerElement
```
```javascript
// Parent: FormPickerElement
@_spi(AdyenInternal) public static func __derived_struct_equals(_: Adyen.FormPickerElement, _: Adyen.FormPickerElement) -> Swift.Bool
```
```javascript
// Parent: Root
@_spi(AdyenInternal) open class FormPickerItem<Value where Value : Adyen.FormPickable> : FormItem, ValidatableFormItem
```
```javascript
// Parent: FormPickerItem
@_spi(AdyenInternal) public let localizationParameters: Adyen.LocalizationParameters? { get }
```
```javascript
// Parent: FormPickerItem
@_spi(AdyenInternal) public var isOptional: Swift.Bool { get }
```
```javascript
// Parent: FormPickerItem
@_spi(AdyenInternal) override public var value: Value? { get set }
```
```javascript
// Parent: FormPickerItem
@_spi(AdyenInternal) public var selectableValues: [Value] { get set }
```
```javascript
// Parent: FormPickerItem
@_spi(AdyenInternal) public var $selectableValues: Adyen.AdyenObservable<[Value]> { get }
```
```javascript
// Parent: FormPickerItem
@_spi(AdyenInternal) public init<Value where Value : Adyen.FormPickable>(preselectedValue: Value?, selectableValues: [Value], title: Swift.String, placeholder: Swift.String, style: Adyen.FormTextItemStyle, presenter: (any Adyen.ViewControllerPresenter)?, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormPickerItem<Value>
```
```javascript
// Parent: FormPickerItem
@_spi(AdyenInternal) public func updateOptionalStatus<Value where Value : Adyen.FormPickable>(isOptional: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: FormPickerItem
@_spi(AdyenInternal) public func resetValue<Value where Value : Adyen.FormPickable>() -> Swift.Void
```
```javascript
// Parent: FormPickerItem
@_spi(AdyenInternal) override public func build<Value where Value : Adyen.FormPickable>(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: FormPickerItem
@_spi(AdyenInternal) override public func isValid<Value where Value : Adyen.FormPickable>() -> Swift.Bool
```
```javascript
// Parent: FormPickerItem
@_spi(AdyenInternal) override public func validationStatus<Value where Value : Adyen.FormPickable>() -> Adyen.ValidationStatus?
```
```javascript
// Parent: FormPickerItem
@_spi(AdyenInternal) public func updateValidationFailureMessage<Value where Value : Adyen.FormPickable>() -> Swift.Void
```
```javascript
// Parent: FormPickerItem
@_spi(AdyenInternal) public func updateFormattedValue<Value where Value : Adyen.FormPickable>() -> Swift.Void
```
```javascript
// Parent: FormPickerItem
@_spi(AdyenInternal) override public init<Value where Value : Adyen.FormPickable>(value: Value?, style: Adyen.FormTextItemStyle, placeholder: Swift.String) -> Adyen.FormPickerItem<Value>
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public class FormPickerItemView<Value where Value : Adyen.FormPickable> : AdyenCompatible, AdyenObserver, AnyFormItemView, AnyFormValidatableValueItemView, AnyFormValueItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: FormPickerItemView
@_spi(AdyenInternal) override public func showValidation<Value where Value : Adyen.FormPickable>() -> Swift.Void
```
```javascript
// Parent: FormPickerItemView
@_spi(AdyenInternal) override public func reset<Value where Value : Adyen.FormPickable>() -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class FormPickerSearchViewController<Option where Option : Adyen.FormPickable> : AdyenCompatible, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSExtensionRequestHandling, NSObjectProtocol, Sendable, UIActivityItemsConfigurationProviding, UIAppearanceContainer, UIContentContainer, UIFocusEnvironment, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UIStateRestoring, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring, ViewControllerPresenter
```
```javascript
// Parent: FormPickerSearchViewController
@_spi(AdyenInternal) public init<Option where Option : Adyen.FormPickable>(localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, style: Adyen.FormPickerSearchViewController<Option>.Style = $DEFAULT_ARG, title: Swift.String?, options: [Option], selectionHandler: (Option) -> Swift.Void) -> Adyen.FormPickerSearchViewController<Option>
```
```javascript
// Parent: FormPickerSearchViewController
@_spi(AdyenInternal) @objc override public dynamic init<Option where Option : Adyen.FormPickable>(navigationBarClass: Swift.AnyClass?, toolbarClass: Swift.AnyClass?) -> Adyen.FormPickerSearchViewController<Option>
```
```javascript
// Parent: FormPickerSearchViewController
@_spi(AdyenInternal) @objc override public dynamic init<Option where Option : Adyen.FormPickable>(rootViewController: UIKit.UIViewController) -> Adyen.FormPickerSearchViewController<Option>
```
```javascript
// Parent: FormPickerSearchViewController
@_spi(AdyenInternal) @objc override public dynamic init<Option where Option : Adyen.FormPickable>(nibName: Swift.String?, bundle: Foundation.Bundle?) -> Adyen.FormPickerSearchViewController<Option>
```
```javascript
// Parent: FormPickerSearchViewController
@_spi(AdyenInternal) public class EmptyView<Option where Option : Adyen.FormPickable> : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, SearchResultsEmptyView, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: FormPickerSearchViewController.EmptyView
@_spi(AdyenInternal) override public var searchTerm: Swift.String { get set }
```
```javascript
// Parent: FormPickerSearchViewController.EmptyView
@_spi(AdyenInternal) public struct Style<Option where Option : Adyen.FormPickable> : ViewStyle
```
```javascript
// Parent: FormPickerSearchViewController.EmptyView.Style
@_spi(AdyenInternal) public var title: Adyen.TextStyle { get set }
```
```javascript
// Parent: FormPickerSearchViewController.EmptyView.Style
@_spi(AdyenInternal) public var subtitle: Adyen.TextStyle { get set }
```
```javascript
// Parent: FormPickerSearchViewController.EmptyView.Style
@_spi(AdyenInternal) public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: FormPickerSearchViewController.EmptyView.Style
@_spi(AdyenInternal) public init<Option where Option : Adyen.FormPickable>() -> Adyen.FormPickerSearchViewController<Option>.EmptyView.Style
```
```javascript
// Parent: FormPickerSearchViewController
@_spi(AdyenInternal) public struct Style<Option where Option : Adyen.FormPickable> : ViewStyle
```
```javascript
// Parent: FormPickerSearchViewController.Style
@_spi(AdyenInternal) public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: FormPickerSearchViewController.Style
@_spi(AdyenInternal) public var emptyView: Adyen.FormPickerSearchViewController<Option>.EmptyView.Style { get set }
```
```javascript
// Parent: FormPickerSearchViewController.Style
@_spi(AdyenInternal) public init<Option where Option : Adyen.FormPickable>() -> Adyen.FormPickerSearchViewController<Option>.Style
```
```javascript
// Parent: Root
@_spi(AdyenInternal) open class FormSelectableValueItem<ValueType where ValueType : Swift.Equatable> : FormItem, ValidatableFormItem
```
```javascript
// Parent: FormSelectableValueItem
@_spi(AdyenInternal) public let placeholder: Swift.String { get }
```
```javascript
// Parent: FormSelectableValueItem
@_spi(AdyenInternal) public var selectionHandler: () -> Swift.Void { get set }
```
```javascript
// Parent: FormSelectableValueItem
@_spi(AdyenInternal) public var formattedValue: Swift.String? { get set }
```
```javascript
// Parent: FormSelectableValueItem
@_spi(AdyenInternal) public var $formattedValue: Adyen.AdyenObservable<Swift.String?> { get }
```
```javascript
// Parent: FormSelectableValueItem
@_spi(AdyenInternal) public init<ValueType where ValueType : Swift.Equatable>(value: ValueType, style: Adyen.FormTextItemStyle, placeholder: Swift.String) -> Adyen.FormSelectableValueItem<ValueType>
```
```javascript
// Parent: Root
@_spi(AdyenInternal) open class FormSelectableValueItemView<ValueType, ItemType where ValueType : Swift.Equatable, ItemType : Adyen.FormSelectableValueItem<ValueType?>> : AdyenCompatible, AdyenObserver, AnyFormItemView, AnyFormValidatableValueItemView, AnyFormValueItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: FormSelectableValueItemView
@_spi(AdyenInternal) public required init<ValueType, ItemType where ValueType : Swift.Equatable, ItemType : Adyen.FormSelectableValueItem<ValueType?>>(item: ItemType) -> Adyen.FormSelectableValueItemView<ValueType, ItemType>
```
```javascript
// Parent: Root
@_spi(AdyenInternal) open class FormValidatableValueItem<ValueType where ValueType : Swift.Equatable> : FormItem, ValidatableFormItem
```
```javascript
// Parent: FormValidatableValueItem
@_spi(AdyenInternal) public var validationFailureMessage: Swift.String? { get set }
```
```javascript
// Parent: FormValidatableValueItem
@_spi(AdyenInternal) public var $validationFailureMessage: Adyen.AdyenObservable<Swift.String?> { get }
```
```javascript
// Parent: FormValidatableValueItem
@_spi(AdyenInternal) public var onDidShowValidationError: ((any Adyen.ValidationError) -> Swift.Void)? { get set }
```
```javascript
// Parent: FormValidatableValueItem
@_spi(AdyenInternal) public func isValid<ValueType where ValueType : Swift.Equatable>() -> Swift.Bool
```
```javascript
// Parent: FormValidatableValueItem
@_spi(AdyenInternal) public func validationStatus<ValueType where ValueType : Swift.Equatable>() -> Adyen.ValidationStatus?
```
```javascript
// Parent: Root
@_spi(AdyenInternal) open class FormValidatableValueItemView<ValueType, ItemType where ValueType : Swift.Equatable, ItemType : Adyen.FormValidatableValueItem<ValueType>> : AdyenCompatible, AdyenObserver, AnyFormItemView, AnyFormValidatableValueItemView, AnyFormValueItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: FormValidatableValueItemView
@_spi(AdyenInternal) public required init<ValueType, ItemType where ValueType : Swift.Equatable, ItemType : Adyen.FormValidatableValueItem<ValueType>>(item: ItemType) -> Adyen.FormValidatableValueItemView<ValueType, ItemType>
```
```javascript
// Parent: FormValidatableValueItemView
@_spi(AdyenInternal) override open func configureSeparatorView<ValueType, ItemType where ValueType : Swift.Equatable, ItemType : Adyen.FormValidatableValueItem<ValueType>>() -> Swift.Void
```
```javascript
// Parent: FormValidatableValueItemView
@_spi(AdyenInternal) public var isValid: Swift.Bool { get }
```
```javascript
// Parent: FormValidatableValueItemView
@_spi(AdyenInternal) public func showValidation<ValueType, ItemType where ValueType : Swift.Equatable, ItemType : Adyen.FormValidatableValueItem<ValueType>>() -> Swift.Void
```
```javascript
// Parent: FormValidatableValueItemView
@_spi(AdyenInternal) open func updateValidationStatus<ValueType, ItemType where ValueType : Swift.Equatable, ItemType : Adyen.FormValidatableValueItem<ValueType>>(forced: Swift.Bool = $DEFAULT_ARG) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol AnyFormValidatableValueItemView<Self : Adyen.AnyFormValueItemView> : AnyFormItemView, AnyFormValueItemView
```
```javascript
// Parent: AnyFormValidatableValueItemView
@_spi(AdyenInternal) public func showValidation<Self where Self : Adyen.AnyFormValidatableValueItemView>() -> Swift.Void
```
```javascript
// Parent: AnyFormValidatableValueItemView
@_spi(AdyenInternal) public var isValid: Swift.Bool { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) @objc public final class ListCell : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UIGestureRecognizerDelegate, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: ListCell
@_spi(AdyenInternal) @objc override public dynamic init(style: UIKit.UITableViewCell.CellStyle, reuseIdentifier: Swift.String?) -> Adyen.ListCell
```
```javascript
// Parent: ListCell
@_spi(AdyenInternal) public var item: Adyen.ListItem? { get set }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public class ListItem : Equatable, FormItem, Hashable
```
```javascript
// Parent: ListItem
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
// Parent: ListItem
@_spi(AdyenInternal) public let style: Adyen.ListItemStyle { get }
```
```javascript
// Parent: ListItem
@_spi(AdyenInternal) public var title: Swift.String { get set }
```
```javascript
// Parent: ListItem
@_spi(AdyenInternal) public var subtitle: Swift.String? { get set }
```
```javascript
// Parent: ListItem
@_spi(AdyenInternal) public var icon: Adyen.ListItem.Icon? { get set }
```
```javascript
// Parent: ListItem
@_spi(AdyenInternal) public var trailingText: Swift.String? { get set }
```
```javascript
// Parent: ListItem
@_spi(AdyenInternal) public var selectionHandler: (() -> Swift.Void)? { get set }
```
```javascript
// Parent: ListItem
@_spi(AdyenInternal) public var deletionHandler: ((Foundation.IndexPath, @escaping Adyen.Completion<Swift.Bool>) -> Swift.Void)? { get set }
```
```javascript
// Parent: ListItem
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
// Parent: ListItem
@_spi(AdyenInternal) public let accessibilityLabel: Swift.String { get }
```
```javascript
// Parent: ListItem
@_spi(AdyenInternal) public init(title: Swift.String, subtitle: Swift.String? = $DEFAULT_ARG, icon: Adyen.ListItem.Icon? = $DEFAULT_ARG, trailingText: Swift.String? = $DEFAULT_ARG, style: Adyen.ListItemStyle = $DEFAULT_ARG, identifier: Swift.String? = $DEFAULT_ARG, accessibilityLabel: Swift.String? = $DEFAULT_ARG, selectionHandler: (() -> Swift.Void)? = $DEFAULT_ARG) -> Adyen.ListItem
```
```javascript
// Parent: ListItem
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
// Parent: ListItem
@_spi(AdyenInternal) public func startLoading() -> Swift.Void
```
```javascript
// Parent: ListItem
@_spi(AdyenInternal) public func stopLoading() -> Swift.Void
```
```javascript
// Parent: ListItem
@_spi(AdyenInternal) public struct Icon : Equatable, Hashable
```
```javascript
// Parent: ListItem.Icon
@_spi(AdyenInternal) public enum Location : Equatable, Hashable
```
```javascript
// Parent: ListItem.Icon.Location
@_spi(AdyenInternal) public case local(image: UIKit.UIImage)
```
```javascript
// Parent: ListItem.Icon.Location
@_spi(AdyenInternal) public case remote(url: Foundation.URL?)
```
```javascript
// Parent: ListItem.Icon.Location
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: ListItem.Icon.Location
@_spi(AdyenInternal) public static func __derived_enum_equals(_: Adyen.ListItem.Icon.Location, _: Adyen.ListItem.Icon.Location) -> Swift.Bool
```
```javascript
// Parent: ListItem.Icon.Location
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
// Parent: ListItem.Icon
@_spi(AdyenInternal) public let location: Adyen.ListItem.Icon.Location { get }
```
```javascript
// Parent: ListItem.Icon
@_spi(AdyenInternal) public let canBeModified: Swift.Bool { get }
```
```javascript
// Parent: ListItem.Icon
@_spi(AdyenInternal) public init(location: Adyen.ListItem.Icon.Location, canBeModified: Swift.Bool = $DEFAULT_ARG) -> Adyen.ListItem.Icon
```
```javascript
// Parent: ListItem.Icon
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: ListItem.Icon
@_spi(AdyenInternal) public static func __derived_struct_equals(_: Adyen.ListItem.Icon, _: Adyen.ListItem.Icon) -> Swift.Bool
```
```javascript
// Parent: ListItem.Icon
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
// Parent: ListItem.Icon
@_spi(AdyenInternal) public init(url: Foundation.URL?, canBeModified: Swift.Bool = $DEFAULT_ARG) -> Adyen.ListItem.Icon
```
```javascript
// Parent: ListItem.Icon
@_spi(AdyenInternal) public init(image: UIKit.UIImage, canBeModified: Swift.Bool = $DEFAULT_ARG) -> Adyen.ListItem.Icon
```
```javascript
// Parent: ListItem
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: ListItem
@_spi(AdyenInternal) public static func ==(_: Adyen.ListItem, _: Adyen.ListItem) -> Swift.Bool
```
```javascript
// Parent: ListItem
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
// Parent: Root
public struct ListItemStyle : Equatable, ViewStyle
```
```javascript
// Parent: ListItemStyle
public var title: Adyen.TextStyle { get set }
```
```javascript
// Parent: ListItemStyle
public var subtitle: Adyen.TextStyle { get set }
```
```javascript
// Parent: ListItemStyle
public var trailingText: Adyen.TextStyle { get set }
```
```javascript
// Parent: ListItemStyle
public var image: Adyen.ImageStyle { get set }
```
```javascript
// Parent: ListItemStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: ListItemStyle
public init(title: Adyen.TextStyle, subtitle: Adyen.TextStyle, image: Adyen.ImageStyle) -> Adyen.ListItemStyle
```
```javascript
// Parent: ListItemStyle
public init() -> Adyen.ListItemStyle
```
```javascript
// Parent: ListItemStyle
public static func ==(_: Adyen.ListItemStyle, _: Adyen.ListItemStyle) -> Swift.Bool
```
```javascript
// Parent: Root
@_spi(AdyenInternal) @objc public final class ListItemView : AdyenCompatible, AnyFormItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: ListItemView
@_spi(AdyenInternal) public var childItemViews: [any Adyen.AnyFormItemView] { get set }
```
```javascript
// Parent: ListItemView
@_spi(AdyenInternal) public init(imageLoader: any Adyen.ImageLoading = $DEFAULT_ARG) -> Adyen.ListItemView
```
```javascript
// Parent: ListItemView
@_spi(AdyenInternal) public func reset() -> Swift.Void
```
```javascript
// Parent: ListItemView
@_spi(AdyenInternal) public var item: Adyen.ListItem? { get set }
```
```javascript
// Parent: ListItemView
@_spi(AdyenInternal) @objc override public func didMoveToWindow() -> Swift.Void
```
```javascript
// Parent: ListItemView
@_spi(AdyenInternal) @objc override public func layoutSubviews() -> Swift.Void
```
```javascript
// Parent: ListItemView
@_spi(AdyenInternal) @objc override public func traitCollectionDidChange(_: UIKit.UITraitCollection?) -> Swift.Void
```
```javascript
// Parent: ListItemView
@_spi(AdyenInternal) @objc override public dynamic init(frame: CoreFoundation.CGRect) -> Adyen.ListItemView
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum EditingStyle : Equatable, Hashable
```
```javascript
// Parent: EditingStyle
@_spi(AdyenInternal) public case delete
```
```javascript
// Parent: EditingStyle
@_spi(AdyenInternal) public case none
```
```javascript
// Parent: EditingStyle
@_spi(AdyenInternal) public static func __derived_enum_equals(_: Adyen.EditingStyle, _: Adyen.EditingStyle) -> Swift.Bool
```
```javascript
// Parent: EditingStyle
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: EditingStyle
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct ListSection : Equatable, Hashable
```
```javascript
// Parent: ListSection
@_spi(AdyenInternal) public let header: Adyen.ListSectionHeader? { get }
```
```javascript
// Parent: ListSection
@_spi(AdyenInternal) public var items: [Adyen.ListItem] { get }
```
```javascript
// Parent: ListSection
@_spi(AdyenInternal) public let footer: Adyen.ListSectionFooter? { get }
```
```javascript
// Parent: ListSection
@_spi(AdyenInternal) public var isEditable: Swift.Bool { get }
```
```javascript
// Parent: ListSection
@_spi(AdyenInternal) public init(header: Adyen.ListSectionHeader? = $DEFAULT_ARG, items: [Adyen.ListItem], footer: Adyen.ListSectionFooter? = $DEFAULT_ARG) -> Adyen.ListSection
```
```javascript
// Parent: ListSection
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: ListSection
@_spi(AdyenInternal) public static func ==(_: Adyen.ListSection, _: Adyen.ListSection) -> Swift.Bool
```
```javascript
// Parent: ListSection
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct ListSectionHeader : Equatable, Hashable
```
```javascript
// Parent: ListSectionHeader
@_spi(AdyenInternal) public var title: Swift.String { get set }
```
```javascript
// Parent: ListSectionHeader
@_spi(AdyenInternal) public var style: Adyen.ListSectionHeaderStyle { get set }
```
```javascript
// Parent: ListSectionHeader
@_spi(AdyenInternal) public var editingStyle: Adyen.EditingStyle { get set }
```
```javascript
// Parent: ListSectionHeader
@_spi(AdyenInternal) public init(title: Swift.String, editingStyle: Adyen.EditingStyle = $DEFAULT_ARG, style: Adyen.ListSectionHeaderStyle) -> Adyen.ListSectionHeader
```
```javascript
// Parent: ListSectionHeader
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: ListSectionHeader
@_spi(AdyenInternal) public static func ==(_: Adyen.ListSectionHeader, _: Adyen.ListSectionHeader) -> Swift.Bool
```
```javascript
// Parent: ListSectionHeader
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
// Parent: Root
public struct ListSectionFooter : Equatable, Hashable
```
```javascript
// Parent: ListSectionFooter
public var title: Swift.String { get set }
```
```javascript
// Parent: ListSectionFooter
public var style: Adyen.ListSectionFooterStyle { get set }
```
```javascript
// Parent: ListSectionFooter
public init(title: Swift.String, style: Adyen.ListSectionFooterStyle) -> Adyen.ListSectionFooter
```
```javascript
// Parent: ListSectionFooter
public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: ListSectionFooter
public static func ==(_: Adyen.ListSectionFooter, _: Adyen.ListSectionFooter) -> Swift.Bool
```
```javascript
// Parent: ListSectionFooter
public var hashValue: Swift.Int { get }
```
```javascript
// Parent: Root
public struct ListSectionFooterStyle : ViewStyle
```
```javascript
// Parent: ListSectionFooterStyle
public var title: Adyen.TextStyle { get set }
```
```javascript
// Parent: ListSectionFooterStyle
public var separatorColor: UIKit.UIColor { get set }
```
```javascript
// Parent: ListSectionFooterStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: ListSectionFooterStyle
public init(title: Adyen.TextStyle) -> Adyen.ListSectionFooterStyle
```
```javascript
// Parent: ListSectionFooterStyle
public init() -> Adyen.ListSectionFooterStyle
```
```javascript
// Parent: Root
public struct ListSectionHeaderStyle : ViewStyle
```
```javascript
// Parent: ListSectionHeaderStyle
public var title: Adyen.TextStyle { get set }
```
```javascript
// Parent: ListSectionHeaderStyle
public var trailingButton: Adyen.ButtonStyle { get set }
```
```javascript
// Parent: ListSectionHeaderStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: ListSectionHeaderStyle
public init(title: Adyen.TextStyle) -> Adyen.ListSectionHeaderStyle
```
```javascript
// Parent: ListSectionHeaderStyle
public init() -> Adyen.ListSectionHeaderStyle
```
```javascript
// Parent: Root
@_spi(AdyenInternal) @objc public final class ListViewController : AdyenCompatible, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSExtensionRequestHandling, NSObjectProtocol, Sendable, UIActivityItemsConfigurationProviding, UIAppearanceContainer, UIContentContainer, UIFocusEnvironment, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UIScrollViewDelegate, UIStateRestoring, UITableViewDataSource, UITableViewDelegate, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring, ViewControllerPresenter
```
```javascript
// Parent: ListViewController
@_spi(AdyenInternal) public let style: any Adyen.ViewStyle { get }
```
```javascript
// Parent: ListViewController
@_spi(AdyenInternal) public weak var delegate: (any Adyen.ViewControllerDelegate)? { get set }
```
```javascript
// Parent: ListViewController
@_spi(AdyenInternal) public init(style: any Adyen.ViewStyle) -> Adyen.ListViewController
```
```javascript
// Parent: ListViewController
@_spi(AdyenInternal) @objc override public var preferredContentSize: CoreFoundation.CGSize { get set }
```
```javascript
// Parent: ListViewController
@_spi(AdyenInternal) public var sections: [Adyen.ListSection] { get }
```
```javascript
// Parent: ListViewController
@_spi(AdyenInternal) public func reload(newSections: [Adyen.ListSection], animated: Swift.Bool = $DEFAULT_ARG) -> Swift.Void
```
```javascript
// Parent: ListViewController
@_spi(AdyenInternal) public func deleteItem(at: Foundation.IndexPath, animated: Swift.Bool = $DEFAULT_ARG) -> Swift.Void
```
```javascript
// Parent: ListViewController
@_spi(AdyenInternal) @objc override public func viewDidLoad() -> Swift.Void
```
```javascript
// Parent: ListViewController
@_spi(AdyenInternal) @objc override public func viewDidAppear(_: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: ListViewController
@_spi(AdyenInternal) @objc override public func viewWillAppear(_: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: ListViewController
@_spi(AdyenInternal) @objc override public func tableView(_: UIKit.UITableView, viewForHeaderInSection: Swift.Int) -> UIKit.UIView?
```
```javascript
// Parent: ListViewController
@_spi(AdyenInternal) @objc override public func tableView(_: UIKit.UITableView, viewForFooterInSection: Swift.Int) -> UIKit.UIView?
```
```javascript
// Parent: ListViewController
@_spi(AdyenInternal) @objc override public func tableView(_: UIKit.UITableView, heightForFooterInSection: Swift.Int) -> CoreGraphics.CGFloat
```
```javascript
// Parent: ListViewController
@_spi(AdyenInternal) @objc override public func tableView(_: UIKit.UITableView, heightForHeaderInSection: Swift.Int) -> CoreGraphics.CGFloat
```
```javascript
// Parent: ListViewController
@_spi(AdyenInternal) @objc override public func tableView(_: UIKit.UITableView, didSelectRowAt: Foundation.IndexPath) -> Swift.Void
```
```javascript
// Parent: ListViewController
@_spi(AdyenInternal) @objc override public func tableView(_: UIKit.UITableView, editingStyleForRowAt: Foundation.IndexPath) -> UIKit.UITableViewCell.EditingStyle
```
```javascript
// Parent: ListViewController
@_spi(AdyenInternal) public func stopLoading() -> Swift.Void
```
```javascript
// Parent: ListViewController
@_spi(AdyenInternal) @objc override public dynamic init(style: UIKit.UITableView.Style) -> Adyen.ListViewController
```
```javascript
// Parent: ListViewController
@_spi(AdyenInternal) @objc override public dynamic init(nibName: Swift.String?, bundle: Foundation.Bundle?) -> Adyen.ListViewController
```
```javascript
// Parent: Root
public struct ApplePayStyle
```
```javascript
// Parent: ApplePayStyle
public var paymentButtonStyle: PassKit.PKPaymentButtonStyle? { get set }
```
```javascript
// Parent: ApplePayStyle
public var paymentButtonType: PassKit.PKPaymentButtonType { get set }
```
```javascript
// Parent: ApplePayStyle
public var cornerRadius: CoreGraphics.CGFloat { get set }
```
```javascript
// Parent: ApplePayStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: ApplePayStyle
public var hintLabel: Adyen.TextStyle { get set }
```
```javascript
// Parent: ApplePayStyle
public init(paymentButtonStyle: PassKit.PKPaymentButtonStyle? = $DEFAULT_ARG, paymentButtonType: PassKit.PKPaymentButtonType = $DEFAULT_ARG, cornerRadius: CoreGraphics.CGFloat = $DEFAULT_ARG, backgroundColor: UIKit.UIColor = $DEFAULT_ARG, hintLabel: Adyen.TextStyle = $DEFAULT_ARG) -> Adyen.ApplePayStyle
```
```javascript
// Parent: Root
public struct ButtonStyle : Equatable, ViewStyle
```
```javascript
// Parent: ButtonStyle
public var title: Adyen.TextStyle { get set }
```
```javascript
// Parent: ButtonStyle
public var cornerRounding: Adyen.CornerRounding { get set }
```
```javascript
// Parent: ButtonStyle
public var borderColor: UIKit.UIColor? { get set }
```
```javascript
// Parent: ButtonStyle
public var borderWidth: CoreGraphics.CGFloat { get set }
```
```javascript
// Parent: ButtonStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: ButtonStyle
public init(title: Adyen.TextStyle) -> Adyen.ButtonStyle
```
```javascript
// Parent: ButtonStyle
public init(title: Adyen.TextStyle, cornerRadius: CoreGraphics.CGFloat) -> Adyen.ButtonStyle
```
```javascript
// Parent: ButtonStyle
public init(title: Adyen.TextStyle, cornerRounding: Adyen.CornerRounding) -> Adyen.ButtonStyle
```
```javascript
// Parent: ButtonStyle
public init(title: Adyen.TextStyle, cornerRadius: CoreGraphics.CGFloat, background: UIKit.UIColor) -> Adyen.ButtonStyle
```
```javascript
// Parent: ButtonStyle
public init(title: Adyen.TextStyle, cornerRounding: Adyen.CornerRounding, background: UIKit.UIColor) -> Adyen.ButtonStyle
```
```javascript
// Parent: ButtonStyle
public static func __derived_struct_equals(_: Adyen.ButtonStyle, _: Adyen.ButtonStyle) -> Swift.Bool
```
```javascript
// Parent: Root
public enum CornerRounding : Equatable
```
```javascript
// Parent: CornerRounding
public case none
```
```javascript
// Parent: CornerRounding
public case fixed(CoreGraphics.CGFloat)
```
```javascript
// Parent: CornerRounding
public case percent(CoreGraphics.CGFloat)
```
```javascript
// Parent: CornerRounding
@_spi(AdyenInternal) public static func ==(_: Adyen.CornerRounding, _: Adyen.CornerRounding) -> Swift.Bool
```
```javascript
// Parent: Root
public struct FormComponentStyle : TintableStyle, ViewStyle
```
```javascript
// Parent: FormComponentStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: FormComponentStyle
public var sectionHeader: Adyen.TextStyle { get set }
```
```javascript
// Parent: FormComponentStyle
public var textField: Adyen.FormTextItemStyle { get set }
```
```javascript
// Parent: FormComponentStyle
public var toggle: Adyen.FormToggleItemStyle { get set }
```
```javascript
// Parent: FormComponentStyle
public var hintLabel: Adyen.TextStyle { get set }
```
```javascript
// Parent: FormComponentStyle
public var footnoteLabel: Adyen.TextStyle { get set }
```
```javascript
// Parent: FormComponentStyle
public var linkTextLabel: Adyen.TextStyle { get set }
```
```javascript
// Parent: FormComponentStyle
public var mainButtonItem: Adyen.FormButtonItemStyle { get set }
```
```javascript
// Parent: FormComponentStyle
public var secondaryButtonItem: Adyen.FormButtonItemStyle { get set }
```
```javascript
// Parent: FormComponentStyle
public var segmentedControlStyle: Adyen.SegmentedControlStyle { get set }
```
```javascript
// Parent: FormComponentStyle
public var addressStyle: Adyen.AddressStyle { get set }
```
```javascript
// Parent: FormComponentStyle
public var errorStyle: Adyen.FormErrorItemStyle { get set }
```
```javascript
// Parent: FormComponentStyle
public var tintColor: UIKit.UIColor? { get set }
```
```javascript
// Parent: FormComponentStyle
public var separatorColor: UIKit.UIColor? { get set }
```
```javascript
// Parent: FormComponentStyle
public init(textField: Adyen.FormTextItemStyle, toggle: Adyen.FormToggleItemStyle, mainButton: Adyen.FormButtonItemStyle, secondaryButton: Adyen.FormButtonItemStyle, helper: Adyen.TextStyle, sectionHeader: Adyen.TextStyle) -> Adyen.FormComponentStyle
```
```javascript
// Parent: FormComponentStyle
public init(textField: Adyen.FormTextItemStyle, toggle: Adyen.FormToggleItemStyle, mainButton: Adyen.ButtonStyle, secondaryButton: Adyen.ButtonStyle) -> Adyen.FormComponentStyle
```
```javascript
// Parent: FormComponentStyle
public init(tintColor: UIKit.UIColor) -> Adyen.FormComponentStyle
```
```javascript
// Parent: FormComponentStyle
public init() -> Adyen.FormComponentStyle
```
```javascript
// Parent: Root
public struct ImageStyle : Equatable, TintableStyle, ViewStyle
```
```javascript
// Parent: ImageStyle
public var borderColor: UIKit.UIColor? { get set }
```
```javascript
// Parent: ImageStyle
public var borderWidth: CoreGraphics.CGFloat { get set }
```
```javascript
// Parent: ImageStyle
public var cornerRounding: Adyen.CornerRounding { get set }
```
```javascript
// Parent: ImageStyle
public var clipsToBounds: Swift.Bool { get set }
```
```javascript
// Parent: ImageStyle
public var contentMode: UIKit.UIView.ContentMode { get set }
```
```javascript
// Parent: ImageStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: ImageStyle
public var tintColor: UIKit.UIColor? { get set }
```
```javascript
// Parent: ImageStyle
public init(borderColor: UIKit.UIColor?, borderWidth: CoreGraphics.CGFloat, cornerRadius: CoreGraphics.CGFloat, clipsToBounds: Swift.Bool, contentMode: UIKit.UIView.ContentMode) -> Adyen.ImageStyle
```
```javascript
// Parent: ImageStyle
public init(borderColor: UIKit.UIColor?, borderWidth: CoreGraphics.CGFloat, cornerRounding: Adyen.CornerRounding, clipsToBounds: Swift.Bool, contentMode: UIKit.UIView.ContentMode) -> Adyen.ImageStyle
```
```javascript
// Parent: ImageStyle
public static func ==(_: Adyen.ImageStyle, _: Adyen.ImageStyle) -> Swift.Bool
```
```javascript
// Parent: Root
public struct ListComponentStyle : ViewStyle
```
```javascript
// Parent: ListComponentStyle
public var listItem: Adyen.ListItemStyle { get set }
```
```javascript
// Parent: ListComponentStyle
public var sectionHeader: Adyen.ListSectionHeaderStyle { get set }
```
```javascript
// Parent: ListComponentStyle
public var partialPaymentSectionFooter: Adyen.ListSectionFooterStyle { get set }
```
```javascript
// Parent: ListComponentStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: ListComponentStyle
public init(listItem: Adyen.ListItemStyle, sectionHeader: Adyen.ListSectionHeaderStyle) -> Adyen.ListComponentStyle
```
```javascript
// Parent: ListComponentStyle
public init() -> Adyen.ListComponentStyle
```
```javascript
// Parent: Root
public enum CancelButtonStyle
```
```javascript
// Parent: CancelButtonStyle
public case system
```
```javascript
// Parent: CancelButtonStyle
public case legacy
```
```javascript
// Parent: CancelButtonStyle
public case custom(UIKit.UIImage)
```
```javascript
// Parent: Root
public enum ToolbarMode : Equatable, Hashable
```
```javascript
// Parent: ToolbarMode
public case leftCancel
```
```javascript
// Parent: ToolbarMode
public case rightCancel
```
```javascript
// Parent: ToolbarMode
public case natural
```
```javascript
// Parent: ToolbarMode
public static func __derived_enum_equals(_: Adyen.ToolbarMode, _: Adyen.ToolbarMode) -> Swift.Bool
```
```javascript
// Parent: ToolbarMode
public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: ToolbarMode
public var hashValue: Swift.Int { get }
```
```javascript
// Parent: Root
public struct NavigationStyle : TintableStyle, ViewStyle
```
```javascript
// Parent: NavigationStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: NavigationStyle
public var separatorColor: UIKit.UIColor? { get set }
```
```javascript
// Parent: NavigationStyle
public var tintColor: UIKit.UIColor? { get set }
```
```javascript
// Parent: NavigationStyle
public var cornerRadius: CoreGraphics.CGFloat { get set }
```
```javascript
// Parent: NavigationStyle
public var barTitle: Adyen.TextStyle { get set }
```
```javascript
// Parent: NavigationStyle
public var cancelButton: Adyen.CancelButtonStyle { get set }
```
```javascript
// Parent: NavigationStyle
public var toolbarMode: Adyen.ToolbarMode { get set }
```
```javascript
// Parent: NavigationStyle
public init() -> Adyen.NavigationStyle
```
```javascript
// Parent: Root
public struct ProgressViewStyle : ViewStyle
```
```javascript
// Parent: ProgressViewStyle
public let progressTintColor: UIKit.UIColor { get }
```
```javascript
// Parent: ProgressViewStyle
public let trackTintColor: UIKit.UIColor { get }
```
```javascript
// Parent: ProgressViewStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: ProgressViewStyle
public init(progressTintColor: UIKit.UIColor, trackTintColor: UIKit.UIColor) -> Adyen.ProgressViewStyle
```
```javascript
// Parent: Root
public struct SegmentedControlStyle : TintableStyle, ViewStyle
```
```javascript
// Parent: SegmentedControlStyle
public var textStyle: Adyen.TextStyle { get set }
```
```javascript
// Parent: SegmentedControlStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: SegmentedControlStyle
public var tintColor: UIKit.UIColor? { get set }
```
```javascript
// Parent: SegmentedControlStyle
public init(textStyle: Adyen.TextStyle, backgroundColor: UIKit.UIColor = $DEFAULT_ARG, tintColor: UIKit.UIColor = $DEFAULT_ARG) -> Adyen.SegmentedControlStyle
```
```javascript
// Parent: Root
public struct TextStyle : Equatable, ViewStyle
```
```javascript
// Parent: TextStyle
public var font: UIKit.UIFont { get set }
```
```javascript
// Parent: TextStyle
public var color: UIKit.UIColor { get set }
```
```javascript
// Parent: TextStyle
public var disabledColor: UIKit.UIColor { get set }
```
```javascript
// Parent: TextStyle
public var textAlignment: UIKit.NSTextAlignment { get set }
```
```javascript
// Parent: TextStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: TextStyle
public var cornerRounding: Adyen.CornerRounding { get set }
```
```javascript
// Parent: TextStyle
public init(font: UIKit.UIFont, color: UIKit.UIColor, disabledColor: UIKit.UIColor = $DEFAULT_ARG, textAlignment: UIKit.NSTextAlignment, cornerRounding: Adyen.CornerRounding = $DEFAULT_ARG, backgroundColor: UIKit.UIColor = $DEFAULT_ARG) -> Adyen.TextStyle
```
```javascript
// Parent: TextStyle
public init(font: UIKit.UIFont, color: UIKit.UIColor) -> Adyen.TextStyle
```
```javascript
// Parent: TextStyle
public static func ==(_: Adyen.TextStyle, _: Adyen.TextStyle) -> Swift.Bool
```
```javascript
// Parent: TextStyle
public var stringAttributes: [Foundation.NSAttributedString.Key : Any] { get }
```
```javascript
// Parent: Root
public protocol ViewStyle
```
```javascript
// Parent: ViewStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: Root
public protocol TintableStyle<Self : Adyen.ViewStyle> : ViewStyle
```
```javascript
// Parent: TintableStyle
public var tintColor: UIKit.UIColor? { get set }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) @objc public final class ADYViewController : AdyenCompatible, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSExtensionRequestHandling, NSObjectProtocol, Sendable, UIActivityItemsConfigurationProviding, UIAppearanceContainer, UIContentContainer, UIFocusEnvironment, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UIStateRestoring, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring, ViewControllerPresenter
```
```javascript
// Parent: ADYViewController
@_spi(AdyenInternal) public init(view: UIKit.UIView, title: Swift.String? = $DEFAULT_ARG) -> Adyen.ADYViewController
```
```javascript
// Parent: ADYViewController
@_spi(AdyenInternal) @objc override public func loadView() -> Swift.Void
```
```javascript
// Parent: ADYViewController
@_spi(AdyenInternal) @objc override public var preferredContentSize: CoreFoundation.CGSize { get set }
```
```javascript
// Parent: ADYViewController
@_spi(AdyenInternal) @objc override public dynamic init(nibName: Swift.String?, bundle: Foundation.Bundle?) -> Adyen.ADYViewController
```
```javascript
// Parent: Root
public struct LookupAddressModel
```
```javascript
// Parent: LookupAddressModel
public let identifier: Swift.String { get }
```
```javascript
// Parent: LookupAddressModel
public let postalAddress: Adyen.PostalAddress { get }
```
```javascript
// Parent: LookupAddressModel
public init(identifier: Swift.String, postalAddress: Adyen.PostalAddress) -> Adyen.LookupAddressModel
```
```javascript
// Parent: Root
public protocol AddressLookupProvider<Self : AnyObject>
```
```javascript
// Parent: AddressLookupProvider
public func lookUp<Self where Self : Adyen.AddressLookupProvider>(searchTerm: Swift.String, resultHandler: ([Adyen.LookupAddressModel]) -> Swift.Void) -> Swift.Void
```
```javascript
// Parent: AddressLookupProvider
public func complete<Self where Self : Adyen.AddressLookupProvider>(incompleteAddress: Adyen.LookupAddressModel, resultHandler: (Swift.Result<Adyen.PostalAddress, any Swift.Error>) -> Swift.Void) -> Swift.Void
```
```javascript
// Parent: AddressLookupProvider
public func complete<Self where Self : Adyen.AddressLookupProvider>(incompleteAddress: Adyen.LookupAddressModel, resultHandler: (Swift.Result<Adyen.PostalAddress, any Swift.Error>) -> Swift.Void) -> Swift.Void
```
```javascript
// Parent: Root
public struct AddressLookupStyle : ViewStyle
```
```javascript
// Parent: AddressLookupStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: AddressLookupStyle
public var search: Adyen.AddressLookupSearchStyle { get set }
```
```javascript
// Parent: AddressLookupStyle
public var form: Adyen.FormComponentStyle { get set }
```
```javascript
// Parent: AddressLookupStyle
public init(search: Adyen.AddressLookupSearchStyle = $DEFAULT_ARG, form: Adyen.FormComponentStyle = $DEFAULT_ARG) -> Adyen.AddressLookupStyle
```
```javascript
// Parent: Root
@_spi(AdyenInternal) @objc public class AddressLookupViewController : AdyenCompatible, AdyenObserver, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSExtensionRequestHandling, NSObjectProtocol, Sendable, UIActivityItemsConfigurationProviding, UIAppearanceContainer, UIContentContainer, UIFocusEnvironment, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UIStateRestoring, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring, ViewControllerPresenter
```
```javascript
// Parent: AddressLookupViewController
@_spi(AdyenInternal) public init(viewModel: Adyen.AddressLookupViewController.ViewModel) -> Adyen.AddressLookupViewController
```
```javascript
// Parent: AddressLookupViewController
@_spi(AdyenInternal) @objc override public dynamic func viewDidLoad() -> Swift.Void
```
```javascript
// Parent: AddressLookupViewController
@_spi(AdyenInternal) @objc override public dynamic init(navigationBarClass: Swift.AnyClass?, toolbarClass: Swift.AnyClass?) -> Adyen.AddressLookupViewController
```
```javascript
// Parent: AddressLookupViewController
@_spi(AdyenInternal) @objc override public dynamic init(rootViewController: UIKit.UIViewController) -> Adyen.AddressLookupViewController
```
```javascript
// Parent: AddressLookupViewController
@_spi(AdyenInternal) @objc override public dynamic init(nibName: Swift.String?, bundle: Foundation.Bundle?) -> Adyen.AddressLookupViewController
```
```javascript
// Parent: AddressLookupViewController
@_spi(AdyenInternal) public struct ViewModel
```
```javascript
// Parent: AddressLookupViewController.ViewModel
@_spi(AdyenInternal) public init(for: Adyen.FormAddressPickerItem.AddressType, style: Adyen.AddressLookupStyle = $DEFAULT_ARG, localizationParameters: Adyen.LocalizationParameters?, supportedCountryCodes: [Swift.String]?, initialCountry: Swift.String, prefillAddress: Adyen.PostalAddress? = $DEFAULT_ARG, lookupProvider: any Adyen.AddressLookupProvider, completionHandler: (Adyen.PostalAddress?) -> Swift.Void) -> Adyen.AddressLookupViewController.ViewModel
```
```javascript
// Parent: Root
@_spi(AdyenInternal) @objc public class AddressInputFormViewController : AdyenCompatible, AdyenObserver, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, FormTextItemViewDelegate, FormViewProtocol, Hashable, NSCoding, NSExtensionRequestHandling, NSObjectProtocol, PreferredContentSizeConsumer, Sendable, UIActivityItemsConfigurationProviding, UIAppearanceContainer, UIContentContainer, UIFocusEnvironment, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UIStateRestoring, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring, ViewControllerPresenter
```
```javascript
// Parent: AddressInputFormViewController
@_spi(AdyenInternal) public init(viewModel: Adyen.AddressInputFormViewController.ViewModel) -> Adyen.AddressInputFormViewController
```
```javascript
// Parent: AddressInputFormViewController
@_spi(AdyenInternal) @objc override public dynamic func viewDidLoad() -> Swift.Void
```
```javascript
// Parent: AddressInputFormViewController
@_spi(AdyenInternal) override public init(style: any Adyen.ViewStyle, localizationParameters: Adyen.LocalizationParameters?) -> Adyen.AddressInputFormViewController
```
```javascript
// Parent: AddressInputFormViewController
@_spi(AdyenInternal) public typealias ShowSearchHandler = (Adyen.PostalAddress) -> Swift.Void
```
```javascript
// Parent: AddressInputFormViewController
@_spi(AdyenInternal) public struct ViewModel
```
```javascript
// Parent: AddressInputFormViewController.ViewModel
@_spi(AdyenInternal) public init(for: Adyen.FormAddressPickerItem.AddressType, style: Adyen.FormComponentStyle, localizationParameters: Adyen.LocalizationParameters?, initialCountry: Swift.String, prefillAddress: Adyen.PostalAddress?, supportedCountryCodes: [Swift.String]?, addressViewModelBuilder: any Adyen.AddressViewModelBuilder = $DEFAULT_ARG, handleShowSearch: Adyen.AddressInputFormViewController.ShowSearchHandler? = $DEFAULT_ARG, completionHandler: (Adyen.PostalAddress?) -> Swift.Void) -> Adyen.AddressInputFormViewController.ViewModel
```
```javascript
// Parent: Root
public struct AddressLookupSearchStyle : ViewStyle
```
```javascript
// Parent: AddressLookupSearchStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: AddressLookupSearchStyle
public var manualEntryListItem: Adyen.ListItemStyle { get set }
```
```javascript
// Parent: AddressLookupSearchStyle
public var emptyView: Adyen.EmptyStateViewStyle { get set }
```
```javascript
// Parent: AddressLookupSearchStyle
public init() -> Adyen.AddressLookupSearchStyle
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol SearchResultsEmptyView<Self : UIKit.UIView>
```
```javascript
// Parent: SearchResultsEmptyView
@_spi(AdyenInternal) public var searchTerm: Swift.String { get set }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) @objc public class SearchViewController : AdyenCompatible, AdyenObserver, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSExtensionRequestHandling, NSObjectProtocol, Sendable, UIActivityItemsConfigurationProviding, UIAppearanceContainer, UIBarPositioningDelegate, UIContentContainer, UIFocusEnvironment, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UISearchBarDelegate, UIStateRestoring, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring, ViewControllerPresenter
```
```javascript
// Parent: SearchViewController
@_spi(AdyenInternal) public weak var delegate: (any Adyen.ViewControllerDelegate)? { get set }
```
```javascript
// Parent: SearchViewController
@_spi(AdyenInternal) public lazy var resultsListViewController: Adyen.ListViewController { get set }
```
```javascript
// Parent: SearchViewController
@_spi(AdyenInternal) public init(viewModel: Adyen.SearchViewController.ViewModel, emptyView: any Adyen.SearchResultsEmptyView) -> Adyen.SearchViewController
```
```javascript
// Parent: SearchViewController
@_spi(AdyenInternal) @objc override public dynamic func viewDidLoad() -> Swift.Void
```
```javascript
// Parent: SearchViewController
@_spi(AdyenInternal) @objc override public dynamic func viewWillAppear(_: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: SearchViewController
@_spi(AdyenInternal) @objc override open dynamic func viewDidAppear(_: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: SearchViewController
@_spi(AdyenInternal) @objc override public dynamic var preferredContentSize: CoreFoundation.CGSize { get set }
```
```javascript
// Parent: SearchViewController
@_spi(AdyenInternal) @objc override public dynamic init(nibName: Swift.String?, bundle: Foundation.Bundle?) -> Adyen.SearchViewController
```
```javascript
// Parent: SearchViewController
@_spi(AdyenInternal) public struct ViewModel
```
```javascript
// Parent: SearchViewController.ViewModel
@_spi(AdyenInternal) public typealias ResultProvider = (Swift.String, @escaping ([Adyen.ListItem]) -> Swift.Void) -> Swift.Void
```
```javascript
// Parent: SearchViewController.ViewModel
@_spi(AdyenInternal) public init(localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, style: any Adyen.ViewStyle, searchBarPlaceholder: Swift.String? = $DEFAULT_ARG, shouldFocusSearchBarOnAppearance: Swift.Bool = $DEFAULT_ARG, resultProvider: Adyen.SearchViewController.ViewModel.ResultProvider) -> Adyen.SearchViewController.ViewModel
```
```javascript
// Parent: SearchViewController
@_spi(AdyenInternal) @objc public dynamic func searchBar(_: UIKit.UISearchBar, textDidChange: Swift.String) -> Swift.Void
```
```javascript
// Parent: SearchViewController
@_spi(AdyenInternal) @objc public dynamic func searchBarSearchButtonClicked(_: UIKit.UISearchBar) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class SecuredViewController<ChildViewController where ChildViewController : UIKit.UIViewController> : AdyenCompatible, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSExtensionRequestHandling, NSObjectProtocol, Sendable, UIActivityItemsConfigurationProviding, UIAppearanceContainer, UIContentContainer, UIFocusEnvironment, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UIStateRestoring, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring, ViewControllerPresenter
```
```javascript
// Parent: SecuredViewController
@_spi(AdyenInternal) public weak var delegate: (any Adyen.ViewControllerDelegate)? { get set }
```
```javascript
// Parent: SecuredViewController
@_spi(AdyenInternal) @objc override public var preferredContentSize: CoreFoundation.CGSize { get set }
```
```javascript
// Parent: SecuredViewController
@_spi(AdyenInternal) @objc override public var title: Swift.String? { get set }
```
```javascript
// Parent: SecuredViewController
@_spi(AdyenInternal) public init<ChildViewController where ChildViewController : UIKit.UIViewController>(child: ChildViewController, style: any Adyen.ViewStyle) -> Adyen.SecuredViewController<ChildViewController>
```
```javascript
// Parent: SecuredViewController
@_spi(AdyenInternal) @objc override public func viewDidLoad<ChildViewController where ChildViewController : UIKit.UIViewController>() -> Swift.Void
```
```javascript
// Parent: SecuredViewController
@_spi(AdyenInternal) @objc override public func viewDidAppear<ChildViewController where ChildViewController : UIKit.UIViewController>(_: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: SecuredViewController
@_spi(AdyenInternal) @objc override public func viewWillAppear<ChildViewController where ChildViewController : UIKit.UIViewController>(_: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: SecuredViewController
@_spi(AdyenInternal) @objc override public dynamic init<ChildViewController where ChildViewController : UIKit.UIViewController>(nibName: Swift.String?, bundle: Foundation.Bundle?) -> Adyen.SecuredViewController<ChildViewController>
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol ViewControllerDelegate<Self : AnyObject>
```
```javascript
// Parent: ViewControllerDelegate
@_spi(AdyenInternal) public func viewDidLoad<Self where Self : Adyen.ViewControllerDelegate>(viewController: UIKit.UIViewController) -> Swift.Void
```
```javascript
// Parent: ViewControllerDelegate
@_spi(AdyenInternal) public func viewDidAppear<Self where Self : Adyen.ViewControllerDelegate>(viewController: UIKit.UIViewController) -> Swift.Void
```
```javascript
// Parent: ViewControllerDelegate
@_spi(AdyenInternal) public func viewWillAppear<Self where Self : Adyen.ViewControllerDelegate>(viewController: UIKit.UIViewController) -> Swift.Void
```
```javascript
// Parent: ViewControllerDelegate
@_spi(AdyenInternal) public func viewDidLoad<Self where Self : Adyen.ViewControllerDelegate>(viewController: UIKit.UIViewController) -> Swift.Void
```
```javascript
// Parent: ViewControllerDelegate
@_spi(AdyenInternal) public func viewDidAppear<Self where Self : Adyen.ViewControllerDelegate>(viewController: UIKit.UIViewController) -> Swift.Void
```
```javascript
// Parent: ViewControllerDelegate
@_spi(AdyenInternal) public func viewWillAppear<Self where Self : Adyen.ViewControllerDelegate>(viewController: UIKit.UIViewController) -> Swift.Void
```
```javascript
// Parent: Root
@objc public final class ContainerView : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: ContainerView
public init(body: UIKit.UIView, padding: UIKit.UIEdgeInsets = $DEFAULT_ARG) -> Adyen.ContainerView
```
```javascript
// Parent: ContainerView
public func setupConstraints() -> Swift.Void
```
```javascript
// Parent: ContainerView
@objc override public dynamic init(frame: CoreFoundation.CGRect) -> Adyen.ContainerView
```
```javascript
// Parent: Root
@_spi(AdyenInternal) @objc public final class CopyLabelView : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, Localizable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: CopyLabelView
@_spi(AdyenInternal) public var localizationParameters: Adyen.LocalizationParameters? { get set }
```
```javascript
// Parent: CopyLabelView
@_spi(AdyenInternal) public init(text: Swift.String, style: Adyen.TextStyle) -> Adyen.CopyLabelView
```
```javascript
// Parent: CopyLabelView
@_spi(AdyenInternal) @objc override public var canBecomeFirstResponder: Swift.Bool { get }
```
```javascript
// Parent: CopyLabelView
@_spi(AdyenInternal) @discardableResult @objc override public func becomeFirstResponder() -> Swift.Bool
```
```javascript
// Parent: CopyLabelView
@_spi(AdyenInternal) @objc override public dynamic init(frame: CoreFoundation.CGRect) -> Adyen.CopyLabelView
```
```javascript
// Parent: Root
public struct EmptyStateViewStyle : ViewStyle
```
```javascript
// Parent: EmptyStateViewStyle
public var title: Adyen.TextStyle { get set }
```
```javascript
// Parent: EmptyStateViewStyle
public var subtitle: Adyen.TextStyle { get set }
```
```javascript
// Parent: EmptyStateViewStyle
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public class EmptyStateView<SubtitleLabel where SubtitleLabel : UIKit.UIView> : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, SearchResultsEmptyView, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: EmptyStateView
@_spi(AdyenInternal) public var searchTerm: Swift.String { get set }
```
```javascript
// Parent: EmptyStateView
@_spi(AdyenInternal) @objc override public dynamic init<SubtitleLabel where SubtitleLabel : UIKit.UIView>(frame: CoreFoundation.CGRect) -> Adyen.EmptyStateView<SubtitleLabel>
```
```javascript
// Parent: Root
@_spi(AdyenInternal) @objc public class LinkTextView : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UIContentSizeCategoryAdjusting, UICoordinateSpace, UIDynamicItem, UIFindInteractionDelegate, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UIFocusItemScrollableContainer, UIKeyInput, UILargeContentViewerItem, UILetterformAwareAdjusting, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UIScrollViewDelegate, UITextDraggable, UITextDroppable, UITextInput, UITextInputTraits, UITextPasteConfigurationSupporting, UITextViewDelegate, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: LinkTextView
@_spi(AdyenInternal) public init(linkSelectionHandler: (Swift.Int) -> Swift.Void) -> Adyen.LinkTextView
```
```javascript
// Parent: LinkTextView
@_spi(AdyenInternal) public func update(text: Swift.String, style: Adyen.TextStyle, linkRangeDelimiter: Swift.String = $DEFAULT_ARG) -> Swift.Void
```
```javascript
// Parent: LinkTextView
@_spi(AdyenInternal) @objc override public dynamic init(frame: CoreFoundation.CGRect, textContainer: UIKit.NSTextContainer?) -> Adyen.LinkTextView
```
```javascript
// Parent: LinkTextView
@_spi(AdyenInternal) @objc public dynamic func textView(_: UIKit.UITextView, shouldInteractWith: Foundation.URL, in: Foundation.NSRange, interaction: UIKit.UITextItemInteraction) -> Swift.Bool
```
```javascript
// Parent: Root
@_spi(AdyenInternal) @objc public final class LoadingView : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UIContextMenuInteractionDelegate, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: LoadingView
@_spi(AdyenInternal) public var disableUserInteractionWhileLoading: Swift.Bool { get set }
```
```javascript
// Parent: LoadingView
@_spi(AdyenInternal) public var spinnerAppearanceDelay: Dispatch.DispatchTimeInterval { get set }
```
```javascript
// Parent: LoadingView
@_spi(AdyenInternal) public init(contentView: UIKit.UIView) -> Adyen.LoadingView
```
```javascript
// Parent: LoadingView
@_spi(AdyenInternal) public var showsActivityIndicator: Swift.Bool { get set }
```
```javascript
// Parent: LoadingView
@_spi(AdyenInternal) @objc override public dynamic init(frame: CoreFoundation.CGRect) -> Adyen.LoadingView
```
```javascript
// Parent: Root
@_spi(AdyenInternal) @objc public final class SubmitButton : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UIContextMenuInteractionDelegate, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: SubmitButton
@_spi(AdyenInternal) public init(style: Adyen.ButtonStyle) -> Adyen.SubmitButton
```
```javascript
// Parent: SubmitButton
@_spi(AdyenInternal) public var title: Swift.String? { get set }
```
```javascript
// Parent: SubmitButton
@_spi(AdyenInternal) @objc override public var accessibilityIdentifier: Swift.String? { get set }
```
```javascript
// Parent: SubmitButton
@_spi(AdyenInternal) public var showsActivityIndicator: Swift.Bool { get set }
```
```javascript
// Parent: SubmitButton
@_spi(AdyenInternal) @objc override public func layoutSubviews() -> Swift.Void
```
```javascript
// Parent: SubmitButton
@_spi(AdyenInternal) @objc override public var isHighlighted: Swift.Bool { get set }
```
```javascript
// Parent: SubmitButton
@_spi(AdyenInternal) @objc override public dynamic init(frame: CoreFoundation.CGRect) -> Adyen.SubmitButton
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum AdyenCoder
```
```javascript
// Parent: AdyenCoder
@_spi(AdyenInternal) public static func decode<T where T : Swift.Decodable>(_: Foundation.Data) throws -> T
```
```javascript
// Parent: AdyenCoder
@_spi(AdyenInternal) public static func decode<T where T : Swift.Decodable>(_: Swift.String) throws -> T
```
```javascript
// Parent: AdyenCoder
@_spi(AdyenInternal) public static func decodeBase64<T where T : Swift.Decodable>(_: Swift.String) throws -> T
```
```javascript
// Parent: AdyenCoder
@_spi(AdyenInternal) public static func encode(_: some Swift.Encodable) throws -> Foundation.Data
```
```javascript
// Parent: AdyenCoder
@_spi(AdyenInternal) public static func encode(_: some Swift.Encodable) throws -> Swift.String
```
```javascript
// Parent: AdyenCoder
@_spi(AdyenInternal) public static func encodeBase64(_: some Swift.Encodable) throws -> Swift.String
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public class Analytics
```
```javascript
// Parent: Analytics
@_spi(AdyenInternal) public enum Flavor : Equatable, Hashable, RawRepresentable
```
```javascript
// Parent: Analytics.Flavor
@_spi(AdyenInternal) public case components
```
```javascript
// Parent: Analytics.Flavor
@_spi(AdyenInternal) public case dropin
```
```javascript
// Parent: Analytics.Flavor
@_spi(AdyenInternal) @inlinable public init(rawValue: Swift.String) -> Adyen.Analytics.Flavor?
```
```javascript
// Parent: Analytics.Flavor
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
// Parent: Analytics.Flavor
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
// Parent: Analytics
@_spi(AdyenInternal) public struct Event
```
```javascript
// Parent: Analytics.Event
@_spi(AdyenInternal) public init(component: Swift.String, flavor: Adyen.Analytics.Flavor, environment: any AdyenNetworking.AnyAPIEnvironment) -> Adyen.Analytics.Event
```
```javascript
// Parent: Analytics.Event
@_spi(AdyenInternal) public init(component: Swift.String, flavor: Adyen.Analytics.Flavor, context: Adyen.APIContext) -> Adyen.Analytics.Event
```
```javascript
// Parent: Analytics
@_spi(AdyenInternal) public static var isEnabled: Swift.Bool { get set }
```
```javascript
// Parent: Analytics
@_spi(AdyenInternal) public static func sendEvent(component: Swift.String, flavor: Adyen.Analytics.Flavor, environment: any AdyenNetworking.AnyAPIEnvironment) -> Swift.Void
```
```javascript
// Parent: Analytics
@_spi(AdyenInternal) public static func sendEvent(component: Swift.String, flavor: Adyen.Analytics.Flavor, context: Adyen.APIContext) -> Swift.Void
```
```javascript
// Parent: Analytics
@_spi(AdyenInternal) public static func sendEvent(_: Adyen.Analytics.Event) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol AnyAppLauncher
```
```javascript
// Parent: AnyAppLauncher
@_spi(AdyenInternal) public func openCustomSchemeUrl<Self where Self : Adyen.AnyAppLauncher>(_: Foundation.URL, completion: ((Swift.Bool) -> Swift.Void)?) -> Swift.Void
```
```javascript
// Parent: AnyAppLauncher
@_spi(AdyenInternal) public func openUniversalAppUrl<Self where Self : Adyen.AnyAppLauncher>(_: Foundation.URL, completion: ((Swift.Bool) -> Swift.Void)?) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct AppLauncher : AnyAppLauncher
```
```javascript
// Parent: AppLauncher
@_spi(AdyenInternal) public init() -> Adyen.AppLauncher
```
```javascript
// Parent: AppLauncher
@_spi(AdyenInternal) public func openCustomSchemeUrl(_: Foundation.URL, completion: ((Swift.Bool) -> Swift.Void)?) -> Swift.Void
```
```javascript
// Parent: AppLauncher
@_spi(AdyenInternal) public func openUniversalAppUrl(_: Foundation.URL, completion: ((Swift.Bool) -> Swift.Void)?) -> Swift.Void
```
```javascript
// Parent: Root
public typealias Completion = (T) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public typealias AssertionListener = (Swift.String) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum AdyenAssertion
```
```javascript
// Parent: AdyenAssertion
@_spi(AdyenInternal) public static func assertionFailure(message: () -> Swift.String) -> Swift.Void
```
```javascript
// Parent: AdyenAssertion
@_spi(AdyenInternal) public static func assert(message: () -> Swift.String, condition: () -> Swift.Bool) -> Swift.Void
```
```javascript
// Parent: Root
public enum AdyenLogging
```
```javascript
// Parent: AdyenLogging
public static var isEnabled: Swift.Bool { get set }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public func adyenPrint(_: Any..., separator: Swift.String = $DEFAULT_ARG, terminator: Swift.String = $DEFAULT_ARG) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct Region : CustomStringConvertible, Decodable, Equatable
```
```javascript
// Parent: Region
@_spi(AdyenInternal) public let identifier: Swift.String { get }
```
```javascript
// Parent: Region
@_spi(AdyenInternal) public let name: Swift.String { get }
```
```javascript
// Parent: Region
@_spi(AdyenInternal) public var description: Swift.String { get }
```
```javascript
// Parent: Region
@_spi(AdyenInternal) public static func __derived_struct_equals(_: Adyen.Region, _: Adyen.Region) -> Swift.Bool
```
```javascript
// Parent: Region
@_spi(AdyenInternal) public init(from: any Swift.Decoder) throws -> Adyen.Region
```
```javascript
// Parent: Root
public final class LogoURLProvider
```
```javascript
// Parent: LogoURLProvider
public init(environment: any AdyenNetworking.AnyAPIEnvironment) -> Adyen.LogoURLProvider
```
```javascript
// Parent: LogoURLProvider
public func logoURL(withName: Swift.String, size: Adyen.LogoURLProvider.Size = $DEFAULT_ARG) -> Foundation.URL
```
```javascript
// Parent: LogoURLProvider
public static func logoURL(for: Adyen.Issuer, localizedParameters: Adyen.LocalizationParameters?, paymentMethod: Adyen.IssuerListPaymentMethod, environment: any AdyenNetworking.AnyAPIEnvironment) -> Foundation.URL
```
```javascript
// Parent: LogoURLProvider
public static func logoURL(withName: Swift.String, environment: any AdyenNetworking.AnyAPIEnvironment, size: Adyen.LogoURLProvider.Size = $DEFAULT_ARG) -> Foundation.URL
```
```javascript
// Parent: LogoURLProvider
public enum Size : Equatable, Hashable, RawRepresentable
```
```javascript
// Parent: LogoURLProvider.Size
public case small
```
```javascript
// Parent: LogoURLProvider.Size
public case medium
```
```javascript
// Parent: LogoURLProvider.Size
public case large
```
```javascript
// Parent: LogoURLProvider.Size
@inlinable public init(rawValue: Swift.String) -> Adyen.LogoURLProvider.Size?
```
```javascript
// Parent: LogoURLProvider.Size
public typealias RawValue = Swift.String
```
```javascript
// Parent: LogoURLProvider.Size
public var rawValue: Swift.String { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum PhoneNumberPaymentMethod : Equatable, Hashable
```
```javascript
// Parent: PhoneNumberPaymentMethod
@_spi(AdyenInternal) public case qiwiWallet
```
```javascript
// Parent: PhoneNumberPaymentMethod
@_spi(AdyenInternal) public case mbWay
```
```javascript
// Parent: PhoneNumberPaymentMethod
@_spi(AdyenInternal) public case generic
```
```javascript
// Parent: PhoneNumberPaymentMethod
@_spi(AdyenInternal) public static func __derived_enum_equals(_: Adyen.PhoneNumberPaymentMethod, _: Adyen.PhoneNumberPaymentMethod) -> Swift.Bool
```
```javascript
// Parent: PhoneNumberPaymentMethod
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: PhoneNumberPaymentMethod
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct PhoneExtensionsQuery
```
```javascript
// Parent: PhoneExtensionsQuery
@_spi(AdyenInternal) public let codes: [Swift.String] { get }
```
```javascript
// Parent: PhoneExtensionsQuery
@_spi(AdyenInternal) public init(codes: [Swift.String]) -> Adyen.PhoneExtensionsQuery
```
```javascript
// Parent: PhoneExtensionsQuery
@_spi(AdyenInternal) public init(paymentMethod: Adyen.PhoneNumberPaymentMethod) -> Adyen.PhoneExtensionsQuery
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum PhoneExtensionsRepository
```
```javascript
// Parent: PhoneExtensionsRepository
@_spi(AdyenInternal) public static func get(with: Adyen.PhoneExtensionsQuery) -> [Adyen.PhoneExtension]
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct IBANSpecification
```
```javascript
// Parent: IBANSpecification
@_spi(AdyenInternal) public static let highestMaximumLength: Swift.Int { get }
```
```javascript
// Parent: IBANSpecification
@_spi(AdyenInternal) public let countryCode: Swift.String { get }
```
```javascript
// Parent: IBANSpecification
@_spi(AdyenInternal) public let length: Swift.Int { get }
```
```javascript
// Parent: IBANSpecification
@_spi(AdyenInternal) public let structure: Swift.String { get }
```
```javascript
// Parent: IBANSpecification
@_spi(AdyenInternal) public let example: Swift.String { get }
```
```javascript
// Parent: IBANSpecification
@_spi(AdyenInternal) public init(forCountryCode: Swift.String) -> Adyen.IBANSpecification?
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public class KeyboardObserver
```
```javascript
// Parent: KeyboardObserver
@_spi(AdyenInternal) public var keyboardRect: CoreFoundation.CGRect { get }
```
```javascript
// Parent: KeyboardObserver
@_spi(AdyenInternal) public var $keyboardRect: Adyen.AdyenObservable<CoreFoundation.CGRect> { get }
```
```javascript
// Parent: KeyboardObserver
@_spi(AdyenInternal) public init() -> Adyen.KeyboardObserver
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public func localizedString(_: Adyen.LocalizationKey, _: Adyen.LocalizationParameters?, _: any Swift.CVarArg...) -> Swift.String
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum PaymentStyle
```
```javascript
// Parent: PaymentStyle
@_spi(AdyenInternal) public case needsRedirectToThirdParty(Swift.String)
```
```javascript
// Parent: PaymentStyle
@_spi(AdyenInternal) public case immediate
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public func localizedSubmitButtonTitle(with: Adyen.Amount?, style: Adyen.PaymentStyle, _: Adyen.LocalizationParameters?) -> Swift.String
```
```javascript
// Parent: Root
public struct LocalizationParameters : Equatable
```
```javascript
// Parent: LocalizationParameters
public static func ==(_: Adyen.LocalizationParameters, _: Adyen.LocalizationParameters) -> Swift.Bool
```
```javascript
// Parent: LocalizationParameters
public var locale: Swift.String? { get }
```
```javascript
// Parent: LocalizationParameters
public var tableName: Swift.String? { get }
```
```javascript
// Parent: LocalizationParameters
public var keySeparator: Swift.String? { get }
```
```javascript
// Parent: LocalizationParameters
public var bundle: Foundation.Bundle? { get }
```
```javascript
// Parent: LocalizationParameters
public init(bundle: Foundation.Bundle? = $DEFAULT_ARG, tableName: Swift.String? = $DEFAULT_ARG, keySeparator: Swift.String? = $DEFAULT_ARG, locale: Swift.String? = $DEFAULT_ARG) -> Adyen.LocalizationParameters
```
```javascript
// Parent: LocalizationParameters
public init(enforcedLocale: Swift.String) -> Adyen.LocalizationParameters
```
```javascript
// Parent: Root
public final class AdyenObservable<ValueType where ValueType : Swift.Equatable> : EventPublisher
```
```javascript
// Parent: AdyenObservable
public init<ValueType where ValueType : Swift.Equatable>(_: ValueType) -> Adyen.AdyenObservable<ValueType>
```
```javascript
// Parent: AdyenObservable
public var wrappedValue: ValueType { get set }
```
```javascript
// Parent: AdyenObservable
public typealias Event = ValueType
```
```javascript
// Parent: AdyenObservable
public var eventHandlers: [Adyen.EventHandlerToken : Adyen.EventHandler<Adyen.AdyenObservable<ValueType>.Event>] { get set }
```
```javascript
// Parent: AdyenObservable
public var projectedValue: Adyen.AdyenObservable<ValueType> { get }
```
```javascript
// Parent: Root
public protocol AdyenObserver<Self : AnyObject>
```
```javascript
// Parent: AdyenObserver
@_spi(AdyenInternal) @discardableResult public func observe<Self, T where Self : Adyen.AdyenObserver, T : Adyen.EventPublisher>(_: T, eventHandler: Adyen.EventHandler<T.Event>) -> Adyen.Observation
```
```javascript
// Parent: AdyenObserver
@_spi(AdyenInternal) @discardableResult public func bind<Self, Value, Target where Self : Adyen.AdyenObserver, Value : Swift.Equatable, Target : AnyObject>(_: Adyen.AdyenObservable<Value>, to: Target, at: Swift.ReferenceWritableKeyPath<Target, Value>) -> Adyen.Observation
```
```javascript
// Parent: AdyenObserver
@_spi(AdyenInternal) @discardableResult public func bind<Self, Value, Target where Self : Adyen.AdyenObserver, Value : Swift.Equatable, Target : AnyObject>(_: Adyen.AdyenObservable<Value>, to: Target, at: Swift.ReferenceWritableKeyPath<Target, Value?>) -> Adyen.Observation
```
```javascript
// Parent: AdyenObserver
@_spi(AdyenInternal) @discardableResult public func bind<Self, Value, Result, Target where Self : Adyen.AdyenObserver, Value : Swift.Equatable, Target : AnyObject>(_: Adyen.AdyenObservable<Value>, to: Target, at: Swift.ReferenceWritableKeyPath<Target, Result>, with: ((Value) -> Result)) -> Adyen.Observation
```
```javascript
// Parent: AdyenObserver
@_spi(AdyenInternal) @discardableResult public func bind<Self, Value, Result, Target where Self : Adyen.AdyenObserver, Value : Swift.Equatable, Target : AnyObject>(_: Adyen.AdyenObservable<Value>, at: Swift.KeyPath<Value, Result>, to: Target, at: Swift.ReferenceWritableKeyPath<Target, Result>) -> Adyen.Observation
```
```javascript
// Parent: AdyenObserver
@_spi(AdyenInternal) @discardableResult public func bind<Self, Value, Result, Target where Self : Adyen.AdyenObserver, Value : Swift.Equatable, Target : AnyObject>(_: Adyen.AdyenObservable<Value>, at: Swift.KeyPath<Value, Result>, to: Target, at: Swift.ReferenceWritableKeyPath<Target, Result?>) -> Adyen.Observation
```
```javascript
// Parent: AdyenObserver
@_spi(AdyenInternal) public func remove<Self where Self : Adyen.AdyenObserver>(_: Adyen.Observation) -> Swift.Void
```
```javascript
// Parent: Root
public protocol EventPublisher<Self : AnyObject>
```
```javascript
// Parent: EventPublisher
public associatedtype Event
```
```javascript
// Parent: EventPublisher
public var eventHandlers: [Adyen.EventHandlerToken : Adyen.EventHandler<Self.Event>] { get set }
```
```javascript
// Parent: EventPublisher
@_spi(AdyenInternal) public func addEventHandler<Self where Self : Adyen.EventPublisher>(_: Adyen.EventHandler<Self.Event>) -> Adyen.EventHandlerToken
```
```javascript
// Parent: EventPublisher
@_spi(AdyenInternal) public func removeEventHandler<Self where Self : Adyen.EventPublisher>(with: Adyen.EventHandlerToken) -> Swift.Void
```
```javascript
// Parent: EventPublisher
@_spi(AdyenInternal) public func publish<Self where Self : Adyen.EventPublisher>(_: Self.Event) -> Swift.Void
```
```javascript
// Parent: Root
public typealias EventHandler = (Event) -> Swift.Void
```
```javascript
// Parent: Root
public struct EventHandlerToken : Equatable, Hashable
```
```javascript
// Parent: EventHandlerToken
public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: EventHandlerToken
public static func __derived_struct_equals(_: Adyen.EventHandlerToken, _: Adyen.EventHandlerToken) -> Swift.Bool
```
```javascript
// Parent: EventHandlerToken
public var hashValue: Swift.Int { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct Observation : Equatable, Hashable
```
```javascript
// Parent: Observation
@_spi(AdyenInternal) public static func ==(_: Adyen.Observation, _: Adyen.Observation) -> Swift.Bool
```
```javascript
// Parent: Observation
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: Observation
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol PublicKeyConsumer<Self : Adyen.PaymentComponent> : AdyenContextAware, Component, PartialPaymentOrderAware, PaymentComponent, PaymentMethodAware
```
```javascript
// Parent: PublicKeyConsumer
@_spi(AdyenInternal) public var publicKeyProvider: any Adyen.AnyPublicKeyProvider { get }
```
```javascript
// Parent: PublicKeyConsumer
@_spi(AdyenInternal) public typealias PublicKeySuccessHandler = (Swift.String) -> Swift.Void
```
```javascript
// Parent: PublicKeyConsumer
@_spi(AdyenInternal) public func fetchCardPublicKey<Self where Self : Adyen.PublicKeyConsumer>(notifyingDelegateOnFailure: Swift.Bool, successHandler: Self.PublicKeySuccessHandler? = $DEFAULT_ARG) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol AnyPublicKeyProvider<Self : AnyObject>
```
```javascript
// Parent: AnyPublicKeyProvider
@_spi(AdyenInternal) public typealias CompletionHandler = (Swift.Result<Swift.String, any Swift.Error>) -> Swift.Void
```
```javascript
// Parent: AnyPublicKeyProvider
@_spi(AdyenInternal) public func fetch<Self where Self : Adyen.AnyPublicKeyProvider>(completion: Self.CompletionHandler) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class PublicKeyProvider : AnyPublicKeyProvider
```
```javascript
// Parent: PublicKeyProvider
@_spi(AdyenInternal) public convenience init(apiContext: Adyen.APIContext) -> Adyen.PublicKeyProvider
```
```javascript
// Parent: PublicKeyProvider
@_spi(AdyenInternal) public func fetch(completion: Adyen.PublicKeyProvider.CompletionHandler) -> Swift.Void
```
```javascript
// Parent: PublicKeyProvider
@_spi(AdyenInternal) public enum Error : Equatable, Error, Hashable, LocalizedError, Sendable
```
```javascript
// Parent: PublicKeyProvider.Error
@_spi(AdyenInternal) public case invalidClientKey
```
```javascript
// Parent: PublicKeyProvider.Error
@_spi(AdyenInternal) public var errorDescription: Swift.String? { get }
```
```javascript
// Parent: PublicKeyProvider.Error
@_spi(AdyenInternal) public static func __derived_enum_equals(_: Adyen.PublicKeyProvider.Error, _: Adyen.PublicKeyProvider.Error) -> Swift.Bool
```
```javascript
// Parent: PublicKeyProvider.Error
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: PublicKeyProvider.Error
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class Throttler
```
```javascript
// Parent: Throttler
@_spi(AdyenInternal) public init(minimumDelay: Foundation.TimeInterval, queue: Dispatch.DispatchQueue = $DEFAULT_ARG) -> Adyen.Throttler
```
```javascript
// Parent: Throttler
@_spi(AdyenInternal) public func throttle(_: () -> Swift.Void) -> Swift.Void
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum ViewIdentifierBuilder
```
```javascript
// Parent: ViewIdentifierBuilder
@_spi(AdyenInternal) public static func build(scopeInstance: Any, postfix: Swift.String) -> Swift.String
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum AddressAnalyticsValidationError : AnalyticsValidationError, Equatable, Error, Hashable, LocalizedError, Sendable, ValidationError
```
```javascript
// Parent: AddressAnalyticsValidationError
@_spi(AdyenInternal) public case postalCodeEmpty
```
```javascript
// Parent: AddressAnalyticsValidationError
@_spi(AdyenInternal) public case postalCodePartial
```
```javascript
// Parent: AddressAnalyticsValidationError
@_spi(AdyenInternal) public var analyticsErrorCode: Swift.Int { get }
```
```javascript
// Parent: AddressAnalyticsValidationError
@_spi(AdyenInternal) public var analyticsErrorMessage: Swift.String { get }
```
```javascript
// Parent: AddressAnalyticsValidationError
@_spi(AdyenInternal) public static func __derived_enum_equals(_: Adyen.AddressAnalyticsValidationError, _: Adyen.AddressAnalyticsValidationError) -> Swift.Bool
```
```javascript
// Parent: AddressAnalyticsValidationError
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: AddressAnalyticsValidationError
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct BalanceChecker
```
```javascript
// Parent: BalanceChecker
@_spi(AdyenInternal) public enum Error : Equatable, Error, Hashable, LocalizedError, Sendable
```
```javascript
// Parent: BalanceChecker.Error
@_spi(AdyenInternal) public case unexpectedCurrencyCode
```
```javascript
// Parent: BalanceChecker.Error
@_spi(AdyenInternal) public case zeroBalance
```
```javascript
// Parent: BalanceChecker.Error
@_spi(AdyenInternal) public var errorDescription: Swift.String? { get }
```
```javascript
// Parent: BalanceChecker.Error
@_spi(AdyenInternal) public static func __derived_enum_equals(_: Adyen.BalanceChecker.Error, _: Adyen.BalanceChecker.Error) -> Swift.Bool
```
```javascript
// Parent: BalanceChecker.Error
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: BalanceChecker.Error
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
// Parent: BalanceChecker
@_spi(AdyenInternal) public struct Result
```
```javascript
// Parent: BalanceChecker.Result
@_spi(AdyenInternal) public let isBalanceEnough: Swift.Bool { get }
```
```javascript
// Parent: BalanceChecker.Result
@_spi(AdyenInternal) public let remainingBalanceAmount: Adyen.Amount { get }
```
```javascript
// Parent: BalanceChecker.Result
@_spi(AdyenInternal) public let amountToPay: Adyen.Amount { get }
```
```javascript
// Parent: BalanceChecker
@_spi(AdyenInternal) public init() -> Adyen.BalanceChecker
```
```javascript
// Parent: BalanceChecker
@_spi(AdyenInternal) public func check(balance: Adyen.Balance, isEnoughToPay: Adyen.Amount) throws -> Adyen.BalanceChecker.Result
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class BrazilSocialSecurityNumberValidator : CombinedValidator, StatusValidator, Validator
```
```javascript
// Parent: BrazilSocialSecurityNumberValidator
@_spi(AdyenInternal) public let firstValidator: any Adyen.Validator { get }
```
```javascript
// Parent: BrazilSocialSecurityNumberValidator
@_spi(AdyenInternal) public let secondValidator: any Adyen.Validator { get }
```
```javascript
// Parent: BrazilSocialSecurityNumberValidator
@_spi(AdyenInternal) public init() -> Adyen.BrazilSocialSecurityNumberValidator
```
```javascript
// Parent: BrazilSocialSecurityNumberValidator
@_spi(AdyenInternal) public func validate(_: Swift.String) -> Adyen.ValidationStatus
```
```javascript
// Parent: BrazilSocialSecurityNumberValidator
@_spi(AdyenInternal) public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
// Parent: Root
public enum ClientKeyError : Equatable, Error, Hashable, LocalizedError, Sendable
```
```javascript
// Parent: ClientKeyError
public case invalidClientKey
```
```javascript
// Parent: ClientKeyError
public var errorDescription: Swift.String? { get }
```
```javascript
// Parent: ClientKeyError
public static func __derived_enum_equals(_: Adyen.ClientKeyError, _: Adyen.ClientKeyError) -> Swift.Bool
```
```javascript
// Parent: ClientKeyError
public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
// Parent: ClientKeyError
public var hashValue: Swift.Int { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class ClientKeyValidator : Validator
```
```javascript
// Parent: ClientKeyValidator
@_spi(AdyenInternal) public init() -> Adyen.ClientKeyValidator
```
```javascript
// Parent: ClientKeyValidator
@_spi(AdyenInternal) override public init(regularExpression: Swift.String, minimumLength: Swift.Int? = $DEFAULT_ARG, maximumLength: Swift.Int? = $DEFAULT_ARG) -> Adyen.ClientKeyValidator
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct CountryCodeValidator : Validator
```
```javascript
// Parent: CountryCodeValidator
@_spi(AdyenInternal) public init() -> Adyen.CountryCodeValidator
```
```javascript
// Parent: CountryCodeValidator
@_spi(AdyenInternal) public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
// Parent: CountryCodeValidator
@_spi(AdyenInternal) public func maximumLength(for: Swift.String) -> Swift.Int
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public struct CurrencyCodeValidator : Validator
```
```javascript
// Parent: CurrencyCodeValidator
@_spi(AdyenInternal) public init() -> Adyen.CurrencyCodeValidator
```
```javascript
// Parent: CurrencyCodeValidator
@_spi(AdyenInternal) public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
// Parent: CurrencyCodeValidator
@_spi(AdyenInternal) public func maximumLength(for: Swift.String) -> Swift.Int
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class DateValidator : Validator
```
```javascript
// Parent: DateValidator
@_spi(AdyenInternal) public init(format: Adyen.DateValidator.Format) -> Adyen.DateValidator
```
```javascript
// Parent: DateValidator
@_spi(AdyenInternal) public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
// Parent: DateValidator
@_spi(AdyenInternal) public func maximumLength(for: Swift.String) -> Swift.Int
```
```javascript
// Parent: DateValidator
@_spi(AdyenInternal) public enum Format : Equatable, Hashable, RawRepresentable
```
```javascript
// Parent: DateValidator.Format
@_spi(AdyenInternal) public case kcpFormat
```
```javascript
// Parent: DateValidator.Format
@_spi(AdyenInternal) @inlinable public init(rawValue: Swift.String) -> Adyen.DateValidator.Format?
```
```javascript
// Parent: DateValidator.Format
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
// Parent: DateValidator.Format
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public class EmailValidator : Validator
```
```javascript
// Parent: EmailValidator
@_spi(AdyenInternal) public init() -> Adyen.EmailValidator
```
```javascript
// Parent: EmailValidator
@_spi(AdyenInternal) override public init(regularExpression: Swift.String, minimumLength: Swift.Int? = $DEFAULT_ARG, maximumLength: Swift.Int? = $DEFAULT_ARG) -> Adyen.EmailValidator
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class IBANValidator : Validator
```
```javascript
// Parent: IBANValidator
@_spi(AdyenInternal) public init() -> Adyen.IBANValidator
```
```javascript
// Parent: IBANValidator
@_spi(AdyenInternal) public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
// Parent: IBANValidator
@_spi(AdyenInternal) public func maximumLength(for: Swift.String) -> Swift.Int
```
```javascript
// Parent: Root
@_spi(AdyenInternal) open class LengthValidator : Validator
```
```javascript
// Parent: LengthValidator
@_spi(AdyenInternal) open var minimumLength: Swift.Int? { get set }
```
```javascript
// Parent: LengthValidator
@_spi(AdyenInternal) open var maximumLength: Swift.Int? { get set }
```
```javascript
// Parent: LengthValidator
@_spi(AdyenInternal) public init(minimumLength: Swift.Int? = $DEFAULT_ARG, maximumLength: Swift.Int? = $DEFAULT_ARG) -> Adyen.LengthValidator
```
```javascript
// Parent: LengthValidator
@_spi(AdyenInternal) public init(exactLength: Swift.Int) -> Adyen.LengthValidator
```
```javascript
// Parent: LengthValidator
@_spi(AdyenInternal) open func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
// Parent: LengthValidator
@_spi(AdyenInternal) public func maximumLength(for: Swift.String) -> Swift.Int
```
```javascript
// Parent: Root
@_spi(AdyenInternal) open class NumericStringValidator : Validator
```
```javascript
// Parent: NumericStringValidator
@_spi(AdyenInternal) override open func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
// Parent: NumericStringValidator
@_spi(AdyenInternal) override public init(minimumLength: Swift.Int? = $DEFAULT_ARG, maximumLength: Swift.Int? = $DEFAULT_ARG) -> Adyen.NumericStringValidator
```
```javascript
// Parent: NumericStringValidator
@_spi(AdyenInternal) override public init(exactLength: Swift.Int) -> Adyen.NumericStringValidator
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class PhoneNumberValidator : Validator
```
```javascript
// Parent: PhoneNumberValidator
@_spi(AdyenInternal) public init() -> Adyen.PhoneNumberValidator
```
```javascript
// Parent: PhoneNumberValidator
@_spi(AdyenInternal) override public init(regularExpression: Swift.String, minimumLength: Swift.Int? = $DEFAULT_ARG, maximumLength: Swift.Int? = $DEFAULT_ARG) -> Adyen.PhoneNumberValidator
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class PostalCodeValidator : StatusValidator, Validator
```
```javascript
// Parent: PostalCodeValidator
@_spi(AdyenInternal) public func validate(_: Swift.String) -> Adyen.ValidationStatus
```
```javascript
// Parent: PostalCodeValidator
@_spi(AdyenInternal) override public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
// Parent: PostalCodeValidator
@_spi(AdyenInternal) override public init(minimumLength: Swift.Int? = $DEFAULT_ARG, maximumLength: Swift.Int? = $DEFAULT_ARG) -> Adyen.PostalCodeValidator
```
```javascript
// Parent: PostalCodeValidator
@_spi(AdyenInternal) override public init(exactLength: Swift.Int) -> Adyen.PostalCodeValidator
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public class RegularExpressionValidator : Validator
```
```javascript
// Parent: RegularExpressionValidator
@_spi(AdyenInternal) public init(regularExpression: Swift.String, minimumLength: Swift.Int? = $DEFAULT_ARG, maximumLength: Swift.Int? = $DEFAULT_ARG) -> Adyen.RegularExpressionValidator
```
```javascript
// Parent: RegularExpressionValidator
@_spi(AdyenInternal) override public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
// Parent: RegularExpressionValidator
@_spi(AdyenInternal) override public func maximumLength(for: Swift.String) -> Swift.Int
```
```javascript
// Parent: RegularExpressionValidator
@_spi(AdyenInternal) override public init(minimumLength: Swift.Int? = $DEFAULT_ARG, maximumLength: Swift.Int? = $DEFAULT_ARG) -> Adyen.RegularExpressionValidator
```
```javascript
// Parent: RegularExpressionValidator
@_spi(AdyenInternal) override public init(exactLength: Swift.Int) -> Adyen.RegularExpressionValidator
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public enum ValidationStatus
```
```javascript
// Parent: ValidationStatus
@_spi(AdyenInternal) public case valid
```
```javascript
// Parent: ValidationStatus
@_spi(AdyenInternal) public case invalid(any Adyen.ValidationError)
```
```javascript
// Parent: ValidationStatus
@_spi(AdyenInternal) public var isValid: Swift.Bool { get }
```
```javascript
// Parent: ValidationStatus
@_spi(AdyenInternal) public var validationError: (any Adyen.ValidationError)? { get }
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol ValidationError<Self : Foundation.LocalizedError> : Error, LocalizedError, Sendable
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol Validator
```
```javascript
// Parent: Validator
@_spi(AdyenInternal) public func isValid<Self where Self : Adyen.Validator>(_: Swift.String) -> Swift.Bool
```
```javascript
// Parent: Validator
@_spi(AdyenInternal) public func maximumLength<Self where Self : Adyen.Validator>(for: Swift.String) -> Swift.Int
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol StatusValidator<Self : Adyen.Validator> : Validator
```
```javascript
// Parent: StatusValidator
@_spi(AdyenInternal) public func validate<Self where Self : Adyen.StatusValidator>(_: Swift.String) -> Adyen.ValidationStatus
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public func ||(_: any Adyen.Validator, _: any Adyen.Validator) -> any Adyen.Validator
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public func &&(_: any Adyen.Validator, _: any Adyen.Validator) -> any Adyen.Validator
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public protocol CombinedValidator<Self : Adyen.Validator> : Validator
```
```javascript
// Parent: CombinedValidator
@_spi(AdyenInternal) public var firstValidator: any Adyen.Validator { get }
```
```javascript
// Parent: CombinedValidator
@_spi(AdyenInternal) public var secondValidator: any Adyen.Validator { get }
```
```javascript
// Parent: CombinedValidator
@_spi(AdyenInternal) public func maximumLength<Self where Self : Adyen.CombinedValidator>(for: Swift.String) -> Swift.Int
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class ORValidator : CombinedValidator, Validator
```
```javascript
// Parent: ORValidator
@_spi(AdyenInternal) public let firstValidator: any Adyen.Validator { get }
```
```javascript
// Parent: ORValidator
@_spi(AdyenInternal) public let secondValidator: any Adyen.Validator { get }
```
```javascript
// Parent: ORValidator
@_spi(AdyenInternal) public init(firstValidator: any Adyen.Validator, secondValidator: any Adyen.Validator) -> Adyen.ORValidator
```
```javascript
// Parent: ORValidator
@_spi(AdyenInternal) public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
// Parent: Root
@_spi(AdyenInternal) public final class ANDValidator : CombinedValidator, Validator
```
```javascript
// Parent: ANDValidator
@_spi(AdyenInternal) public let firstValidator: any Adyen.Validator { get }
```
```javascript
// Parent: ANDValidator
@_spi(AdyenInternal) public let secondValidator: any Adyen.Validator { get }
```
```javascript
// Parent: ANDValidator
@_spi(AdyenInternal) public init(firstValidator: any Adyen.Validator, secondValidator: any Adyen.Validator) -> Adyen.ANDValidator
```
```javascript
// Parent: ANDValidator
@_spi(AdyenInternal) public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
// Parent: Root
@objc open dynamic class Bundle : AdyenCompatible, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSObjectProtocol, Sendable
```
```javascript
// Parent: Bundle
@_spi(AdyenInternal) public typealias AdyenBase = Foundation.Bundle
```
```javascript
// Parent: Bundle
@_spi(AdyenInternal) public enum Adyen
```
```javascript
// Parent: Bundle.Adyen
@_spi(AdyenInternal) public static var localizedEditCopy: Swift.String { get }
```
```javascript
// Parent: Bundle.Adyen
@_spi(AdyenInternal) public static var localizedDoneCopy: Swift.String { get }
```
```javascript
// Parent: Bundle
@_spi(AdyenInternal) public static let coreInternalResources: Foundation.Bundle { get }
```
```javascript
// Parent: Root
@objc open dynamic class UIViewController : AdyenCompatible, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSExtensionRequestHandling, NSObjectProtocol, Sendable, UIActivityItemsConfigurationProviding, UIAppearanceContainer, UIContentContainer, UIFocusEnvironment, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UIStateRestoring, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring, ViewControllerPresenter
```
```javascript
// Parent: UIViewController
@_spi(AdyenInternal) public func presentViewController(_: UIKit.UIViewController, animated: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: UIViewController
@_spi(AdyenInternal) public func dismissViewController(animated: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: Root
@objc open dynamic class UIImageView : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityContentSizeCategoryImageAdjusting, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: UIImageView
@_spi(AdyenInternal) @discardableResult public func load(url: Foundation.URL, using: any Adyen.ImageLoading, placeholder: UIKit.UIImage? = $DEFAULT_ARG) -> any Adyen.AdyenCancellable
```
```javascript
// Parent: UIImageView
@_spi(AdyenInternal) public convenience init(style: Adyen.ImageStyle) -> UIKit.UIImageView
```
```javascript
// Parent: Root
@objc open dynamic class NSLayoutConstraint : AdyenCompatible, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSObjectProtocol
```
```javascript
// Parent: NSLayoutConstraint
@_spi(AdyenInternal) public typealias AdyenBase = UIKit.NSLayoutConstraint
```
```javascript
// Parent: Root
@objc public dynamic enum NSTextAlignment : AdyenCompatible, Equatable, Hashable, RawRepresentable, Sendable
```
```javascript
// Parent: NSTextAlignment
@_spi(AdyenInternal) public typealias AdyenBase = UIKit.NSTextAlignment
```
```javascript
// Parent: Root
public enum Result<Success, Failure where Failure : Swift.Error> : Equatable, Hashable, Sendable
```
```javascript
// Parent: Result
@_spi(AdyenInternal) public func handle<Success, Failure where Failure : Swift.Error>(success: (Success) -> Swift.Void, failure: (Failure) -> Swift.Void) -> Swift.Void
```
```javascript
// Parent: Root
public struct String : AdyenCompatible, BidirectionalCollection, CVarArg, CodingKeyRepresentable, Collection, Comparable, CustomDebugStringConvertible, CustomReflectable, CustomStringConvertible, Decodable, Encodable, Equatable, ExpressibleByExtendedGraphemeClusterLiteral, ExpressibleByStringInterpolation, ExpressibleByStringLiteral, ExpressibleByUnicodeScalarLiteral, Hashable, LosslessStringConvertible, MirrorPath, RangeReplaceableCollection, Sendable, Sequence, StringProtocol, TextOutputStream, TextOutputStreamable, Transferable
```
```javascript
// Parent: String
@_spi(AdyenInternal) public enum Adyen
```
```javascript
// Parent: String.Adyen
@_spi(AdyenInternal) public static let securedString: Swift.String { get }
```
```javascript
// Parent: String
@_spi(AdyenInternal) public typealias AdyenBase = Swift.String
```
```javascript
// Parent: Root
public enum Optional<Wrapped> : AdyenCompatible, Commands, CustomDebugStringConvertible, CustomReflectable, CustomizableToolbarContent, Decodable, DecodableWithConfiguration, Encodable, EncodableWithConfiguration, Equatable, ExpressibleByNilLiteral, Gesture, Hashable, Sendable, TableColumnContent, TableRowContent, ToolbarContent, View
```
```javascript
// Parent: Optional
@_spi(AdyenInternal) public typealias AdyenBase = Wrapped?
```
```javascript
// Parent: Root
public struct Double : AdditiveArithmetic, AdyenCompatible, Animatable, BinaryFloatingPoint, CVarArg, Comparable, CustomDebugStringConvertible, CustomReflectable, CustomStringConvertible, Decodable, Encodable, Equatable, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, FloatingPoint, Hashable, LosslessStringConvertible, Numeric, SIMDScalar, Sendable, SignedNumeric, Strideable, TextOutputStreamable, VectorArithmetic
```
```javascript
// Parent: Double
@_spi(AdyenInternal) public typealias AdyenBase = Swift.Double
```
```javascript
// Parent: Root
@objc open dynamic class UIButton : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityContentSizeCategoryImageAdjusting, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UIContextMenuInteractionDelegate, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UISpringLoadedInteractionSupporting, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: UIButton
@_spi(AdyenInternal) public convenience init(style: Adyen.ButtonStyle) -> UIKit.UIButton
```
```javascript
// Parent: Root
@objc open dynamic class UIColor : CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSCopying, NSItemProviderReading, NSItemProviderWriting, NSObjectProtocol, NSSecureCoding, Sendable
```
```javascript
// Parent: UIColor
public enum Adyen
```
```javascript
// Parent: UIColor.Adyen
public static var dimmBackground: UIKit.UIColor { get }
```
```javascript
// Parent: UIColor.Adyen
public static var componentBackground: UIKit.UIColor { get }
```
```javascript
// Parent: UIColor.Adyen
public static var secondaryComponentBackground: UIKit.UIColor { get }
```
```javascript
// Parent: UIColor.Adyen
public static var componentLabel: UIKit.UIColor { get }
```
```javascript
// Parent: UIColor.Adyen
public static var componentSecondaryLabel: UIKit.UIColor { get }
```
```javascript
// Parent: UIColor.Adyen
public static var componentTertiaryLabel: UIKit.UIColor { get }
```
```javascript
// Parent: UIColor.Adyen
public static var componentQuaternaryLabel: UIKit.UIColor { get }
```
```javascript
// Parent: UIColor.Adyen
public static var componentPlaceholderText: UIKit.UIColor { get }
```
```javascript
// Parent: UIColor.Adyen
public static var componentSeparator: UIKit.UIColor { get }
```
```javascript
// Parent: UIColor.Adyen
public static var componentLoadingMessageColor: UIKit.UIColor { get }
```
```javascript
// Parent: UIColor.Adyen
public static var paidSectionFooterTitleColor: UIKit.UIColor { get }
```
```javascript
// Parent: UIColor.Adyen
public static var paidSectionFooterTitleBackgroundColor: UIKit.UIColor { get }
```
```javascript
// Parent: UIColor.Adyen
public static let defaultBlue: UIKit.UIColor { get }
```
```javascript
// Parent: UIColor.Adyen
public static let defaultRed: UIKit.UIColor { get }
```
```javascript
// Parent: UIColor.Adyen
public static let errorRed: UIKit.UIColor { get }
```
```javascript
// Parent: UIColor.Adyen
public static let lightGray: UIKit.UIColor { get }
```
```javascript
// Parent: UIColor.Adyen
public static let green40: UIKit.UIColor { get }
```
```javascript
// Parent: Root
@objc open dynamic class UIFont : AdyenCompatible, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSCopying, NSObjectProtocol, NSSecureCoding, Sendable
```
```javascript
// Parent: UIFont
@_spi(AdyenInternal) public typealias AdyenBase = UIKit.UIFont
```
```javascript
// Parent: Root
@objc open dynamic class UILabel : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UIContentSizeCategoryAdjusting, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UILetterformAwareAdjusting, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: UILabel
@_spi(AdyenInternal) public convenience init(style: Adyen.TextStyle) -> UIKit.UILabel
```
```javascript
// Parent: Root
@objc open dynamic class UIProgressView : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: UIProgressView
@_spi(AdyenInternal) public convenience init(style: Adyen.ProgressViewStyle) -> UIKit.UIProgressView
```
```javascript
// Parent: Root
@objc open dynamic class UIView : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: UIView
@_spi(AdyenInternal) public func accessibilityMarkAsSelected(_: Swift.Bool) -> Swift.Void
```
```javascript
// Parent: Root
@objc open dynamic class UILayoutGuide : CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, UIPopoverPresentationControllerSourceItem
```
```javascript
// Parent: Root
@objc open dynamic class UIResponder : AdyenCompatible, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSObjectProtocol, Sendable, UIActivityItemsConfigurationProviding, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UIUserActivityRestoring
```
```javascript
// Parent: UIResponder
@_spi(AdyenInternal) public typealias AdyenBase = UIKit.UIResponder
```
```javascript
// Parent: Root
public struct URL : AdyenCompatible, CustomDebugStringConvertible, CustomStringConvertible, Decodable, Encodable, Equatable, Hashable, ReferenceConvertible, Sendable, Transferable
```
```javascript
// Parent: URL
@_spi(AdyenInternal) public typealias AdyenBase = Foundation.URL
```
```javascript
// Parent: Root
@objc open dynamic class UISearchBar : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UIBarPositioning, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UILookToDictateCapable, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITextInputTraits, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
// Parent: UISearchBar
@_spi(AdyenInternal) public static func prominent(placeholder: Swift.String?, backgroundColor: UIKit.UIColor, delegate: any UIKit.UISearchBarDelegate) -> UIKit.UISearchBar
```
