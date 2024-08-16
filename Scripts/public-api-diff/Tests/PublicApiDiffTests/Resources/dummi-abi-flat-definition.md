```javascript
import AdyenNetworking
```
```javascript
import Contacts
```
```javascript
import Darwin
```
```javascript
import DeveloperToolsSupport
```
```javascript
import Foundation
```
```javascript
import Foundation
```
```javascript
import Foundation
```
```javascript
import Foundation
```
```javascript
import PassKit
```
```javascript
import QuartzCore
```
```javascript
import SwiftOnoneSupport
```
```javascript
import SwiftUI
```
```javascript
import UIKit
```
```javascript
import WebKit
```
```javascript
import _Concurrency
```
```javascript
import _StringProcessing
```
```javascript
import _SwiftConcurrencyShims
```
```javascript
@_spi(AdyenInternal) public enum AnalyticsFlavor
```
```javascript
@_spi(AdyenInternal) public case components(type: Adyen.PaymentMethodType)
```
```javascript
@_spi(AdyenInternal) public case dropIn(type: Swift.String, paymentMethods: [Swift.String])
```
```javascript
@_spi(AdyenInternal) public var value: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public protocol AnalyticsProviderProtocol
```
```javascript
@_spi(AdyenInternal) public var checkoutAttemptId: Swift.String? { get }
```
```javascript
@_spi(AdyenInternal) public func sendInitialAnalytics<Self where Self : Adyen.AnalyticsProviderProtocol>(with: Adyen.AnalyticsFlavor, additionalFields: Adyen.AdditionalAnalyticsFields?) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func add<Self where Self : Adyen.AnalyticsProviderProtocol>(info: Adyen.AnalyticsEventInfo) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func add<Self where Self : Adyen.AnalyticsProviderProtocol>(log: Adyen.AnalyticsEventLog) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func add<Self where Self : Adyen.AnalyticsProviderProtocol>(error: Adyen.AnalyticsEventError) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public final class AnalyticsForSession
```
```javascript
@_spi(AdyenInternal) public static var sessionId: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public protocol AnalyticsEvent<Self : Swift.Encodable> : Encodable
```
```javascript
@_spi(AdyenInternal) public var timestamp: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public var component: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public var id: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public enum AnalyticsEventTarget : Encodable, Equatable, Hashable, RawRepresentable
```
```javascript
@_spi(AdyenInternal) public case cardNumber
```
```javascript
@_spi(AdyenInternal) public case expiryDate
```
```javascript
@_spi(AdyenInternal) public case securityCode
```
```javascript
@_spi(AdyenInternal) public case holderName
```
```javascript
@_spi(AdyenInternal) public case dualBrand
```
```javascript
@_spi(AdyenInternal) public case boletoSocialSecurityNumber
```
```javascript
@_spi(AdyenInternal) public case taxNumber
```
```javascript
@_spi(AdyenInternal) public case authPassWord
```
```javascript
@_spi(AdyenInternal) public case addressStreet
```
```javascript
@_spi(AdyenInternal) public case addressHouseNumber
```
```javascript
@_spi(AdyenInternal) public case addressCity
```
```javascript
@_spi(AdyenInternal) public case addressPostalCode
```
```javascript
@_spi(AdyenInternal) public case issuerList
```
```javascript
@_spi(AdyenInternal) public case listSearch
```
```javascript
@_spi(AdyenInternal) public init(rawValue: Swift.String) -> Adyen.AnalyticsEventTarget?
```
```javascript
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
public struct AnalyticsConfiguration
```
```javascript
public var isEnabled: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) public var context: Adyen.AnalyticsContext { get set }
```
```javascript
public init() -> Adyen.AnalyticsConfiguration
```
```javascript
@_spi(AdyenInternal) public struct AdditionalAnalyticsFields
```
```javascript
@_spi(AdyenInternal) public let amount: Adyen.Amount? { get }
```
```javascript
@_spi(AdyenInternal) public let sessionId: Swift.String? { get }
```
```javascript
@_spi(AdyenInternal) public init(amount: Adyen.Amount?, sessionId: Swift.String?) -> Adyen.AdditionalAnalyticsFields
```
```javascript
@_spi(AdyenInternal) public enum AnalyticsConstants
```
```javascript
@_spi(AdyenInternal) public enum ValidationErrorCodes
```
```javascript
@_spi(AdyenInternal) public static let cardNumberEmpty: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public static let cardNumberPartial: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public static let cardLuhnCheckFailed: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public static let cardUnsupported: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public static let expiryDateEmpty: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public static let expiryDatePartial: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public static let cardExpired: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public static let expiryDateTooFar: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public static let securityCodeEmpty: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public static let securityCodePartial: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public static let holderNameEmpty: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public static let brazilSSNEmpty: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public static let brazilSSNPartial: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public static let postalCodeEmpty: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public static let postalCodePartial: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public static let kcpPasswordEmpty: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public static let kcpPasswordPartial: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public static let kcpFieldEmpty: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public static let kcpFieldPartial: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public struct AnalyticsContext
```
```javascript
@_spi(AdyenInternal) public init(version: Swift.String = $DEFAULT_ARG, platform: Adyen.AnalyticsContext.Platform = $DEFAULT_ARG) -> Adyen.AnalyticsContext
```
```javascript
@_spi(AdyenInternal) public enum Platform : Equatable, Hashable, RawRepresentable
```
```javascript
@_spi(AdyenInternal) public case iOS
```
```javascript
@_spi(AdyenInternal) public case reactNative
```
```javascript
@_spi(AdyenInternal) public case flutter
```
```javascript
@_spi(AdyenInternal) public init(rawValue: Swift.String) -> Adyen.AnalyticsContext.Platform?
```
```javascript
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public struct AnalyticsEventError : AnalyticsEvent, Encodable
```
```javascript
@_spi(AdyenInternal) public var id: Swift.String { get set }
```
```javascript
@_spi(AdyenInternal) public var timestamp: Swift.Int { get set }
```
```javascript
@_spi(AdyenInternal) public var component: Swift.String { get set }
```
```javascript
@_spi(AdyenInternal) public var type: Adyen.AnalyticsEventError.ErrorType { get set }
```
```javascript
@_spi(AdyenInternal) public var code: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var message: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public enum ErrorType : Encodable, Equatable, Hashable, RawRepresentable
```
```javascript
@_spi(AdyenInternal) public case network
```
```javascript
@_spi(AdyenInternal) public case implementation
```
```javascript
@_spi(AdyenInternal) public case internal
```
```javascript
@_spi(AdyenInternal) public case api
```
```javascript
@_spi(AdyenInternal) public case sdk
```
```javascript
@_spi(AdyenInternal) public case thirdParty
```
```javascript
@_spi(AdyenInternal) public case generic
```
```javascript
@_spi(AdyenInternal) public init(rawValue: Swift.String) -> Adyen.AnalyticsEventError.ErrorType?
```
```javascript
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public init(component: Swift.String, type: Adyen.AnalyticsEventError.ErrorType) -> Adyen.AnalyticsEventError
```
```javascript
@_spi(AdyenInternal) public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public struct AnalyticsEventInfo : AnalyticsEvent, Encodable
```
```javascript
@_spi(AdyenInternal) public var id: Swift.String { get set }
```
```javascript
@_spi(AdyenInternal) public var timestamp: Swift.Int { get set }
```
```javascript
@_spi(AdyenInternal) public var component: Swift.String { get set }
```
```javascript
@_spi(AdyenInternal) public var type: Adyen.AnalyticsEventInfo.InfoType { get set }
```
```javascript
@_spi(AdyenInternal) public var target: Adyen.AnalyticsEventTarget? { get set }
```
```javascript
@_spi(AdyenInternal) public var isStoredPaymentMethod: Swift.Bool? { get set }
```
```javascript
@_spi(AdyenInternal) public var brand: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var issuer: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var validationErrorCode: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var validationErrorMessage: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public enum InfoType : Encodable, Equatable, Hashable, RawRepresentable
```
```javascript
@_spi(AdyenInternal) public case selected
```
```javascript
@_spi(AdyenInternal) public case focus
```
```javascript
@_spi(AdyenInternal) public case unfocus
```
```javascript
@_spi(AdyenInternal) public case validationError
```
```javascript
@_spi(AdyenInternal) public case rendered
```
```javascript
@_spi(AdyenInternal) public case input
```
```javascript
@_spi(AdyenInternal) public init(rawValue: Swift.String) -> Adyen.AnalyticsEventInfo.InfoType?
```
```javascript
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public init(component: Swift.String, type: Adyen.AnalyticsEventInfo.InfoType) -> Adyen.AnalyticsEventInfo
```
```javascript
@_spi(AdyenInternal) public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public struct AnalyticsEventLog : AnalyticsEvent, Encodable
```
```javascript
@_spi(AdyenInternal) public var id: Swift.String { get set }
```
```javascript
@_spi(AdyenInternal) public var timestamp: Swift.Int { get set }
```
```javascript
@_spi(AdyenInternal) public var component: Swift.String { get set }
```
```javascript
@_spi(AdyenInternal) public var type: Adyen.AnalyticsEventLog.LogType { get set }
```
```javascript
@_spi(AdyenInternal) public var subType: Adyen.AnalyticsEventLog.LogSubType? { get set }
```
```javascript
@_spi(AdyenInternal) public var target: Adyen.AnalyticsEventTarget? { get set }
```
```javascript
@_spi(AdyenInternal) public var message: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public enum LogType : Encodable, Equatable, Hashable, RawRepresentable
```
```javascript
@_spi(AdyenInternal) public case action
```
```javascript
@_spi(AdyenInternal) public case submit
```
```javascript
@_spi(AdyenInternal) public case redirect
```
```javascript
@_spi(AdyenInternal) public case threeDS2
```
```javascript
@_spi(AdyenInternal) public init(rawValue: Swift.String) -> Adyen.AnalyticsEventLog.LogType?
```
```javascript
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public enum LogSubType : Encodable, Equatable, Hashable, RawRepresentable
```
```javascript
@_spi(AdyenInternal) public case threeDS2
```
```javascript
@_spi(AdyenInternal) public case redirect
```
```javascript
@_spi(AdyenInternal) public case voucher
```
```javascript
@_spi(AdyenInternal) public case await
```
```javascript
@_spi(AdyenInternal) public case qrCode
```
```javascript
@_spi(AdyenInternal) public case bankTransfer
```
```javascript
@_spi(AdyenInternal) public case sdk
```
```javascript
@_spi(AdyenInternal) public case fingerprintSent
```
```javascript
@_spi(AdyenInternal) public case fingerprintComplete
```
```javascript
@_spi(AdyenInternal) public case challengeDataSent
```
```javascript
@_spi(AdyenInternal) public case challengeDisplayed
```
```javascript
@_spi(AdyenInternal) public case challengeComplete
```
```javascript
@_spi(AdyenInternal) public init(rawValue: Swift.String) -> Adyen.AnalyticsEventLog.LogSubType?
```
```javascript
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public init(component: Swift.String, type: Adyen.AnalyticsEventLog.LogType, subType: Adyen.AnalyticsEventLog.LogSubType? = $DEFAULT_ARG) -> Adyen.AnalyticsEventLog
```
```javascript
@_spi(AdyenInternal) public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public protocol AnalyticsValidationError<Self : Adyen.ValidationError> : Error, LocalizedError, Sendable, ValidationError
```
```javascript
@_spi(AdyenInternal) public var analyticsErrorCode: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public var analyticsErrorMessage: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public struct LocalizationKey
```
```javascript
@_spi(AdyenInternal) public static let submitButton: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let submitButtonFormatted: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cancelButton: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let dismissButton: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let removeButton: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let errorTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let errorUnknown: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let validationAlertTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let paymentMethodsOtherMethods: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let paymentMethodsStoredMethods: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let paymentMethodsPaidMethods: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let paymentMethodsTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let paymentMethodRemoveButton: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let paymentRefusedMessage: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let sepaIbanItemTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let sepaIbanItemInvalid: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let sepaNameItemTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let sepaNameItemPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let sepaConsentLabel: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let sepaNameItemInvalid: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardStoreDetailsButton: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardNameItemTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardNameItemPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardNameItemInvalid: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardNumberItemTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardNumberItemPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardNumberItemInvalid: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardExpiryItemTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardExpiryItemTitleOptional: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardExpiryItemPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardExpiryItemInvalid: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardCvcItemInvalid: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardCvcItemTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardCvcItemPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardStoredTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardStoredMessage: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardStoredExpires: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardNumberItemUnsupportedBrand: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardNumberItemUnknownBrand: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let dropInStoredTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let dropInPreselectedOpenAllTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let continueTo: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let continueTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let phoneNumberTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let phoneNumberInvalid: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let telephonePrefix: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let phoneNumberPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardCvcItemPlaceholderDigits: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let emailItemTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let emailItemPlaceHolder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let emailItemInvalid: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let moreOptions: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let applePayTotal: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let mbwayConfirmPayment: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let awaitWaitForConfirmation: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let blikConfirmPayment: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let blikInvalid: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let blikCode: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let blikHelp: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let blikPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let preauthorizeWith: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let confirmPreauthorization: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardCvcItemTitleOptional: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let confirmPurchase: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let lastName: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let firstName: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardPinTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let missingField: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardApplyGiftcard: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let voucherCollectionInstitutionNumber: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let voucherMerchantName: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let voucherExpirationDate: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let voucherPaymentReferenceLabel: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let voucherShopperName: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let buttonCopy: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let voucherIntroduction: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let voucherReadInstructions: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let voucherSaveImage: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let voucherFinish: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardBrazilSSNPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let amount: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let voucherEntity: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let pixInstructions: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let pixExpirationLabel: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let pixCopyButton: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let pixInstructionsCopiedMessage: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let billingAddressSectionTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let billingAddressPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let deliveryAddressSectionTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let deliveryAddressPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let countryFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let countryFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let countryFieldInvalid: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let addressFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let addressFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let streetFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let streetFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let houseNumberFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let houseNumberFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cityFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cityFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cityTownFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cityTownFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let postalCodeFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let postalCodeFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let zipCodeFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let zipCodeFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let stateFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let stateFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let selectStateFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let stateOrProvinceFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let stateOrProvinceFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let selectStateOrProvinceFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let provinceOrTerritoryFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let provinceOrTerritoryFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let apartmentSuiteFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let apartmentSuiteFieldPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let errorFeedbackEmptyField: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let errorFeedbackIncorrectFormat: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let fieldTitleOptional: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let boletobancarioBtnLabel: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let boletoSendCopyToEmail: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let boletoPersonalDetails: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let boletoSocialSecurityNumber: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let boletoDownloadPdf: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let giftcardCurrencyError: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let giftcardNoBalance: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let giftcardRemoveTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let giftcardRemoveMessage: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let giftcardPaymentMethodTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let partialPaymentRemainingBalance: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let partialPaymentPayRemainingAmount: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardTaxNumberLabel: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardTaxNumberPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardTaxNumberInvalid: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardEncryptedPasswordLabel: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardEncryptedPasswordPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardEncryptedPasswordInvalid: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardTaxNumberLabelShort: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let affirmDeliveryAddressToggleTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let voucherShopperReference: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let voucherAlternativeReference: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardInstallmentsNumberOfInstallments: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardInstallmentsOneTime: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardInstallmentsTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardInstallmentsRevolving: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardInstallmentsMonthsAndPrice: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardInstallmentsMonths: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cardInstallmentsPlan: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let bacsHolderNameFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let bacsBankAccountNumberFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let bacsBankLocationIdFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let bacsLegalConsentToggleTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let bacsAmountConsentToggleTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let bacsSpecifiedAmountConsentToggleTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let bacsHolderNameFieldInvalidMessage: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let bacsBankAccountNumberFieldInvalidMessage: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let bacsBankLocationIdFieldInvalidMessage: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let bacsPaymentButtonTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let bacsDownloadMandate: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let achBankAccountTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let achAccountHolderNameFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let achAccountHolderNameFieldInvalid: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let achAccountNumberFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let achAccountNumberFieldInvalid: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let achAccountLocationFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let achAccountLocationFieldInvalid: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let selectFieldTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let onlineBankingTermsAndConditions: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let qrCodeInstructionMessage: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let qrCodeTimerExpirationMessage: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let paybybankSubtitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let paybybankTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let searchPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let upiModeSelection: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let UPIVpaValidationMessage: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let UPIQrcodeGenerationMessage: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let UPIQrcodeTimerMessage: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let upiCollectConfirmPayment: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let upiVpaWaitingMessage: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let QRCodeGenerateQRCode: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let UPIQRCodeInstructions: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let UPIFirstTabTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let UPISecondTabTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let UPICollectDropdownLabel: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let UPICollectFieldLabel: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let UPIErrorNoAppSelected: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cashAppPayTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let cashAppPayCashtag: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let twintNoAppsInstalledMessage: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DARegistrationTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DABiometrics: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DAFaceID: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DATouchID: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DAOpticID: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DARegistrationDescription: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DARegistrationFirstInfo: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DARegistrationSecondInfo: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DARegistrationThirdInfo: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DARegistrationPositiveButton: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DARegistrationNegativeButton: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DAApprovalTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DAApprovalDescription: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DAApprovalPositiveButton: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DAApprovalNegativeButton: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DAApprovalActionSheetTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DAApprovalActionSheetFallback: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DAApprovalActionSheetRemove: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DAApprovalRemoveAlertTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DAApprovalRemoveAlertDescription: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DAApprovalRemoveAlertPositiveButton: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DAApprovalRemoveAlertNegativeButton: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DAApprovalErrorTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DAApprovalErrorMessage: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DAApprovalErrorButtonTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DARegistrationErrorTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DARegistrationErrorMessage: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DARegistrationErrorButtonTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DADeletionConfirmationTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DADeletionConfirmationMessage: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let threeds2DADeletionConfirmationButtonTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let pickerSearchEmptyTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let pickerSearchEmptySubtitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let addressLookupSearchPlaceholder: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let addressLookupSearchEmptyTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let addressLookupSearchEmptySubtitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let addressLookupSearchEmptyTitleNoResults: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let addressLookupSearchEmptySubtitleNoResults: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let addressLookupItemValidationFailureMessageEmpty: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let addressLookupItemValidationFailureMessageInvalid: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let addressLookupSearchManualEntryItemTitle: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public static let accessibilityLastFourDigits: Adyen.LocalizationKey { get }
```
```javascript
@_spi(AdyenInternal) public init(key: Swift.String) -> Adyen.LocalizationKey
```
```javascript
public protocol AdyenContextAware<Self : AnyObject>
```
```javascript
public var context: Adyen.AdyenContext { get }
```
```javascript
public var payment: Adyen.Payment? { get }
```
```javascript
public struct APIContext : AnyAPIContext
```
```javascript
public var queryParameters: [Foundation.URLQueryItem] { get }
```
```javascript
public let headers: [Swift.String : Swift.String] { get }
```
```javascript
public let environment: any AdyenNetworking.AnyAPIEnvironment { get }
```
```javascript
public let clientKey: Swift.String { get }
```
```javascript
public init(environment: any AdyenNetworking.AnyAPIEnvironment, clientKey: Swift.String) throws -> Adyen.APIContext
```
```javascript
@_spi(AdyenInternal) public enum AnalyticsEnvironment : AnyAPIEnvironment, Equatable, Hashable, RawRepresentable
```
```javascript
@_spi(AdyenInternal) public case test
```
```javascript
@_spi(AdyenInternal) public case liveEurope
```
```javascript
@_spi(AdyenInternal) public case liveAustralia
```
```javascript
@_spi(AdyenInternal) public case liveUnitedStates
```
```javascript
@_spi(AdyenInternal) public case liveApse
```
```javascript
@_spi(AdyenInternal) public case liveIndia
```
```javascript
@_spi(AdyenInternal) public case beta
```
```javascript
@_spi(AdyenInternal) public case local
```
```javascript
@_spi(AdyenInternal) public var baseURL: Foundation.URL { get }
```
```javascript
@_spi(AdyenInternal) public init(rawValue: Swift.String) -> Adyen.AnalyticsEnvironment?
```
```javascript
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
public struct Environment : AnyAPIEnvironment, Equatable
```
```javascript
public var baseURL: Foundation.URL { get set }
```
```javascript
public static let test: Adyen.Environment { get }
```
```javascript
@_spi(AdyenInternal) public static let beta: Adyen.Environment { get }
```
```javascript
@_spi(AdyenInternal) public static let local: Adyen.Environment { get }
```
```javascript
public static let live: Adyen.Environment { get }
```
```javascript
public static let liveEurope: Adyen.Environment { get }
```
```javascript
public static let liveAustralia: Adyen.Environment { get }
```
```javascript
public static let liveUnitedStates: Adyen.Environment { get }
```
```javascript
public static let liveApse: Adyen.Environment { get }
```
```javascript
public static let liveIndia: Adyen.Environment { get }
```
```javascript
@_spi(AdyenInternal) public var isLive: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) public static func __derived_struct_equals(_: Adyen.Environment, _: Adyen.Environment) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public protocol APIRequest<Self : AdyenNetworking.Request, Self.ErrorResponseType == Adyen.APIError> : Encodable, Request
```
```javascript
@_spi(AdyenInternal) public struct AppleWalletPassRequest : APIRequest, Encodable, Request
```
```javascript
@_spi(AdyenInternal) public typealias ResponseType = Adyen.AppleWalletPassResponse
```
```javascript
@_spi(AdyenInternal) public let path: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public var counter: Swift.UInt { get set }
```
```javascript
@_spi(AdyenInternal) public let headers: [Swift.String : Swift.String] { get }
```
```javascript
@_spi(AdyenInternal) public let queryParameters: [Foundation.URLQueryItem] { get }
```
```javascript
@_spi(AdyenInternal) public let method: AdyenNetworking.HTTPMethod { get }
```
```javascript
@_spi(AdyenInternal) public let platform: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public let passToken: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public init(passToken: Swift.String) -> Adyen.AppleWalletPassRequest
```
```javascript
@_spi(AdyenInternal) public enum CodingKeys : CodingKey, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, Sendable
```
```javascript
@_spi(AdyenInternal) public case platform
```
```javascript
@_spi(AdyenInternal) public case passToken
```
```javascript
@_spi(AdyenInternal) public static func __derived_enum_equals(_: Adyen.AppleWalletPassRequest.CodingKeys, _: Adyen.AppleWalletPassRequest.CodingKeys) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public init(stringValue: Swift.String) -> Adyen.AppleWalletPassRequest.CodingKeys?
```
```javascript
@_spi(AdyenInternal) public init(intValue: Swift.Int) -> Adyen.AppleWalletPassRequest.CodingKeys?
```
```javascript
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public var intValue: Swift.Int? { get }
```
```javascript
@_spi(AdyenInternal) public var stringValue: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public typealias ErrorResponseType = Adyen.APIError
```
```javascript
@_spi(AdyenInternal) public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public struct ClientKeyRequest : APIRequest, Encodable, Request
```
```javascript
@_spi(AdyenInternal) public typealias ResponseType = Adyen.ClientKeyResponse
```
```javascript
@_spi(AdyenInternal) public var path: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public let clientKey: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public var counter: Swift.UInt { get set }
```
```javascript
@_spi(AdyenInternal) public let headers: [Swift.String : Swift.String] { get }
```
```javascript
@_spi(AdyenInternal) public let queryParameters: [Foundation.URLQueryItem] { get }
```
```javascript
@_spi(AdyenInternal) public let method: AdyenNetworking.HTTPMethod { get }
```
```javascript
@_spi(AdyenInternal) public init(clientKey: Swift.String) -> Adyen.ClientKeyRequest
```
```javascript
@_spi(AdyenInternal) public typealias ErrorResponseType = Adyen.APIError
```
```javascript
@_spi(AdyenInternal) public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public struct OrderStatusRequest : APIRequest, Encodable, Request
```
```javascript
@_spi(AdyenInternal) public typealias ResponseType = Adyen.OrderStatusResponse
```
```javascript
@_spi(AdyenInternal) public var path: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public var counter: Swift.UInt { get set }
```
```javascript
@_spi(AdyenInternal) public let headers: [Swift.String : Swift.String] { get }
```
```javascript
@_spi(AdyenInternal) public let queryParameters: [Foundation.URLQueryItem] { get }
```
```javascript
@_spi(AdyenInternal) public let method: AdyenNetworking.HTTPMethod { get }
```
```javascript
@_spi(AdyenInternal) public let orderData: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public init(orderData: Swift.String) -> Adyen.OrderStatusRequest
```
```javascript
@_spi(AdyenInternal) public typealias ErrorResponseType = Adyen.APIError
```
```javascript
@_spi(AdyenInternal) public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public struct PaymentStatusRequest : APIRequest, Encodable, Request
```
```javascript
@_spi(AdyenInternal) public typealias ResponseType = Adyen.PaymentStatusResponse
```
```javascript
@_spi(AdyenInternal) public let path: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public var counter: Swift.UInt { get set }
```
```javascript
@_spi(AdyenInternal) public let headers: [Swift.String : Swift.String] { get }
```
```javascript
@_spi(AdyenInternal) public let queryParameters: [Foundation.URLQueryItem] { get }
```
```javascript
@_spi(AdyenInternal) public let method: AdyenNetworking.HTTPMethod { get }
```
```javascript
@_spi(AdyenInternal) public let paymentData: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public init(paymentData: Swift.String) -> Adyen.PaymentStatusRequest
```
```javascript
@_spi(AdyenInternal) public typealias ErrorResponseType = Adyen.APIError
```
```javascript
@_spi(AdyenInternal) public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public struct AppleWalletPassResponse : Decodable, Response
```
```javascript
@_spi(AdyenInternal) public let passData: Foundation.Data { get }
```
```javascript
@_spi(AdyenInternal) public init(passBase64String: Swift.String) throws -> Adyen.AppleWalletPassResponse
```
```javascript
@_spi(AdyenInternal) public init(from: any Swift.Decoder) throws -> Adyen.AppleWalletPassResponse
```
```javascript
@_spi(AdyenInternal) public struct ClientKeyResponse : Decodable, Response
```
```javascript
@_spi(AdyenInternal) public let cardPublicKey: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public init(from: any Swift.Decoder) throws -> Adyen.ClientKeyResponse
```
```javascript
@_spi(AdyenInternal) public struct OrderStatusResponse : Decodable, Response
```
```javascript
@_spi(AdyenInternal) public let remainingAmount: Adyen.Amount { get }
```
```javascript
@_spi(AdyenInternal) public let paymentMethods: [Adyen.OrderPaymentMethod]? { get }
```
```javascript
@_spi(AdyenInternal) public init(remainingAmount: Adyen.Amount, paymentMethods: [Adyen.OrderPaymentMethod]?) -> Adyen.OrderStatusResponse
```
```javascript
@_spi(AdyenInternal) public init(from: any Swift.Decoder) throws -> Adyen.OrderStatusResponse
```
```javascript
@_spi(AdyenInternal) public struct OrderPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
@_spi(AdyenInternal) public var name: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
@_spi(AdyenInternal) public let lastFour: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public let type: Adyen.PaymentMethodType { get }
```
```javascript
@_spi(AdyenInternal) public let transactionLimit: Adyen.Amount? { get }
```
```javascript
@_spi(AdyenInternal) public let amount: Adyen.Amount { get }
```
```javascript
@_spi(AdyenInternal) public init(lastFour: Swift.String, type: Adyen.PaymentMethodType, transactionLimit: Adyen.Amount?, amount: Adyen.Amount) -> Adyen.OrderPaymentMethod
```
```javascript
@_spi(AdyenInternal) public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public init(from: any Swift.Decoder) throws -> Adyen.OrderPaymentMethod
```
```javascript
@_spi(AdyenInternal) public enum PaymentResultCode : Decodable, Equatable, Hashable, RawRepresentable
```
```javascript
@_spi(AdyenInternal) public case authorised
```
```javascript
@_spi(AdyenInternal) public case refused
```
```javascript
@_spi(AdyenInternal) public case pending
```
```javascript
@_spi(AdyenInternal) public case cancelled
```
```javascript
@_spi(AdyenInternal) public case error
```
```javascript
@_spi(AdyenInternal) public case received
```
```javascript
@_spi(AdyenInternal) public case redirectShopper
```
```javascript
@_spi(AdyenInternal) public case identifyShopper
```
```javascript
@_spi(AdyenInternal) public case challengeShopper
```
```javascript
@_spi(AdyenInternal) public init(rawValue: Swift.String) -> Adyen.PaymentResultCode?
```
```javascript
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public struct PaymentStatusResponse : Decodable, Response
```
```javascript
@_spi(AdyenInternal) public let payload: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public let resultCode: Adyen.PaymentResultCode { get }
```
```javascript
@_spi(AdyenInternal) public init(from: any Swift.Decoder) throws -> Adyen.PaymentStatusResponse
```
```javascript
public final class AdyenContext : PaymentAware
```
```javascript
public let apiContext: Adyen.APIContext { get }
```
```javascript
public var payment: Adyen.Payment? { get }
```
```javascript
@_spi(AdyenInternal) public let analyticsProvider: (any Adyen.AnalyticsProviderProtocol)? { get }
```
```javascript
public convenience init(apiContext: Adyen.APIContext, payment: Adyen.Payment?, analyticsConfiguration: Adyen.AnalyticsConfiguration = $DEFAULT_ARG) -> Adyen.AdyenContext
```
```javascript
@_spi(AdyenInternal) public func update(payment: Adyen.Payment?) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public enum PersonalInformation : Equatable
```
```javascript
@_spi(AdyenInternal) public case firstName
```
```javascript
@_spi(AdyenInternal) public case lastName
```
```javascript
@_spi(AdyenInternal) public case email
```
```javascript
@_spi(AdyenInternal) public case phone
```
```javascript
@_spi(AdyenInternal) public case address
```
```javascript
@_spi(AdyenInternal) public case deliveryAddress
```
```javascript
@_spi(AdyenInternal) public case custom(any Adyen.FormItemInjector)
```
```javascript
@_spi(AdyenInternal) public static func ==(_: Adyen.PersonalInformation, _: Adyen.PersonalInformation) -> Swift.Bool
```
```javascript
public class AbstractPersonalInformationComponent : AdyenContextAware, Component, LoadingComponent, PartialPaymentOrderAware, PaymentAware, PaymentComponent, PaymentMethodAware, PresentableComponent, TrackableComponent, ViewControllerDelegate, ViewControllerPresenter
```
```javascript
public typealias Configuration = Adyen.PersonalInformationConfiguration
```
```javascript
@_spi(AdyenInternal) public let context: Adyen.AdyenContext { get }
```
```javascript
public let paymentMethod: any Adyen.PaymentMethod { get }
```
```javascript
public weak var delegate: (any Adyen.PaymentComponentDelegate)? { get set }
```
```javascript
public lazy var viewController: UIKit.UIViewController { get set }
```
```javascript
public let requiresModalPresentation: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) public var configuration: Adyen.AbstractPersonalInformationComponent.Configuration { get set }
```
```javascript
@_spi(AdyenInternal) public init(paymentMethod: any Adyen.PaymentMethod, context: Adyen.AdyenContext, fields: [Adyen.PersonalInformation], configuration: Adyen.AbstractPersonalInformationComponent.Configuration) -> Adyen.AbstractPersonalInformationComponent
```
```javascript
@_spi(AdyenInternal) public var firstNameItem: Adyen.FormTextInputItem? { get }
```
```javascript
@_spi(AdyenInternal) public var lastNameItem: Adyen.FormTextInputItem? { get }
```
```javascript
@_spi(AdyenInternal) public var emailItem: Adyen.FormTextInputItem? { get }
```
```javascript
@_spi(AdyenInternal) public var addressItem: Adyen.FormAddressPickerItem? { get }
```
```javascript
@_spi(AdyenInternal) public var deliveryAddressItem: Adyen.FormAddressPickerItem? { get }
```
```javascript
@_spi(AdyenInternal) public var phoneItem: Adyen.FormPhoneNumberItem? { get }
```
```javascript
@_spi(AdyenInternal) public func submitButtonTitle() -> Swift.String
```
```javascript
@_spi(AdyenInternal) public func createPaymentDetails() throws -> any Adyen.PaymentMethodDetails
```
```javascript
@_spi(AdyenInternal) public func phoneExtensions() -> [Adyen.PhoneExtension]
```
```javascript
@_spi(AdyenInternal) public func addressViewModelBuilder() -> any Adyen.AddressViewModelBuilder
```
```javascript
@_spi(AdyenInternal) public func showValidation() -> Swift.Void
```
```javascript
public func stopLoading() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func presentViewController(_: UIKit.UIViewController, animated: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func dismissViewController(animated: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func viewWillAppear(viewController: UIKit.UIViewController) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func viewDidLoad(viewController: UIKit.UIViewController) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public protocol FormItemInjector
```
```javascript
@_spi(AdyenInternal) public func inject<Self where Self : Adyen.FormItemInjector>(into: Adyen.FormViewController) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public struct CustomFormItemInjector<T where T : Adyen.FormItem> : FormItemInjector
```
```javascript
@_spi(AdyenInternal) public init<T where T : Adyen.FormItem>(item: T) -> Adyen.CustomFormItemInjector<T>
```
```javascript
@_spi(AdyenInternal) public func inject<T where T : Adyen.FormItem>(into: Adyen.FormViewController) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public final class AlreadyPaidPaymentComponent : AdyenContextAware, Component, PartialPaymentOrderAware, PaymentComponent, PaymentMethodAware
```
```javascript
@_spi(AdyenInternal) public let context: Adyen.AdyenContext { get }
```
```javascript
@_spi(AdyenInternal) public let paymentMethod: any Adyen.PaymentMethod { get }
```
```javascript
@_spi(AdyenInternal) public weak var delegate: (any Adyen.PaymentComponentDelegate)? { get set }
```
```javascript
@_spi(AdyenInternal) public init(paymentMethod: any Adyen.PaymentMethod, context: Adyen.AdyenContext) -> Adyen.AlreadyPaidPaymentComponent
```
```javascript
public protocol AnyCashAppPayConfiguration
```
```javascript
public var redirectURL: Foundation.URL { get }
```
```javascript
public var referenceId: Swift.String? { get }
```
```javascript
public var showsStorePaymentMethodField: Swift.Bool { get }
```
```javascript
public var storePaymentMethod: Swift.Bool { get }
```
```javascript
public struct ActionComponentData
```
```javascript
public let details: any Adyen.AdditionalDetails { get }
```
```javascript
public let paymentData: Swift.String? { get }
```
```javascript
public init(details: any Adyen.AdditionalDetails, paymentData: Swift.String?) -> Adyen.ActionComponentData
```
```javascript
public protocol AnyBasicComponentConfiguration<Self : Adyen.Localizable> : Localizable
```
```javascript
public protocol AnyPersonalInformationConfiguration<Self : Adyen.AnyBasicComponentConfiguration> : AnyBasicComponentConfiguration, Localizable
```
```javascript
public var shopperInformation: Adyen.PrefilledShopperInformation? { get }
```
```javascript
public struct BasicComponentConfiguration : AnyBasicComponentConfiguration, Localizable
```
```javascript
public var style: Adyen.FormComponentStyle { get set }
```
```javascript
public var localizationParameters: Adyen.LocalizationParameters? { get set }
```
```javascript
public init(style: Adyen.FormComponentStyle = $DEFAULT_ARG, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG) -> Adyen.BasicComponentConfiguration
```
```javascript
public struct PersonalInformationConfiguration : AnyBasicComponentConfiguration, AnyPersonalInformationConfiguration, Localizable
```
```javascript
public var style: Adyen.FormComponentStyle { get set }
```
```javascript
public var shopperInformation: Adyen.PrefilledShopperInformation? { get set }
```
```javascript
public var localizationParameters: Adyen.LocalizationParameters? { get set }
```
```javascript
public init(style: Adyen.FormComponentStyle = $DEFAULT_ARG, shopperInformation: Adyen.PrefilledShopperInformation? = $DEFAULT_ARG, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG) -> Adyen.PersonalInformationConfiguration
```
```javascript
public enum PartialPaymentError : Equatable, Error, Hashable, LocalizedError, Sendable
```
```javascript
public case zeroRemainingAmount
```
```javascript
public case missingOrderData
```
```javascript
public case notSupportedForComponent
```
```javascript
public var errorDescription: Swift.String? { get }
```
```javascript
public static func __derived_enum_equals(_: Adyen.PartialPaymentError, _: Adyen.PartialPaymentError) -> Swift.Bool
```
```javascript
public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
public var hashValue: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public final class PresentableComponentWrapper : AdyenContextAware, Cancellable, Component, FinalizableComponent, LoadingComponent, PresentableComponent
```
```javascript
@_spi(AdyenInternal) public var apiContext: Adyen.APIContext { get }
```
```javascript
@_spi(AdyenInternal) public var context: Adyen.AdyenContext { get }
```
```javascript
@_spi(AdyenInternal) public let viewController: UIKit.UIViewController { get }
```
```javascript
@_spi(AdyenInternal) public let component: any Adyen.Component { get }
```
```javascript
@_spi(AdyenInternal) public var requiresModalPresentation: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) public var navBarType: Adyen.NavigationBarType { get set }
```
```javascript
@_spi(AdyenInternal) public init(component: any Adyen.Component, viewController: UIKit.UIViewController, navBarType: Adyen.NavigationBarType = $DEFAULT_ARG) -> Adyen.PresentableComponentWrapper
```
```javascript
@_spi(AdyenInternal) public func didCancel() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func didFinalize(with: Swift.Bool, completion: (() -> Swift.Void)?) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func stopLoading() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public protocol InstallmentConfigurationAware<Self : Adyen.AdyenSessionAware> : AdyenSessionAware
```
```javascript
@_spi(AdyenInternal) public var installmentConfiguration: Adyen.InstallmentConfiguration? { get }
```
```javascript
public struct InstallmentOptions : Decodable, Encodable, Equatable
```
```javascript
@_spi(AdyenInternal) public let regularInstallmentMonths: [Swift.UInt] { get }
```
```javascript
@_spi(AdyenInternal) public let includesRevolving: Swift.Bool { get }
```
```javascript
public init(monthValues: [Swift.UInt], includesRevolving: Swift.Bool) -> Adyen.InstallmentOptions
```
```javascript
public init(maxInstallmentMonth: Swift.UInt, includesRevolving: Swift.Bool) -> Adyen.InstallmentOptions
```
```javascript
@_spi(AdyenInternal) public init(from: any Swift.Decoder) throws -> Adyen.InstallmentOptions
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public static func __derived_struct_equals(_: Adyen.InstallmentOptions, _: Adyen.InstallmentOptions) -> Swift.Bool
```
```javascript
public struct InstallmentConfiguration : Decodable
```
```javascript
@_spi(AdyenInternal) public let defaultOptions: Adyen.InstallmentOptions? { get }
```
```javascript
@_spi(AdyenInternal) public let cardBasedOptions: [Adyen.CardType : Adyen.InstallmentOptions]? { get }
```
```javascript
@_spi(AdyenInternal) public var showInstallmentAmount: Swift.Bool { get set }
```
```javascript
public init(cardBasedOptions: [Adyen.CardType : Adyen.InstallmentOptions], defaultOptions: Adyen.InstallmentOptions, showInstallmentAmount: Swift.Bool = $DEFAULT_ARG) -> Adyen.InstallmentConfiguration
```
```javascript
public init(cardBasedOptions: [Adyen.CardType : Adyen.InstallmentOptions], showInstallmentAmount: Swift.Bool = $DEFAULT_ARG) -> Adyen.InstallmentConfiguration
```
```javascript
public init(defaultOptions: Adyen.InstallmentOptions, showInstallmentAmount: Swift.Bool = $DEFAULT_ARG) -> Adyen.InstallmentConfiguration
```
```javascript
@_spi(AdyenInternal) public init(from: any Swift.Decoder) throws -> Adyen.InstallmentConfiguration
```
```javascript
@_spi(AdyenInternal) public protocol PaymentInitiable
```
```javascript
@_spi(AdyenInternal) public func initiatePayment<Self where Self : Adyen.PaymentInitiable>() -> Swift.Void
```
```javascript
public final class InstantPaymentComponent : AdyenContextAware, Component, PartialPaymentOrderAware, PaymentComponent, PaymentInitiable, PaymentMethodAware
```
```javascript
@_spi(AdyenInternal) public let context: Adyen.AdyenContext { get }
```
```javascript
public let paymentData: Adyen.PaymentComponentData { get }
```
```javascript
public let paymentMethod: any Adyen.PaymentMethod { get }
```
```javascript
public weak var delegate: (any Adyen.PaymentComponentDelegate)? { get set }
```
```javascript
public init(paymentMethod: any Adyen.PaymentMethod, context: Adyen.AdyenContext, paymentData: Adyen.PaymentComponentData) -> Adyen.InstantPaymentComponent
```
```javascript
public init(paymentMethod: any Adyen.PaymentMethod, context: Adyen.AdyenContext, order: Adyen.PartialPaymentOrder?) -> Adyen.InstantPaymentComponent
```
```javascript
public func initiatePayment() -> Swift.Void
```
```javascript
public struct InstantPaymentDetails : Details, Encodable, OpaqueEncodable, PaymentMethodDetails
```
```javascript
@_spi(AdyenInternal) public var checkoutAttemptId: Swift.String? { get set }
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public init(type: Adyen.PaymentMethodType) -> Adyen.InstantPaymentDetails
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public final class StoredPaymentMethodComponent : AdyenContextAware, Component, PartialPaymentOrderAware, PaymentAware, PaymentComponent, PaymentMethodAware, PresentableComponent, TrackableComponent
```
```javascript
public var configuration: Adyen.StoredPaymentMethodComponent.Configuration { get set }
```
```javascript
public let context: Adyen.AdyenContext { get }
```
```javascript
public var paymentMethod: any Adyen.PaymentMethod { get }
```
```javascript
public weak var delegate: (any Adyen.PaymentComponentDelegate)? { get set }
```
```javascript
public init(paymentMethod: any Adyen.StoredPaymentMethod, context: Adyen.AdyenContext, configuration: Adyen.StoredPaymentMethodComponent.Configuration = $DEFAULT_ARG) -> Adyen.StoredPaymentMethodComponent
```
```javascript
public lazy var viewController: UIKit.UIViewController { get set }
```
```javascript
public struct Configuration : AnyBasicComponentConfiguration, Localizable
```
```javascript
public var localizationParameters: Adyen.LocalizationParameters? { get set }
```
```javascript
public init(localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG) -> Adyen.StoredPaymentMethodComponent.Configuration
```
```javascript
public struct StoredPaymentDetails : Details, Encodable, OpaqueEncodable, PaymentMethodDetails
```
```javascript
@_spi(AdyenInternal) public var checkoutAttemptId: Swift.String? { get set }
```
```javascript
public init(paymentMethod: any Adyen.StoredPaymentMethod) -> Adyen.StoredPaymentDetails
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public protocol ActionComponent<Self : Adyen.Component> : AdyenContextAware, Component
```
```javascript
public var delegate: (any Adyen.ActionComponentDelegate)? { get set }
```
```javascript
public protocol ActionComponentDelegate<Self : AnyObject>
```
```javascript
public func didOpenExternalApplication<Self where Self : Adyen.ActionComponentDelegate>(component: any Adyen.ActionComponent) -> Swift.Void
```
```javascript
public func didProvide<Self where Self : Adyen.ActionComponentDelegate>(_: Adyen.ActionComponentData, from: any Adyen.ActionComponent) -> Swift.Void
```
```javascript
public func didComplete<Self where Self : Adyen.ActionComponentDelegate>(from: any Adyen.ActionComponent) -> Swift.Void
```
```javascript
public func didFail<Self where Self : Adyen.ActionComponentDelegate>(with: any Swift.Error, from: any Adyen.ActionComponent) -> Swift.Void
```
```javascript
public func didOpenExternalApplication<Self where Self : Adyen.ActionComponentDelegate>(component: any Adyen.ActionComponent) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public protocol AdyenSessionAware
```
```javascript
@_spi(AdyenInternal) public var isSession: Swift.Bool { get }
```
```javascript
public protocol AnyDropInComponent<Self : Adyen.PresentableComponent> : AdyenContextAware, Component, PresentableComponent
```
```javascript
public var delegate: (any Adyen.DropInComponentDelegate)? { get set }
```
```javascript
public func reload<Self where Self : Adyen.AnyDropInComponent>(with: Adyen.PartialPaymentOrder, _: Adyen.PaymentMethods) throws -> Swift.Void
```
```javascript
public protocol Component<Self : Adyen.AdyenContextAware> : AdyenContextAware
```
```javascript
public func finalizeIfNeeded<Self where Self : Adyen.Component>(with: Swift.Bool, completion: (() -> Swift.Void)?) -> Swift.Void
```
```javascript
public func cancelIfNeeded<Self where Self : Adyen.Component>() -> Swift.Void
```
```javascript
public func stopLoadingIfNeeded<Self where Self : Adyen.Component>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public var _isDropIn: Swift.Bool { get set }
```
```javascript
public protocol FinalizableComponent<Self : Adyen.Component> : AdyenContextAware, Component
```
```javascript
public func didFinalize<Self where Self : Adyen.FinalizableComponent>(with: Swift.Bool, completion: (() -> Swift.Void)?) -> Swift.Void
```
```javascript
public protocol Details<Self : Adyen.OpaqueEncodable> : Encodable, OpaqueEncodable
```
```javascript
public protocol PaymentMethodDetails<Self : Adyen.Details> : Details, Encodable, OpaqueEncodable
```
```javascript
@_spi(AdyenInternal) public var checkoutAttemptId: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var checkoutAttemptId: Swift.String? { get set }
```
```javascript
public protocol AdditionalDetails<Self : Adyen.Details> : Details, Encodable, OpaqueEncodable
```
```javascript
public protocol DeviceDependent
```
```javascript
public static func isDeviceSupported<Self where Self : Adyen.DeviceDependent>() -> Swift.Bool
```
```javascript
public protocol DropInComponentDelegate<Self : AnyObject>
```
```javascript
public func didSubmit<Self where Self : Adyen.DropInComponentDelegate>(_: Adyen.PaymentComponentData, from: any Adyen.PaymentComponent, in: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
public func didFail<Self where Self : Adyen.DropInComponentDelegate>(with: any Swift.Error, from: any Adyen.PaymentComponent, in: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
public func didProvide<Self where Self : Adyen.DropInComponentDelegate>(_: Adyen.ActionComponentData, from: any Adyen.ActionComponent, in: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
public func didComplete<Self where Self : Adyen.DropInComponentDelegate>(from: any Adyen.ActionComponent, in: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
public func didFail<Self where Self : Adyen.DropInComponentDelegate>(with: any Swift.Error, from: any Adyen.ActionComponent, in: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
public func didOpenExternalApplication<Self where Self : Adyen.DropInComponentDelegate>(component: any Adyen.ActionComponent, in: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
public func didFail<Self where Self : Adyen.DropInComponentDelegate>(with: any Swift.Error, from: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
public func didCancel<Self where Self : Adyen.DropInComponentDelegate>(component: any Adyen.PaymentComponent, from: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
public func didCancel<Self where Self : Adyen.DropInComponentDelegate>(component: any Adyen.PaymentComponent, from: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
public func didOpenExternalApplication<Self where Self : Adyen.DropInComponentDelegate>(component: any Adyen.ActionComponent, in: any Adyen.AnyDropInComponent) -> Swift.Void
```
```javascript
public protocol ComponentLoader<Self : Adyen.LoadingComponent> : LoadingComponent
```
```javascript
public func startLoading<Self where Self : Adyen.ComponentLoader>(for: any Adyen.PaymentComponent) -> Swift.Void
```
```javascript
public protocol LoadingComponent
```
```javascript
public func stopLoading<Self where Self : Adyen.LoadingComponent>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public protocol PartialPaymentComponent<Self : Adyen.PaymentComponent> : AdyenContextAware, Component, PartialPaymentOrderAware, PaymentComponent, PaymentMethodAware
```
```javascript
@_spi(AdyenInternal) public var partialPaymentDelegate: (any Adyen.PartialPaymentDelegate)? { get set }
```
```javascript
@_spi(AdyenInternal) public var readyToSubmitComponentDelegate: (any Adyen.ReadyToSubmitPaymentComponentDelegate)? { get set }
```
```javascript
public protocol PartialPaymentDelegate<Self : AnyObject>
```
```javascript
public func checkBalance<Self where Self : Adyen.PartialPaymentDelegate>(with: Adyen.PaymentComponentData, component: any Adyen.Component, completion: (Swift.Result<Adyen.Balance, any Swift.Error>) -> Swift.Void) -> Swift.Void
```
```javascript
public func requestOrder<Self where Self : Adyen.PartialPaymentDelegate>(for: any Adyen.Component, completion: (Swift.Result<Adyen.PartialPaymentOrder, any Swift.Error>) -> Swift.Void) -> Swift.Void
```
```javascript
public func cancelOrder<Self where Self : Adyen.PartialPaymentDelegate>(_: Adyen.PartialPaymentOrder, component: any Adyen.Component) -> Swift.Void
```
```javascript
public protocol PartialPaymentOrderAware
```
```javascript
public var order: Adyen.PartialPaymentOrder? { get set }
```
```javascript
@_spi(AdyenInternal) public var order: Adyen.PartialPaymentOrder? { get set }
```
```javascript
public protocol PaymentAware
```
```javascript
public var payment: Adyen.Payment? { get }
```
```javascript
public protocol PaymentMethodAware
```
```javascript
public var paymentMethod: any Adyen.PaymentMethod { get }
```
```javascript
public protocol PaymentComponent<Self : Adyen.Component, Self : Adyen.PartialPaymentOrderAware, Self : Adyen.PaymentMethodAware> : AdyenContextAware, Component, PartialPaymentOrderAware, PaymentMethodAware
```
```javascript
public var delegate: (any Adyen.PaymentComponentDelegate)? { get set }
```
```javascript
@_spi(AdyenInternal) public func submit<Self where Self : Adyen.PaymentComponent>(data: Adyen.PaymentComponentData, component: (any Adyen.PaymentComponent)? = $DEFAULT_ARG) -> Swift.Void
```
```javascript
public protocol PaymentComponentDelegate<Self : AnyObject>
```
```javascript
public func didSubmit<Self where Self : Adyen.PaymentComponentDelegate>(_: Adyen.PaymentComponentData, from: any Adyen.PaymentComponent) -> Swift.Void
```
```javascript
public func didFail<Self where Self : Adyen.PaymentComponentDelegate>(with: any Swift.Error, from: any Adyen.PaymentComponent) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public protocol PaymentComponentBuilder<Self : Adyen.AdyenContextAware> : AdyenContextAware
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.StoredCardPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: any Adyen.StoredPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.StoredBCMCPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.StoredACHDirectDebitPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.CardPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.BCMCPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.IssuerListPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.SEPADirectDebitPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.BACSDirectDebitPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.ACHDirectDebitPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.ApplePayPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.WeChatPayPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.QiwiWalletPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.MBWayPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.BLIKPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.DokuPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.EContextPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.GiftCardPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.MealVoucherPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.BoletoPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.AffirmPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.AtomePaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.OnlineBankingPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.UPIPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.CashAppPayPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.StoredCashAppPayPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: Adyen.TwintPaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.PaymentComponentBuilder>(paymentMethod: any Adyen.PaymentMethod) -> (any Adyen.PaymentComponent)?
```
```javascript
public protocol PaymentMethod<Self : Swift.Decodable, Self : Swift.Encodable> : Decodable, Encodable
```
```javascript
public var type: Adyen.PaymentMethodType { get }
```
```javascript
public var name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
@_spi(AdyenInternal) public func defaultDisplayInformation<Self where Self : Adyen.PaymentMethod>(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
@_spi(AdyenInternal) public func buildComponent<Self where Self : Adyen.PaymentMethod>(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func buildComponent<Self where Self : Adyen.PaymentMethod>(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func displayInformation<Self where Self : Adyen.PaymentMethod>(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
@_spi(AdyenInternal) public func defaultDisplayInformation<Self where Self : Adyen.PaymentMethod>(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
public protocol PartialPaymentMethod<Self : Adyen.PaymentMethod> : Decodable, Encodable, PaymentMethod
```
```javascript
public protocol StoredPaymentMethod<Self : Adyen.PaymentMethod> : Decodable, Encodable, PaymentMethod
```
```javascript
public var identifier: Swift.String { get }
```
```javascript
public var supportedShopperInteractions: [Adyen.ShopperInteraction] { get }
```
```javascript
@_spi(AdyenInternal) public func ==(_: any Adyen.StoredPaymentMethod, _: any Adyen.StoredPaymentMethod) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func !=(_: any Adyen.StoredPaymentMethod, _: any Adyen.StoredPaymentMethod) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func ==(_: any Adyen.PaymentMethod, _: any Adyen.PaymentMethod) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func !=(_: any Adyen.PaymentMethod, _: any Adyen.PaymentMethod) -> Swift.Bool
```
```javascript
public protocol Localizable
```
```javascript
public var localizationParameters: Adyen.LocalizationParameters? { get set }
```
```javascript
public protocol Cancellable<Self : AnyObject>
```
```javascript
public func didCancel<Self where Self : Adyen.Cancellable>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public protocol AnyNavigationBar<Self : UIKit.UIView>
```
```javascript
@_spi(AdyenInternal) public var onCancelHandler: (() -> Swift.Void)? { get set }
```
```javascript
@_spi(AdyenInternal) public enum NavigationBarType
```
```javascript
@_spi(AdyenInternal) public case regular
```
```javascript
@_spi(AdyenInternal) public case custom(any Adyen.AnyNavigationBar)
```
```javascript
public protocol PresentableComponent<Self : Adyen.Component> : AdyenContextAware, Component
```
```javascript
public var requiresModalPresentation: Swift.Bool { get }
```
```javascript
public var viewController: UIKit.UIViewController { get }
```
```javascript
@_spi(AdyenInternal) public var navBarType: Adyen.NavigationBarType { get }
```
```javascript
@_spi(AdyenInternal) public var requiresModalPresentation: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) public var navBarType: Adyen.NavigationBarType { get }
```
```javascript
public protocol PresentationDelegate<Self : AnyObject>
```
```javascript
public func present<Self where Self : Adyen.PresentationDelegate>(component: any Adyen.PresentableComponent) -> Swift.Void
```
```javascript
public protocol ReadyToSubmitPaymentComponentDelegate<Self : AnyObject>
```
```javascript
public func showConfirmation<Self where Self : Adyen.ReadyToSubmitPaymentComponentDelegate>(for: Adyen.InstantPaymentComponent, with: Adyen.PartialPaymentOrder?) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public protocol StorePaymentMethodFieldAware<Self : Adyen.AdyenSessionAware> : AdyenSessionAware
```
```javascript
@_spi(AdyenInternal) public var showStorePaymentMethodField: Swift.Bool? { get }
```
```javascript
@_spi(AdyenInternal) public protocol SessionStoredPaymentMethodsDelegate<Self : Adyen.AdyenSessionAware, Self : Adyen.StoredPaymentMethodsDelegate> : AdyenSessionAware, StoredPaymentMethodsDelegate
```
```javascript
@_spi(AdyenInternal) public var showRemovePaymentMethodButton: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) public func disable<Self where Self : Adyen.SessionStoredPaymentMethodsDelegate>(storedPaymentMethod: any Adyen.StoredPaymentMethod, dropInComponent: any Adyen.AnyDropInComponent, completion: Adyen.Completion<Swift.Bool>) -> Swift.Void
```
```javascript
public protocol StoredPaymentMethodsDelegate<Self : AnyObject>
```
```javascript
public func disable<Self where Self : Adyen.StoredPaymentMethodsDelegate>(storedPaymentMethod: any Adyen.StoredPaymentMethod, completion: Adyen.Completion<Swift.Bool>) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public protocol TrackableComponent<Self : Adyen.Component> : AdyenContextAware, Component
```
```javascript
@_spi(AdyenInternal) public var analyticsFlavor: Adyen.AnalyticsFlavor { get }
```
```javascript
@_spi(AdyenInternal) public func sendInitialAnalytics<Self where Self : Adyen.TrackableComponent>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func sendDidLoadEvent<Self where Self : Adyen.TrackableComponent>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func viewDidLoad<Self where Self : Adyen.TrackableComponent, Self : Adyen.ViewControllerDelegate>(viewController: UIKit.UIViewController) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func sendInitialAnalytics<Self where Self : Adyen.TrackableComponent>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public var analyticsFlavor: Adyen.AnalyticsFlavor { get }
```
```javascript
@_spi(AdyenInternal) public func sendDidLoadEvent<Self where Self : Adyen.PaymentMethodAware, Self : Adyen.TrackableComponent>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public protocol ViewControllerPresenter<Self : AnyObject>
```
```javascript
@_spi(AdyenInternal) public func presentViewController<Self where Self : Adyen.ViewControllerPresenter>(_: UIKit.UIViewController, animated: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func dismissViewController<Self where Self : Adyen.ViewControllerPresenter>(animated: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public class WeakReferenceViewControllerPresenter : ViewControllerPresenter
```
```javascript
@_spi(AdyenInternal) public init(_: any Adyen.ViewControllerPresenter) -> Adyen.WeakReferenceViewControllerPresenter
```
```javascript
@_spi(AdyenInternal) public func presentViewController(_: UIKit.UIViewController, animated: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func dismissViewController(animated: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public struct APIError : Decodable, Error, ErrorResponse, LocalizedError, Response, Sendable
```
```javascript
@_spi(AdyenInternal) public let status: Swift.Int? { get }
```
```javascript
@_spi(AdyenInternal) public let errorCode: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public let errorMessage: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public let type: Adyen.APIErrorType { get }
```
```javascript
@_spi(AdyenInternal) public var errorDescription: Swift.String? { get }
```
```javascript
@_spi(AdyenInternal) public init(from: any Swift.Decoder) throws -> Adyen.APIError
```
```javascript
@_spi(AdyenInternal) public enum APIErrorType : Decodable, Equatable, Hashable, RawRepresentable
```
```javascript
@_spi(AdyenInternal) public case internal
```
```javascript
@_spi(AdyenInternal) public case validation
```
```javascript
@_spi(AdyenInternal) public case security
```
```javascript
@_spi(AdyenInternal) public case configuration
```
```javascript
@_spi(AdyenInternal) public case urlError
```
```javascript
@_spi(AdyenInternal) public case noInternet
```
```javascript
@_spi(AdyenInternal) public case sessionExpired
```
```javascript
@_spi(AdyenInternal) public init(rawValue: Swift.String) -> Adyen.APIErrorType?
```
```javascript
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
public enum AppleWalletError : Equatable, Error, Hashable, LocalizedError, Sendable
```
```javascript
public case failedToAddToAppleWallet
```
```javascript
public static func __derived_enum_equals(_: Adyen.AppleWalletError, _: Adyen.AppleWalletError) -> Swift.Bool
```
```javascript
public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
public var hashValue: Swift.Int { get }
```
```javascript
public enum ComponentError : Equatable, Error, Hashable, Sendable
```
```javascript
public case cancelled
```
```javascript
public case paymentMethodNotSupported
```
```javascript
public static func __derived_enum_equals(_: Adyen.ComponentError, _: Adyen.ComponentError) -> Swift.Bool
```
```javascript
public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
public var hashValue: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public struct UnknownError : Error, LocalizedError, Sendable
```
```javascript
@_spi(AdyenInternal) public var errorDescription: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public init(errorDescription: Swift.String? = $DEFAULT_ARG) -> Adyen.UnknownError
```
```javascript
public enum CardType : Decodable, Encodable, Equatable, Hashable, RawRepresentable
```
```javascript
public case accel
```
```javascript
public case alphaBankBonusMasterCard
```
```javascript
public case alphaBankBonusVISA
```
```javascript
public case argencard
```
```javascript
public case americanExpress
```
```javascript
public case bcmc
```
```javascript
public case bijenkorfCard
```
```javascript
public case cabal
```
```javascript
public case carteBancaire
```
```javascript
public case cencosud
```
```javascript
public case chequeDejeneur
```
```javascript
public case chinaUnionPay
```
```javascript
public case codensa
```
```javascript
public case creditUnion24
```
```javascript
public case dankort
```
```javascript
public case dankortVISA
```
```javascript
public case diners
```
```javascript
public case discover
```
```javascript
public case elo
```
```javascript
public case forbrugsforeningen
```
```javascript
public case hiper
```
```javascript
public case hipercard
```
```javascript
public case jcb
```
```javascript
public case karenMillen
```
```javascript
public case kcp
```
```javascript
public case koreanLocalCard
```
```javascript
public case laser
```
```javascript
public case maestro
```
```javascript
public case maestroUK
```
```javascript
public case masterCard
```
```javascript
public case mir
```
```javascript
public case naranja
```
```javascript
public case netplus
```
```javascript
public case nyce
```
```javascript
public case oasis
```
```javascript
public case pulse
```
```javascript
public case shopping
```
```javascript
public case solo
```
```javascript
public case star
```
```javascript
public case troy
```
```javascript
public case uatp
```
```javascript
public case visa
```
```javascript
public case warehouse
```
```javascript
public case other(named: Swift.String)
```
```javascript
public init(rawValue: Swift.String) -> Adyen.CardType
```
```javascript
public var rawValue: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public var name: Swift.String { get }
```
```javascript
public typealias RawValue = Swift.String
```
```javascript
@_spi(AdyenInternal) public func matches(cardNumber: Swift.String) -> Swift.Bool
```
```javascript
public struct DisplayInformation : Equatable
```
```javascript
public let title: Swift.String { get }
```
```javascript
public let subtitle: Swift.String? { get }
```
```javascript
@_spi(AdyenInternal) public let logoName: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public let disclosureText: Swift.String? { get }
```
```javascript
@_spi(AdyenInternal) public let footnoteText: Swift.String? { get }
```
```javascript
@_spi(AdyenInternal) public let accessibilityLabel: Swift.String? { get }
```
```javascript
public init(title: Swift.String, subtitle: Swift.String?, logoName: Swift.String, disclosureText: Swift.String? = $DEFAULT_ARG, footnoteText: Swift.String? = $DEFAULT_ARG, accessibilityLabel: Swift.String? = $DEFAULT_ARG) -> Adyen.DisplayInformation
```
```javascript
public static func __derived_struct_equals(_: Adyen.DisplayInformation, _: Adyen.DisplayInformation) -> Swift.Bool
```
```javascript
public struct MerchantCustomDisplayInformation
```
```javascript
public let title: Swift.String { get }
```
```javascript
public let subtitle: Swift.String? { get }
```
```javascript
public init(title: Swift.String, subtitle: Swift.String? = $DEFAULT_ARG) -> Adyen.MerchantCustomDisplayInformation
```
```javascript
public enum ShopperInteraction : Decodable, Encodable, Equatable, Hashable, RawRepresentable
```
```javascript
public case shopperPresent
```
```javascript
public case shopperNotPresent
```
```javascript
public init(rawValue: Swift.String) -> Adyen.ShopperInteraction?
```
```javascript
public typealias RawValue = Swift.String
```
```javascript
public var rawValue: Swift.String { get }
```
```javascript
public struct ACHDirectDebitPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.ACHDirectDebitPaymentMethod
```
```javascript
public struct StoredACHDirectDebitPaymentMethod : Decodable, Encodable, PaymentMethod, StoredPaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
public let identifier: Swift.String { get }
```
```javascript
public let supportedShopperInteractions: [Adyen.ShopperInteraction] { get }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
public let bankAccountNumber: Swift.String { get }
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.StoredACHDirectDebitPaymentMethod
```
```javascript
public protocol AnyCardPaymentMethod<Self : Adyen.PaymentMethod> : Decodable, Encodable, PaymentMethod
```
```javascript
public var brands: [Adyen.CardType] { get }
```
```javascript
public var fundingSource: Adyen.CardFundingSource? { get }
```
```javascript
public enum CardFundingSource : Decodable, Encodable, Equatable, Hashable, RawRepresentable
```
```javascript
public case debit
```
```javascript
public case credit
```
```javascript
public init(rawValue: Swift.String) -> Adyen.CardFundingSource?
```
```javascript
public typealias RawValue = Swift.String
```
```javascript
public var rawValue: Swift.String { get }
```
```javascript
public enum PaymentMethodType : Decodable, Encodable, Equatable, Hashable, RawRepresentable
```
```javascript
public case card
```
```javascript
public case scheme
```
```javascript
public case ideal
```
```javascript
public case entercash
```
```javascript
public case eps
```
```javascript
public case dotpay
```
```javascript
public case onlineBankingPoland
```
```javascript
public case openBankingUK
```
```javascript
public case molPayEBankingFPXMY
```
```javascript
public case molPayEBankingTH
```
```javascript
public case molPayEBankingVN
```
```javascript
public case sepaDirectDebit
```
```javascript
public case applePay
```
```javascript
public case payPal
```
```javascript
public case bcmc
```
```javascript
public case bcmcMobile
```
```javascript
public case qiwiWallet
```
```javascript
public case weChatPaySDK
```
```javascript
public case mbWay
```
```javascript
public case blik
```
```javascript
public case dokuWallet
```
```javascript
public case dokuAlfamart
```
```javascript
public case dokuIndomaret
```
```javascript
public case giftcard
```
```javascript
public case doku
```
```javascript
public case econtextSevenEleven
```
```javascript
public case econtextStores
```
```javascript
public case econtextATM
```
```javascript
public case econtextOnline
```
```javascript
public case boleto
```
```javascript
public case affirm
```
```javascript
public case oxxo
```
```javascript
public case bacsDirectDebit
```
```javascript
public case achDirectDebit
```
```javascript
public case multibanco
```
```javascript
public case atome
```
```javascript
public case onlineBankingCZ
```
```javascript
public case onlineBankingSK
```
```javascript
public case mealVoucherNatixis
```
```javascript
public case mealVoucherGroupeUp
```
```javascript
public case mealVoucherSodexo
```
```javascript
public case upi
```
```javascript
public case cashAppPay
```
```javascript
public case twint
```
```javascript
public case other(Swift.String)
```
```javascript
public case bcmcMobileQR
```
```javascript
public case weChatMiniProgram
```
```javascript
public case weChatQR
```
```javascript
public case weChatPayWeb
```
```javascript
public case googlePay
```
```javascript
public case afterpay
```
```javascript
public case androidPay
```
```javascript
public case amazonPay
```
```javascript
public case upiCollect
```
```javascript
public case upiIntent
```
```javascript
public case upiQr
```
```javascript
public case bizum
```
```javascript
public init(rawValue: Swift.String) -> Adyen.PaymentMethodType?
```
```javascript
public var rawValue: Swift.String { get }
```
```javascript
public typealias RawValue = Swift.String
```
```javascript
@_spi(AdyenInternal) public var name: Swift.String { get }
```
```javascript
public struct PaymentMethods : Decodable, Encodable
```
```javascript
public var paid: [any Adyen.PaymentMethod] { get set }
```
```javascript
public var regular: [any Adyen.PaymentMethod] { get set }
```
```javascript
public var stored: [any Adyen.StoredPaymentMethod] { get set }
```
```javascript
public init(regular: [any Adyen.PaymentMethod], stored: [any Adyen.StoredPaymentMethod]) -> Adyen.PaymentMethods
```
```javascript
public mutating func overrideDisplayInformation<T where T : Adyen.PaymentMethod>(ofStoredPaymentMethod: Adyen.PaymentMethodType, with: Adyen.MerchantCustomDisplayInformation, where: (T) -> Swift.Bool) -> Swift.Void
```
```javascript
public mutating func overrideDisplayInformation(ofStoredPaymentMethod: Adyen.PaymentMethodType, with: Adyen.MerchantCustomDisplayInformation) -> Swift.Void
```
```javascript
public mutating func overrideDisplayInformation<T where T : Adyen.PaymentMethod>(ofRegularPaymentMethod: Adyen.PaymentMethodType, with: Adyen.MerchantCustomDisplayInformation, where: (T) -> Swift.Bool) -> Swift.Void
```
```javascript
public mutating func overrideDisplayInformation(ofRegularPaymentMethod: Adyen.PaymentMethodType, with: Adyen.MerchantCustomDisplayInformation) -> Swift.Void
```
```javascript
public func paymentMethod<T where T : Adyen.PaymentMethod>(ofType: T.Type) -> T?
```
```javascript
public func paymentMethod<T where T : Adyen.PaymentMethod>(ofType: T.Type, where: (T) -> Swift.Bool) -> T?
```
```javascript
public func paymentMethod(ofType: Adyen.PaymentMethodType) -> (any Adyen.PaymentMethod)?
```
```javascript
public func paymentMethod<T where T : Adyen.PaymentMethod>(ofType: Adyen.PaymentMethodType, where: (T) -> Swift.Bool) -> T?
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.PaymentMethods
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public struct AffirmPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.AffirmPaymentMethod
```
```javascript
public struct ApplePayPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
public let brands: [Swift.String]? { get }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.ApplePayPaymentMethod
```
```javascript
public struct AtomePaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.AtomePaymentMethod
```
```javascript
public struct BACSDirectDebitPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.BACSDirectDebitPaymentMethod
```
```javascript
public struct BCMCPaymentMethod : AnyCardPaymentMethod, Decodable, Encodable, PaymentMethod
```
```javascript
public var type: Adyen.PaymentMethodType { get }
```
```javascript
public var name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
public var brands: [Adyen.CardType] { get }
```
```javascript
public var fundingSource: Adyen.CardFundingSource? { get }
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.BCMCPaymentMethod
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public struct BLIKPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.BLIKPaymentMethod
```
```javascript
public struct BoletoPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.BoletoPaymentMethod
```
```javascript
public struct CardPaymentMethod : AnyCardPaymentMethod, Decodable, Encodable, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
public let fundingSource: Adyen.CardFundingSource? { get }
```
```javascript
public let brands: [Adyen.CardType] { get }
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.CardPaymentMethod
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public struct StoredCardPaymentMethod : AnyCardPaymentMethod, Decodable, Encodable, PaymentMethod, StoredPaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
public let identifier: Swift.String { get }
```
```javascript
public var brands: [Adyen.CardType] { get }
```
```javascript
public var fundingSource: Adyen.CardFundingSource? { get set }
```
```javascript
public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public let supportedShopperInteractions: [Adyen.ShopperInteraction] { get }
```
```javascript
public let brand: Adyen.CardType { get }
```
```javascript
public let lastFour: Swift.String { get }
```
```javascript
public let expiryMonth: Swift.String { get }
```
```javascript
public let expiryYear: Swift.String { get }
```
```javascript
public let holderName: Swift.String? { get }
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.StoredCardPaymentMethod
```
```javascript
public struct CashAppPayPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public let clientId: Swift.String { get }
```
```javascript
public let scopeId: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.CashAppPayPaymentMethod
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public struct DokuPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.DokuPaymentMethod
```
```javascript
public typealias DokuWalletPaymentMethod = Adyen.DokuPaymentMethod
```
```javascript
public typealias AlfamartPaymentMethod = Adyen.DokuPaymentMethod
```
```javascript
public typealias IndomaretPaymentMethod = Adyen.DokuPaymentMethod
```
```javascript
public struct EContextPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.EContextPaymentMethod
```
```javascript
public typealias SevenElevenPaymentMethod = Adyen.EContextPaymentMethod
```
```javascript
public struct GiftCardPaymentMethod : Decodable, Encodable, PartialPaymentMethod, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
public let brand: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.GiftCardPaymentMethod
```
```javascript
public struct InstantPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.InstantPaymentMethod
```
```javascript
public struct IssuerListPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
public let issuers: [Adyen.Issuer] { get }
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.IssuerListPaymentMethod
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public struct MBWayPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.MBWayPaymentMethod
```
```javascript
public struct MealVoucherPaymentMethod : Decodable, Encodable, PartialPaymentMethod, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.MealVoucherPaymentMethod
```
```javascript
public struct Issuer : CustomStringConvertible, Decodable, Encodable, Equatable
```
```javascript
public let identifier: Swift.String { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var description: Swift.String { get }
```
```javascript
public static func __derived_struct_equals(_: Adyen.Issuer, _: Adyen.Issuer) -> Swift.Bool
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.Issuer
```
```javascript
public struct OnlineBankingPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
public let issuers: [Adyen.Issuer] { get }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.OnlineBankingPaymentMethod
```
```javascript
public struct QiwiWalletPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
public let phoneExtensions: [Adyen.PhoneExtension] { get }
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.QiwiWalletPaymentMethod
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public struct PhoneExtension : Decodable, Encodable, Equatable, FormPickable
```
```javascript
public let value: Swift.String { get }
```
```javascript
public let countryCode: Swift.String { get }
```
```javascript
public var countryDisplayName: Swift.String { get }
```
```javascript
public init(value: Swift.String, countryCode: Swift.String) -> Adyen.PhoneExtension
```
```javascript
public static func __derived_struct_equals(_: Adyen.PhoneExtension, _: Adyen.PhoneExtension) -> Swift.Bool
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.PhoneExtension
```
```javascript
@_spi(AdyenInternal) public var identifier: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public var icon: UIKit.UIImage? { get }
```
```javascript
@_spi(AdyenInternal) public var title: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public var subtitle: Swift.String? { get }
```
```javascript
@_spi(AdyenInternal) public var trailingText: Swift.String? { get }
```
```javascript
public struct SEPADirectDebitPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.SEPADirectDebitPaymentMethod
```
```javascript
public struct StoredBCMCPaymentMethod : Decodable, Encodable, PaymentMethod, StoredPaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public var name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
public var identifier: Swift.String { get }
```
```javascript
public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
public var supportedShopperInteractions: [Adyen.ShopperInteraction] { get }
```
```javascript
public let brand: Swift.String { get }
```
```javascript
public var lastFour: Swift.String { get }
```
```javascript
public var expiryMonth: Swift.String { get }
```
```javascript
public var expiryYear: Swift.String { get }
```
```javascript
public var holderName: Swift.String? { get }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.StoredBCMCPaymentMethod
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public struct StoredBLIKPaymentMethod : Decodable, Encodable, PaymentMethod, StoredPaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
public let identifier: Swift.String { get }
```
```javascript
public let supportedShopperInteractions: [Adyen.ShopperInteraction] { get }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.StoredBLIKPaymentMethod
```
```javascript
public struct StoredCashAppPayPaymentMethod : Decodable, Encodable, PaymentMethod, StoredPaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public let cashtag: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
public let identifier: Swift.String { get }
```
```javascript
public let supportedShopperInteractions: [Adyen.ShopperInteraction] { get }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
@_spi(AdyenInternal) public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.StoredCashAppPayPaymentMethod
```
```javascript
public struct StoredInstantPaymentMethod : Decodable, Encodable, PaymentMethod, StoredPaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
public let identifier: Swift.String { get }
```
```javascript
public let supportedShopperInteractions: [Adyen.ShopperInteraction] { get }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.StoredInstantPaymentMethod
```
```javascript
public struct StoredPayPalPaymentMethod : Decodable, Encodable, PaymentMethod, StoredPaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
public let identifier: Swift.String { get }
```
```javascript
public let supportedShopperInteractions: [Adyen.ShopperInteraction] { get }
```
```javascript
public func defaultDisplayInformation(using: Adyen.LocalizationParameters?) -> Adyen.DisplayInformation
```
```javascript
public let emailAddress: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.StoredPayPalPaymentMethod
```
```javascript
public struct TwintPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
public var type: Adyen.PaymentMethodType { get set }
```
```javascript
public var name: Swift.String { get set }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.TwintPaymentMethod
```
```javascript
public struct UPIPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public let apps: [Adyen.Issuer]? { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.UPIPaymentMethod
```
```javascript
public struct WeChatPayPaymentMethod : Decodable, Encodable, PaymentMethod
```
```javascript
public let type: Adyen.PaymentMethodType { get }
```
```javascript
public let name: Swift.String { get }
```
```javascript
public var merchantProvidedDisplayInformation: Adyen.MerchantCustomDisplayInformation? { get set }
```
```javascript
@_spi(AdyenInternal) public func buildComponent(using: any Adyen.PaymentComponentBuilder) -> (any Adyen.PaymentComponent)?
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.WeChatPayPaymentMethod
```
```javascript
@_spi(AdyenInternal) @objc public final class CancellingToolBar : AdyenCompatible, AnyNavigationBar, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) override public init(title: Swift.String?, style: Adyen.NavigationStyle) -> Adyen.CancellingToolBar
```
```javascript
@_spi(AdyenInternal) @objc public class ModalToolbar : AdyenCompatible, AnyNavigationBar, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public var onCancelHandler: (() -> Swift.Void)? { get set }
```
```javascript
@_spi(AdyenInternal) public init(title: Swift.String?, style: Adyen.NavigationStyle) -> Adyen.ModalToolbar
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init(frame: CoreFoundation.CGRect) -> Adyen.ModalToolbar
```
```javascript
public final class AmountFormatter
```
```javascript
public static func formatted(amount: Swift.Int, currencyCode: Swift.String, localeIdentifier: Swift.String? = $DEFAULT_ARG) -> Swift.String?
```
```javascript
public static func minorUnitAmount(from: Swift.Double, currencyCode: Swift.String, localeIdentifier: Swift.String? = $DEFAULT_ARG) -> Swift.Int
```
```javascript
public static func minorUnitAmount(from: Foundation.Decimal, currencyCode: Swift.String, localeIdentifier: Swift.String? = $DEFAULT_ARG) -> Swift.Int
```
```javascript
public static func decimalAmount(_: Swift.Int, currencyCode: Swift.String, localeIdentifier: Swift.String? = $DEFAULT_ARG) -> Foundation.NSDecimalNumber
```
```javascript
public final class BrazilSocialSecurityNumberFormatter : Formatter, Sanitizer
```
```javascript
override public func formattedValue(for: Swift.String) -> Swift.String
```
```javascript
override public init() -> Adyen.BrazilSocialSecurityNumberFormatter
```
```javascript
public protocol Formatter<Self : Adyen.Sanitizer> : Sanitizer
```
```javascript
public func formattedValue<Self where Self : Adyen.Formatter>(for: Swift.String) -> Swift.String
```
```javascript
public protocol Sanitizer
```
```javascript
public func sanitizedValue<Self where Self : Adyen.Sanitizer>(for: Swift.String) -> Swift.String
```
```javascript
public final class IBANFormatter : Formatter, Sanitizer
```
```javascript
public init() -> Adyen.IBANFormatter
```
```javascript
public func formattedValue(for: Swift.String) -> Swift.String
```
```javascript
public func sanitizedValue(for: Swift.String) -> Swift.String
```
```javascript
public class NumericFormatter : Formatter, Sanitizer
```
```javascript
public init() -> Adyen.NumericFormatter
```
```javascript
public func formattedValue(for: Swift.String) -> Swift.String
```
```javascript
public func sanitizedValue(for: Swift.String) -> Swift.String
```
```javascript
@_spi(AdyenInternal) public protocol AdyenCancellable
```
```javascript
@_spi(AdyenInternal) public func cancel<Self where Self : Adyen.AdyenCancellable>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public class AdyenTask : AdyenCancellable
```
```javascript
@_spi(AdyenInternal) public var isCancelled: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) public func cancel() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public struct AdyenDependencyValues
```
```javascript
@_spi(AdyenInternal) public subscript<K where K : Adyen.AdyenDependencyKey>(_: K.Type) -> K.Value { get set }
```
```javascript
@_spi(AdyenInternal) public struct AdyenDependency<T>
```
```javascript
@_spi(AdyenInternal) public var wrappedValue: T { get }
```
```javascript
@_spi(AdyenInternal) public init<T>(_: Swift.KeyPath<Adyen.AdyenDependencyValues, T>) -> Adyen.AdyenDependency<T>
```
```javascript
@_spi(AdyenInternal) public protocol AdyenDependencyKey
```
```javascript
@_spi(AdyenInternal) public associatedtype Value
```
```javascript
@_spi(AdyenInternal) public static var liveValue: Self.Value { get }
```
```javascript
@_spi(AdyenInternal) public struct AdyenScope<Base>
```
```javascript
@_spi(AdyenInternal) public let base: Base { get }
```
```javascript
@_spi(AdyenInternal) public init<Base>(base: Base) -> Adyen.AdyenScope<Base>
```
```javascript
@_spi(AdyenInternal) public subscript<Base, T where Base == [T]>(safeIndex: Swift.Int) -> T? { get }
```
```javascript
@_spi(AdyenInternal) public func isSchemeConfigured<Base where Base : Foundation.Bundle>(_: Swift.String) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func with<Base where Base : UIKit.NSLayoutConstraint>(priority: UIKit.UILayoutPriority) -> UIKit.NSLayoutConstraint
```
```javascript
@_spi(AdyenInternal) public var caAlignmentMode: QuartzCore.CATextLayerAlignmentMode { get }
```
```javascript
@_spi(AdyenInternal) public var isNullOrEmpty: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) public var nilIfEmpty: Swift.String? { get }
```
```javascript
@_spi(AdyenInternal) public var nilIfEmpty: Swift.String? { get }
```
```javascript
@_spi(AdyenInternal) public func truncate<Base where Base == Swift.String>(to: Swift.Int) -> Swift.String
```
```javascript
@_spi(AdyenInternal) public func components<Base where Base == Swift.String>(withLengths: [Swift.Int]) -> [Swift.String]
```
```javascript
@_spi(AdyenInternal) public func components<Base where Base == Swift.String>(withLength: Swift.Int) -> [Swift.String]
```
```javascript
@_spi(AdyenInternal) public subscript<Base where Base == Swift.String>(_: Swift.Int) -> Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public subscript<Base where Base == Swift.String>(_: Swift.Range<Swift.Int>) -> Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public subscript<Base where Base == Swift.String>(_: Swift.ClosedRange<Swift.Int>) -> Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public var linkRanges: [Foundation.NSRange] { get }
```
```javascript
@_spi(AdyenInternal) public func timeLeftString<Base where Base == Swift.Double>() -> Swift.String?
```
```javascript
@_spi(AdyenInternal) public var mainKeyWindow: UIKit.UIWindow? { get }
```
```javascript
@_spi(AdyenInternal) public func font<Base where Base : UIKit.UIFont>(with: UIKit.UIFont.Weight) -> UIKit.UIFont
```
```javascript
@_spi(AdyenInternal) public func cancelAnimations<Base where Base : UIKit.UIView>(with: Swift.String) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func animate<Base where Base : UIKit.UIView>(context: Adyen.AnimationContext) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @discardableResult public func anchor<Base where Base : UIKit.UIView>(inside: UIKit.UIView, with: UIKit.UIEdgeInsets = $DEFAULT_ARG) -> [UIKit.NSLayoutConstraint]
```
```javascript
@_spi(AdyenInternal) @discardableResult public func anchor<Base where Base : UIKit.UIView>(inside: UIKit.UILayoutGuide, with: UIKit.UIEdgeInsets = $DEFAULT_ARG) -> [UIKit.NSLayoutConstraint]
```
```javascript
@_spi(AdyenInternal) @discardableResult public func anchor<Base where Base : UIKit.UIView>(inside: Adyen.AdyenScope<Base>.LayoutAnchorSource, edgeInsets: Adyen.AdyenScope<Base>.EdgeInsets = $DEFAULT_ARG) -> [UIKit.NSLayoutConstraint]
```
```javascript
@_spi(AdyenInternal) public func wrapped<Base where Base : UIKit.UIView>(with: UIKit.UIEdgeInsets = $DEFAULT_ARG) -> UIKit.UIView
```
```javascript
@_spi(AdyenInternal) public enum LayoutAnchorSource<Base where Base : UIKit.UIView>
```
```javascript
@_spi(AdyenInternal) public case view(UIKit.UIView)
```
```javascript
@_spi(AdyenInternal) public case layoutGuide(UIKit.UILayoutGuide)
```
```javascript
@_spi(AdyenInternal) public struct EdgeInsets<Base where Base : UIKit.UIView>
```
```javascript
@_spi(AdyenInternal) public var top: CoreGraphics.CGFloat? { get set }
```
```javascript
@_spi(AdyenInternal) public var left: CoreGraphics.CGFloat? { get set }
```
```javascript
@_spi(AdyenInternal) public var bottom: CoreGraphics.CGFloat? { get set }
```
```javascript
@_spi(AdyenInternal) public var right: CoreGraphics.CGFloat? { get set }
```
```javascript
@_spi(AdyenInternal) public static var zero: Adyen.AdyenScope<Base>.EdgeInsets { get }
```
```javascript
@_spi(AdyenInternal) public init<Base where Base : UIKit.UIView>(top: CoreGraphics.CGFloat? = $DEFAULT_ARG, left: CoreGraphics.CGFloat? = $DEFAULT_ARG, bottom: CoreGraphics.CGFloat? = $DEFAULT_ARG, right: CoreGraphics.CGFloat? = $DEFAULT_ARG) -> Adyen.AdyenScope<Base>.EdgeInsets
```
```javascript
@_spi(AdyenInternal) public var topPresenter: UIKit.UIViewController { get }
```
```javascript
@_spi(AdyenInternal) @discardableResult public func snapShot<Base where Base : UIKit.UIView>(forceRedraw: Swift.Bool = $DEFAULT_ARG) -> UIKit.UIImage?
```
```javascript
@_spi(AdyenInternal) public func hide<Base where Base : UIKit.UIView>(animationKey: Swift.String, hidden: Swift.Bool, animated: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public var minimalSize: CoreFoundation.CGSize { get }
```
```javascript
@_spi(AdyenInternal) public func round<Base where Base : UIKit.UIView>(corners: UIKit.UIRectCorner, radius: CoreGraphics.CGFloat) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func round<Base where Base : UIKit.UIView>(corners: UIKit.UIRectCorner, percentage: CoreGraphics.CGFloat) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func round<Base where Base : UIKit.UIView>(corners: UIKit.UIRectCorner, rounding: Adyen.CornerRounding) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func round<Base where Base : UIKit.UIView>(using: Adyen.CornerRounding) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public var queryParameters: [Swift.String : Swift.String] { get }
```
```javascript
@_spi(AdyenInternal) public var isHttp: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) public protocol AdyenCompatible
```
```javascript
@_spi(AdyenInternal) public associatedtype AdyenBase
```
```javascript
@_spi(AdyenInternal) public var adyen: Adyen.AdyenScope<Self.AdyenBase> { get }
```
```javascript
@_spi(AdyenInternal) public var adyen: Adyen.AdyenScope<Self> { get }
```
```javascript
public let adyenSdkVersion: Swift.String
```
```javascript
@_spi(AdyenInternal) public protocol ImageLoading
```
```javascript
@_spi(AdyenInternal) @discardableResult public func load<Self where Self : Adyen.ImageLoading>(url: Foundation.URL, completion: ((UIKit.UIImage?) -> Swift.Void)) -> any Adyen.AdyenCancellable
```
```javascript
@_spi(AdyenInternal) public final class ImageLoader : ImageLoading
```
```javascript
@_spi(AdyenInternal) public init(urlSession: Foundation.URLSession = $DEFAULT_ARG) -> Adyen.ImageLoader
```
```javascript
@_spi(AdyenInternal) @discardableResult public func load(url: Foundation.URL, completion: ((UIKit.UIImage?) -> Swift.Void)) -> any Adyen.AdyenCancellable
```
```javascript
@_spi(AdyenInternal) public final class ImageLoaderProvider
```
```javascript
@_spi(AdyenInternal) public static func imageLoader() -> any Adyen.ImageLoading
```
```javascript
@_spi(AdyenInternal) @objc public class AnimationContext : CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSObjectProtocol
```
```javascript
@_spi(AdyenInternal) public init(animationKey: Swift.String, duration: Foundation.TimeInterval, delay: Foundation.TimeInterval = $DEFAULT_ARG, options: UIKit.UIView.AnimationOptions = $DEFAULT_ARG, animations: () -> Swift.Void, completion: ((Swift.Bool) -> Swift.Void)? = $DEFAULT_ARG) -> Adyen.AnimationContext
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init() -> Adyen.AnimationContext
```
```javascript
@_spi(AdyenInternal) @objc public final class KeyFrameAnimationContext : CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSObjectProtocol
```
```javascript
@_spi(AdyenInternal) public init(animationKey: Swift.String, duration: Foundation.TimeInterval, delay: Foundation.TimeInterval = $DEFAULT_ARG, options: UIKit.UIView.KeyframeAnimationOptions = $DEFAULT_ARG, animations: () -> Swift.Void, completion: ((Swift.Bool) -> Swift.Void)? = $DEFAULT_ARG) -> Adyen.KeyFrameAnimationContext
```
```javascript
@_spi(AdyenInternal) override public init(animationKey: Swift.String, duration: Foundation.TimeInterval, delay: Foundation.TimeInterval = $DEFAULT_ARG, options: UIKit.UIView.AnimationOptions = $DEFAULT_ARG, animations: () -> Swift.Void, completion: ((Swift.Bool) -> Swift.Void)? = $DEFAULT_ARG) -> Adyen.KeyFrameAnimationContext
```
```javascript
@_spi(AdyenInternal) @objc public final class SpringAnimationContext : CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSObjectProtocol
```
```javascript
@_spi(AdyenInternal) public init(animationKey: Swift.String, duration: Foundation.TimeInterval, delay: Foundation.TimeInterval = $DEFAULT_ARG, dampingRatio: CoreGraphics.CGFloat, velocity: CoreGraphics.CGFloat, options: UIKit.UIView.AnimationOptions = $DEFAULT_ARG, animations: () -> Swift.Void, completion: ((Swift.Bool) -> Swift.Void)? = $DEFAULT_ARG) -> Adyen.SpringAnimationContext
```
```javascript
@_spi(AdyenInternal) override public init(animationKey: Swift.String, duration: Foundation.TimeInterval, delay: Foundation.TimeInterval = $DEFAULT_ARG, options: UIKit.UIView.AnimationOptions = $DEFAULT_ARG, animations: () -> Swift.Void, completion: ((Swift.Bool) -> Swift.Void)? = $DEFAULT_ARG) -> Adyen.SpringAnimationContext
```
```javascript
@_spi(AdyenInternal) public protocol PreferredContentSizeConsumer
```
```javascript
@_spi(AdyenInternal) public func didUpdatePreferredContentSize<Self where Self : Adyen.PreferredContentSizeConsumer>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func willUpdatePreferredContentSize<Self where Self : Adyen.PreferredContentSizeConsumer>() -> Swift.Void
```
```javascript
public struct Amount : Comparable, Decodable, Encodable, Equatable
```
```javascript
public let value: Swift.Int { get }
```
```javascript
public let currencyCode: Swift.String { get }
```
```javascript
public var localeIdentifier: Swift.String? { get set }
```
```javascript
public init(value: Swift.Int, currencyCode: Swift.String, localeIdentifier: Swift.String? = $DEFAULT_ARG) -> Adyen.Amount
```
```javascript
public init(value: Foundation.Decimal, currencyCode: Swift.String, localeIdentifier: Swift.String? = $DEFAULT_ARG) -> Adyen.Amount
```
```javascript
public static func __derived_struct_equals(_: Adyen.Amount, _: Adyen.Amount) -> Swift.Bool
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.Amount
```
```javascript
public var formatted: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public var formattedComponents: Adyen.AmountComponents { get }
```
```javascript
@_spi(AdyenInternal) public static func <(_: Adyen.Amount, _: Adyen.Amount) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public static func <=(_: Adyen.Amount, _: Adyen.Amount) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public static func >=(_: Adyen.Amount, _: Adyen.Amount) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public static func >(_: Adyen.Amount, _: Adyen.Amount) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public struct AmountComponents
```
```javascript
@_spi(AdyenInternal) public let formattedValue: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public let formattedCurrencySymbol: Swift.String { get }
```
```javascript
public protocol OpaqueEncodable<Self : Swift.Encodable> : Encodable
```
```javascript
public var encodable: Adyen.AnyEncodable { get }
```
```javascript
public var encodable: Adyen.AnyEncodable { get }
```
```javascript
public struct AnyEncodable : Encodable
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public struct Balance
```
```javascript
public let availableAmount: Adyen.Amount { get }
```
```javascript
public let transactionLimit: Adyen.Amount? { get }
```
```javascript
public init(availableAmount: Adyen.Amount, transactionLimit: Adyen.Amount?) -> Adyen.Balance
```
```javascript
public struct BrowserInfo : Encodable
```
```javascript
public var userAgent: Swift.String? { get set }
```
```javascript
public static func initialize(completion: ((Adyen.BrowserInfo?) -> Swift.Void)) -> Swift.Void
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public protocol DelegatedAuthenticationAware
```
```javascript
@_spi(AdyenInternal) public var delegatedAuthenticationData: Adyen.DelegatedAuthenticationData? { get }
```
```javascript
public enum DelegatedAuthenticationData : Decodable, Encodable
```
```javascript
public enum DecodingError : Equatable, Error, Hashable, LocalizedError, Sendable
```
```javascript
public case invalidDelegatedAuthenticationData
```
```javascript
public var errorDescription: Swift.String? { get }
```
```javascript
public static func __derived_enum_equals(_: Adyen.DelegatedAuthenticationData.DecodingError, _: Adyen.DelegatedAuthenticationData.DecodingError) -> Swift.Bool
```
```javascript
public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
public var hashValue: Swift.Int { get }
```
```javascript
public case sdkOutput(Swift.String)
```
```javascript
public case sdkInput(Swift.String)
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.DelegatedAuthenticationData
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public struct Installments : Encodable, Equatable
```
```javascript
public enum Plan : Equatable, Hashable, RawRepresentable
```
```javascript
public case regular
```
```javascript
public case revolving
```
```javascript
public init(rawValue: Swift.String) -> Adyen.Installments.Plan?
```
```javascript
public typealias RawValue = Swift.String
```
```javascript
public var rawValue: Swift.String { get }
```
```javascript
public let totalMonths: Swift.Int { get }
```
```javascript
public let plan: Adyen.Installments.Plan { get }
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(totalMonths: Swift.Int, plan: Adyen.Installments.Plan) -> Adyen.Installments
```
```javascript
public static func __derived_struct_equals(_: Adyen.Installments, _: Adyen.Installments) -> Swift.Bool
```
```javascript
public struct PartialPaymentOrder : Decodable, Encodable, Equatable
```
```javascript
public struct CompactOrder : Encodable, Equatable
```
```javascript
public let pspReference: Swift.String { get }
```
```javascript
public let orderData: Swift.String? { get }
```
```javascript
public static func __derived_struct_equals(_: Adyen.PartialPaymentOrder.CompactOrder, _: Adyen.PartialPaymentOrder.CompactOrder) -> Swift.Bool
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public let compactOrder: Adyen.PartialPaymentOrder.CompactOrder { get }
```
```javascript
public let pspReference: Swift.String { get }
```
```javascript
public let orderData: Swift.String? { get }
```
```javascript
public let reference: Swift.String? { get }
```
```javascript
public let amount: Adyen.Amount? { get }
```
```javascript
public let remainingAmount: Adyen.Amount? { get }
```
```javascript
public let expiresAt: Foundation.Date? { get }
```
```javascript
public init(pspReference: Swift.String, orderData: Swift.String?, reference: Swift.String? = $DEFAULT_ARG, amount: Adyen.Amount? = $DEFAULT_ARG, remainingAmount: Adyen.Amount? = $DEFAULT_ARG, expiresAt: Foundation.Date? = $DEFAULT_ARG) -> Adyen.PartialPaymentOrder
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.PartialPaymentOrder
```
```javascript
public static func __derived_struct_equals(_: Adyen.PartialPaymentOrder, _: Adyen.PartialPaymentOrder) -> Swift.Bool
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public struct Payment : Decodable, Encodable
```
```javascript
public let amount: Adyen.Amount { get }
```
```javascript
public let countryCode: Swift.String { get }
```
```javascript
public init(amount: Adyen.Amount, countryCode: Swift.String) -> Adyen.Payment
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.Payment
```
```javascript
public struct PaymentComponentData
```
```javascript
public let amount: Adyen.Amount? { get }
```
```javascript
public let paymentMethod: any Adyen.PaymentMethodDetails { get }
```
```javascript
public let storePaymentMethod: Swift.Bool? { get }
```
```javascript
public let order: Adyen.PartialPaymentOrder? { get }
```
```javascript
public var amountToPay: Adyen.Amount? { get }
```
```javascript
public let installments: Adyen.Installments? { get }
```
```javascript
public let supportNativeRedirect: Swift.Bool { get }
```
```javascript
public var shopperName: Adyen.ShopperName? { get }
```
```javascript
public var emailAddress: Swift.String? { get }
```
```javascript
public var telephoneNumber: Swift.String? { get }
```
```javascript
public let browserInfo: Adyen.BrowserInfo? { get }
```
```javascript
public var checkoutAttemptId: Swift.String? { get }
```
```javascript
public var billingAddress: Adyen.PostalAddress? { get }
```
```javascript
public var deliveryAddress: Adyen.PostalAddress? { get }
```
```javascript
public var socialSecurityNumber: Swift.String? { get }
```
```javascript
public var delegatedAuthenticationData: Adyen.DelegatedAuthenticationData? { get }
```
```javascript
@_spi(AdyenInternal) public init(paymentMethodDetails: some Adyen.PaymentMethodDetails, amount: Adyen.Amount?, order: Adyen.PartialPaymentOrder?, storePaymentMethod: Swift.Bool? = $DEFAULT_ARG, browserInfo: Adyen.BrowserInfo? = $DEFAULT_ARG, installments: Adyen.Installments? = $DEFAULT_ARG) -> Adyen.PaymentComponentData
```
```javascript
@_spi(AdyenInternal) public func replacing(order: Adyen.PartialPaymentOrder) -> Adyen.PaymentComponentData
```
```javascript
@_spi(AdyenInternal) public func replacing(amount: Adyen.Amount) -> Adyen.PaymentComponentData
```
```javascript
@_spi(AdyenInternal) public func replacing(checkoutAttemptId: Swift.String?) -> Adyen.PaymentComponentData
```
```javascript
@_spi(AdyenInternal) public func dataByAddingBrowserInfo(completion: ((Adyen.PaymentComponentData) -> Swift.Void)) -> Swift.Void
```
```javascript
public struct PostalAddress : Encodable, Equatable
```
```javascript
public init(city: Swift.String? = $DEFAULT_ARG, country: Swift.String? = $DEFAULT_ARG, houseNumberOrName: Swift.String? = $DEFAULT_ARG, postalCode: Swift.String? = $DEFAULT_ARG, stateOrProvince: Swift.String? = $DEFAULT_ARG, street: Swift.String? = $DEFAULT_ARG, apartment: Swift.String? = $DEFAULT_ARG) -> Adyen.PostalAddress
```
```javascript
public var city: Swift.String? { get set }
```
```javascript
public var country: Swift.String? { get set }
```
```javascript
public var houseNumberOrName: Swift.String? { get set }
```
```javascript
public var postalCode: Swift.String? { get set }
```
```javascript
public var stateOrProvince: Swift.String? { get set }
```
```javascript
public var street: Swift.String? { get set }
```
```javascript
public var apartment: Swift.String? { get set }
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public static func ==(_: Adyen.PostalAddress, _: Adyen.PostalAddress) -> Swift.Bool
```
```javascript
public var isEmpty: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) public func formatted(using: Adyen.LocalizationParameters?) -> Swift.String
```
```javascript
@_spi(AdyenInternal) public var formattedStreet: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public func formattedLocation(using: Adyen.LocalizationParameters?) -> Swift.String
```
```javascript
@_spi(AdyenInternal) public func satisfies(requiredFields: Swift.Set<Adyen.AddressField>) -> Swift.Bool
```
```javascript
public struct PhoneNumber
```
```javascript
public let value: Swift.String { get }
```
```javascript
public let callingCode: Swift.String? { get }
```
```javascript
public init(value: Swift.String, callingCode: Swift.String?) -> Adyen.PhoneNumber
```
```javascript
public struct PrefilledShopperInformation : ShopperInformation
```
```javascript
public var shopperName: Adyen.ShopperName? { get set }
```
```javascript
public var emailAddress: Swift.String? { get set }
```
```javascript
public var telephoneNumber: Swift.String? { get set }
```
```javascript
public var phoneNumber: Adyen.PhoneNumber? { get set }
```
```javascript
public var billingAddress: Adyen.PostalAddress? { get set }
```
```javascript
public var deliveryAddress: Adyen.PostalAddress? { get set }
```
```javascript
public var socialSecurityNumber: Swift.String? { get set }
```
```javascript
public var card: Adyen.PrefilledShopperInformation.CardInformation? { get set }
```
```javascript
public init(shopperName: Adyen.ShopperName? = $DEFAULT_ARG, emailAddress: Swift.String? = $DEFAULT_ARG, telephoneNumber: Swift.String? = $DEFAULT_ARG, billingAddress: Adyen.PostalAddress? = $DEFAULT_ARG, deliveryAddress: Adyen.PostalAddress? = $DEFAULT_ARG, socialSecurityNumber: Swift.String? = $DEFAULT_ARG, card: Adyen.PrefilledShopperInformation.CardInformation? = $DEFAULT_ARG) -> Adyen.PrefilledShopperInformation
```
```javascript
public init(shopperName: Adyen.ShopperName? = $DEFAULT_ARG, emailAddress: Swift.String? = $DEFAULT_ARG, phoneNumber: Adyen.PhoneNumber? = $DEFAULT_ARG, billingAddress: Adyen.PostalAddress? = $DEFAULT_ARG, deliveryAddress: Adyen.PostalAddress? = $DEFAULT_ARG, socialSecurityNumber: Swift.String? = $DEFAULT_ARG, card: Adyen.PrefilledShopperInformation.CardInformation? = $DEFAULT_ARG) -> Adyen.PrefilledShopperInformation
```
```javascript
public struct CardInformation
```
```javascript
public let holderName: Swift.String { get }
```
```javascript
public init(holderName: Swift.String) -> Adyen.PrefilledShopperInformation.CardInformation
```
```javascript
public protocol ShopperInformation
```
```javascript
public var shopperName: Adyen.ShopperName? { get }
```
```javascript
public var emailAddress: Swift.String? { get }
```
```javascript
public var telephoneNumber: Swift.String? { get }
```
```javascript
public var billingAddress: Adyen.PostalAddress? { get }
```
```javascript
public var deliveryAddress: Adyen.PostalAddress? { get }
```
```javascript
public var socialSecurityNumber: Swift.String? { get }
```
```javascript
@_spi(AdyenInternal) public var shopperName: Adyen.ShopperName? { get }
```
```javascript
@_spi(AdyenInternal) public var emailAddress: Swift.String? { get }
```
```javascript
@_spi(AdyenInternal) public var telephoneNumber: Swift.String? { get }
```
```javascript
@_spi(AdyenInternal) public var billingAddress: Adyen.PostalAddress? { get }
```
```javascript
@_spi(AdyenInternal) public var deliveryAddress: Adyen.PostalAddress? { get }
```
```javascript
@_spi(AdyenInternal) public var socialSecurityNumber: Swift.String? { get }
```
```javascript
public struct ShopperName : Decodable, Encodable, Equatable
```
```javascript
public let firstName: Swift.String { get }
```
```javascript
public let lastName: Swift.String { get }
```
```javascript
public init(firstName: Swift.String, lastName: Swift.String) -> Adyen.ShopperName
```
```javascript
public static func __derived_struct_equals(_: Adyen.ShopperName, _: Adyen.ShopperName) -> Swift.Bool
```
```javascript
public func encode(to: any Swift.Encoder) throws -> Swift.Void
```
```javascript
public init(from: any Swift.Decoder) throws -> Adyen.ShopperName
```
```javascript
@_spi(AdyenInternal) public enum Dimensions
```
```javascript
@_spi(AdyenInternal) public static var leastPresentableScale: CoreGraphics.CGFloat { get set }
```
```javascript
@_spi(AdyenInternal) public static var greatestPresentableHeightScale: CoreGraphics.CGFloat { get set }
```
```javascript
@_spi(AdyenInternal) public static var maxAdaptiveWidth: CoreGraphics.CGFloat { get set }
```
```javascript
@_spi(AdyenInternal) public static var greatestPresentableScale: CoreGraphics.CGFloat { get }
```
```javascript
@_spi(AdyenInternal) public static func expectedWidth(for: UIKit.UIWindow? = $DEFAULT_ARG) -> CoreGraphics.CGFloat
```
```javascript
@_spi(AdyenInternal) public static func keyWindowSize(for: UIKit.UIWindow? = $DEFAULT_ARG) -> CoreFoundation.CGRect
```
```javascript
@_spi(AdyenInternal) public struct FormItemViewBuilder
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormToggleItem) -> Adyen.FormItemView<Adyen.FormToggleItem>
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormSplitItem) -> Adyen.FormItemView<Adyen.FormSplitItem>
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormPhoneNumberItem) -> Adyen.FormItemView<Adyen.FormPhoneNumberItem>
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormIssuersPickerItem) -> Adyen.BaseFormPickerItemView<Adyen.Issuer>
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormTextInputItem) -> Adyen.FormItemView<Adyen.FormTextInputItem>
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.ListItem) -> Adyen.ListItemView
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.SelectableFormItem) -> Adyen.FormItemView<Adyen.SelectableFormItem>
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormButtonItem) -> Adyen.FormItemView<Adyen.FormButtonItem>
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormImageItem) -> Adyen.FormItemView<Adyen.FormImageItem>
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormSeparatorItem) -> Adyen.FormItemView<Adyen.FormSeparatorItem>
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormErrorItem) -> Adyen.FormItemView<Adyen.FormErrorItem>
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormAddressItem) -> Adyen.FormItemView<Adyen.FormAddressItem>
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormSpacerItem) -> Adyen.FormItemView<Adyen.FormSpacerItem>
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormPostalCodeItem) -> Adyen.FormItemView<Adyen.FormPostalCodeItem>
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormSearchButtonItem) -> Adyen.FormItemView<Adyen.FormSearchButtonItem>
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormAddressPickerItem) -> Adyen.FormItemView<Adyen.FormAddressPickerItem>
```
```javascript
@_spi(AdyenInternal) public func build<Value where Value : Adyen.FormPickable>(with: Adyen.FormPickerItem<Value>) -> Adyen.FormItemView<Adyen.FormPickerItem<Value>>
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormPhoneExtensionPickerItem) -> Adyen.FormPhoneExtensionPickerItemView
```
```javascript
@_spi(AdyenInternal) public static func build(_: any Adyen.FormItem) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) public protocol FormViewProtocol
```
```javascript
@_spi(AdyenInternal) public func add<Self, T where Self : Adyen.FormViewProtocol, T : Adyen.FormItem>(item: T?) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func displayValidation<Self where Self : Adyen.FormViewProtocol>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc public class FormViewController : AdyenCompatible, AdyenObserver, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, FormTextItemViewDelegate, FormViewProtocol, Hashable, NSCoding, NSExtensionRequestHandling, NSObjectProtocol, PreferredContentSizeConsumer, Sendable, UIActivityItemsConfigurationProviding, UIAppearanceContainer, UIContentContainer, UIFocusEnvironment, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UIStateRestoring, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring, ViewControllerPresenter
```
```javascript
@_spi(AdyenInternal) public var requiresKeyboardInput: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) public let style: any Adyen.ViewStyle { get }
```
```javascript
@_spi(AdyenInternal) public weak var delegate: (any Adyen.ViewControllerDelegate)? { get set }
```
```javascript
@_spi(AdyenInternal) public init(style: any Adyen.ViewStyle, localizationParameters: Adyen.LocalizationParameters?) -> Adyen.FormViewController
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic func viewDidLoad() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic func viewWillAppear(_: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic func viewDidAppear(_: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic func viewWillDisappear(_: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic func viewDidDisappear(_: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic var preferredContentSize: CoreFoundation.CGSize { get set }
```
```javascript
@_spi(AdyenInternal) public func willUpdatePreferredContentSize() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func didUpdatePreferredContentSize() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func append(_: some Adyen.FormItem) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public let localizationParameters: Adyen.LocalizationParameters? { get }
```
```javascript
@_spi(AdyenInternal) public func validate() -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func showValidation() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func resetForm() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @discardableResult @objc override public dynamic func resignFirstResponder() -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init(nibName: Swift.String?, bundle: Foundation.Bundle?) -> Adyen.FormViewController
```
```javascript
@_spi(AdyenInternal) public func add(item: (some Adyen.FormItem)?) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func displayValidation() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func didReachMaximumLength(in: Adyen.FormTextItemView<some Adyen.FormTextItem>) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func didSelectReturnKey(in: Adyen.FormTextItemView<some Adyen.FormTextItem>) -> Swift.Void
```
```javascript
public struct AddressStyle : FormValueItemStyle, TintableStyle, ViewStyle
```
```javascript
public var title: Adyen.TextStyle { get set }
```
```javascript
public var textField: Adyen.FormTextItemStyle { get set }
```
```javascript
public var tintColor: UIKit.UIColor? { get set }
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public var separatorColor: UIKit.UIColor? { get }
```
```javascript
public init(title: Adyen.TextStyle, textField: Adyen.FormTextItemStyle, tintColor: UIKit.UIColor? = $DEFAULT_ARG, backgroundColor: UIKit.UIColor = $DEFAULT_ARG) -> Adyen.AddressStyle
```
```javascript
public init() -> Adyen.AddressStyle
```
```javascript
@_spi(AdyenInternal) public enum AddressField : CaseIterable, Equatable, Hashable, RawRepresentable
```
```javascript
@_spi(AdyenInternal) public case street
```
```javascript
@_spi(AdyenInternal) public case houseNumberOrName
```
```javascript
@_spi(AdyenInternal) public case apartment
```
```javascript
@_spi(AdyenInternal) public case postalCode
```
```javascript
@_spi(AdyenInternal) public case city
```
```javascript
@_spi(AdyenInternal) public case stateOrProvince
```
```javascript
@_spi(AdyenInternal) public case country
```
```javascript
@_spi(AdyenInternal) public init(rawValue: Swift.String) -> Adyen.AddressField?
```
```javascript
@_spi(AdyenInternal) public typealias AllCases = [Adyen.AddressField]
```
```javascript
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
@_spi(AdyenInternal) public static var allCases: [Adyen.AddressField] { get }
```
```javascript
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public enum AddressFormScheme
```
```javascript
@_spi(AdyenInternal) public var children: [Adyen.AddressField] { get }
```
```javascript
@_spi(AdyenInternal) public case item(Adyen.AddressField)
```
```javascript
@_spi(AdyenInternal) public case split(Adyen.AddressField, Adyen.AddressField)
```
```javascript
@_spi(AdyenInternal) public struct AddressViewModel
```
```javascript
@_spi(AdyenInternal) public var optionalFields: [Adyen.AddressField] { get set }
```
```javascript
@_spi(AdyenInternal) public var scheme: [Adyen.AddressFormScheme] { get set }
```
```javascript
@_spi(AdyenInternal) public init(labels: [Adyen.AddressField : Adyen.LocalizationKey], placeholder: [Adyen.AddressField : Adyen.LocalizationKey], optionalFields: [Adyen.AddressField], scheme: [Adyen.AddressFormScheme]) -> Adyen.AddressViewModel
```
```javascript
@_spi(AdyenInternal) public var requiredFields: Swift.Set<Adyen.AddressField> { get }
```
```javascript
@_spi(AdyenInternal) public struct AddressViewModelBuilderContext
```
```javascript
@_spi(AdyenInternal) public var countryCode: Swift.String { get set }
```
```javascript
@_spi(AdyenInternal) public var isOptional: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) public protocol AddressViewModelBuilder
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.AddressViewModelBuilder>(context: Adyen.AddressViewModelBuilderContext) -> Adyen.AddressViewModel
```
```javascript
@_spi(AdyenInternal) public struct DefaultAddressViewModelBuilder : AddressViewModelBuilder
```
```javascript
@_spi(AdyenInternal) public init() -> Adyen.DefaultAddressViewModelBuilder
```
```javascript
@_spi(AdyenInternal) public func build(context: Adyen.AddressViewModelBuilderContext) -> Adyen.AddressViewModel
```
```javascript
@_spi(AdyenInternal) public final class FormAddressItem : AdyenObserver, FormItem, Hidable
```
```javascript
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get set }
```
```javascript
@_spi(AdyenInternal) override public var value: Adyen.PostalAddress { get set }
```
```javascript
@_spi(AdyenInternal) override public var subitems: [any Adyen.FormItem] { get }
```
```javascript
@_spi(AdyenInternal) public var addressViewModel: Adyen.AddressViewModel { get }
```
```javascript
@_spi(AdyenInternal) override public var title: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public init(initialCountry: Swift.String, configuration: Adyen.FormAddressItem.Configuration, identifier: Swift.String? = $DEFAULT_ARG, presenter: (any Adyen.ViewControllerPresenter)?, addressViewModelBuilder: any Adyen.AddressViewModelBuilder) -> Adyen.FormAddressItem
```
```javascript
@_spi(AdyenInternal) public func updateOptionalStatus(isOptional: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) override public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) public func reset() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public struct Configuration
```
```javascript
@_spi(AdyenInternal) public init(style: Adyen.AddressStyle = $DEFAULT_ARG, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, supportedCountryCodes: [Swift.String]? = $DEFAULT_ARG, showsHeader: Swift.Bool = $DEFAULT_ARG) -> Adyen.FormAddressItem.Configuration
```
```javascript
@_spi(AdyenInternal) public final class FormPostalCodeItem : FormItem, InputViewRequiringFormItem, ValidatableFormItem
```
```javascript
@_spi(AdyenInternal) public init(style: Adyen.FormTextItemStyle = $DEFAULT_ARG, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG) -> Adyen.FormPostalCodeItem
```
```javascript
@_spi(AdyenInternal) public func updateOptionalStatus(isOptional: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) override public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) override public init(style: Adyen.FormTextItemStyle) -> Adyen.FormPostalCodeItem
```
```javascript
@_spi(AdyenInternal) public final class FormRegionPickerItem : FormItem, ValidatableFormItem
```
```javascript
@_spi(AdyenInternal) public required init(preselectedRegion: Adyen.Region?, selectableRegions: [Adyen.Region], validationFailureMessage: Swift.String?, title: Swift.String, placeholder: Swift.String, style: Adyen.FormTextItemStyle, presenter: (any Adyen.ViewControllerPresenter)?, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormRegionPickerItem
```
```javascript
@_spi(AdyenInternal) public func updateValue(with: Adyen.Region?) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) override public func resetValue() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) override public func updateValidationFailureMessage() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) override public func updateFormattedValue() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) override public init(preselectedValue: Adyen.FormPickerElement?, selectableValues: [Adyen.FormPickerElement], title: Swift.String, placeholder: Swift.String, style: Adyen.FormTextItemStyle, presenter: (any Adyen.ViewControllerPresenter)?, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormRegionPickerItem
```
```javascript
@_spi(AdyenInternal) public final class FormAddressPickerItem : FormItem, Hidable, ValidatableFormItem
```
```javascript
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get set }
```
```javascript
@_spi(AdyenInternal) public enum AddressType : Equatable, Hashable
```
```javascript
@_spi(AdyenInternal) public case billing
```
```javascript
@_spi(AdyenInternal) public case delivery
```
```javascript
@_spi(AdyenInternal) public static func __derived_enum_equals(_: Adyen.FormAddressPickerItem.AddressType, _: Adyen.FormAddressPickerItem.AddressType) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public func placeholder(with: Adyen.LocalizationParameters?) -> Swift.String
```
```javascript
@_spi(AdyenInternal) public func title(with: Adyen.LocalizationParameters?) -> Swift.String
```
```javascript
@_spi(AdyenInternal) public var addressViewModel: Adyen.AddressViewModel { get }
```
```javascript
@_spi(AdyenInternal) override public var value: Adyen.PostalAddress? { get set }
```
```javascript
@_spi(AdyenInternal) public init(for: Adyen.FormAddressPickerItem.AddressType, initialCountry: Swift.String, supportedCountryCodes: [Swift.String]?, prefillAddress: Adyen.PostalAddress?, style: Adyen.FormComponentStyle, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, identifier: Swift.String? = $DEFAULT_ARG, addressViewModelBuilder: any Adyen.AddressViewModelBuilder = $DEFAULT_ARG, presenter: any Adyen.ViewControllerPresenter, lookupProvider: (any Adyen.AddressLookupProvider)? = $DEFAULT_ARG) -> Adyen.FormAddressPickerItem
```
```javascript
@_spi(AdyenInternal) public func updateOptionalStatus(isOptional: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) override public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) override public func isValid() -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) override public func validationStatus() -> Adyen.ValidationStatus?
```
```javascript
@_spi(AdyenInternal) override public init(value: Adyen.PostalAddress?, style: Adyen.FormTextItemStyle, placeholder: Swift.String) -> Adyen.FormAddressPickerItem
```
```javascript
@_spi(AdyenInternal) public class FormAttributedLabelItem : FormItem
```
```javascript
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
@_spi(AdyenInternal) public init(originalText: Swift.String, links: [Swift.String], style: Adyen.TextStyle, linkTextStyle: Adyen.TextStyle, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormAttributedLabelItem
```
```javascript
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) public class FormContainerItem : FormItem, Hidable
```
```javascript
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get set }
```
```javascript
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
@_spi(AdyenInternal) public init(content: any Adyen.FormItem, padding: UIKit.UIEdgeInsets = $DEFAULT_ARG, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormContainerItem
```
```javascript
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var content: any Adyen.FormItem { get }
```
```javascript
@_spi(AdyenInternal) public var padding: UIKit.UIEdgeInsets { get set }
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) public class FormLabelItem : FormItem
```
```javascript
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
@_spi(AdyenInternal) public init(text: Swift.String, style: Adyen.TextStyle, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormLabelItem
```
```javascript
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var style: Adyen.TextStyle { get set }
```
```javascript
@_spi(AdyenInternal) public var text: Swift.String { get set }
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) public class FormVerticalStackItemView<FormItemType where FormItemType : Adyen.FormItem> : AdyenCompatible, AdyenObserver, AnyFormItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public var views: [any Adyen.AnyFormItemView] { get }
```
```javascript
@_spi(AdyenInternal) public required init<FormItemType where FormItemType : Adyen.FormItem>(item: FormItemType) -> Adyen.FormVerticalStackItemView<FormItemType>
```
```javascript
@_spi(AdyenInternal) public convenience init<FormItemType where FormItemType : Adyen.FormItem>(item: FormItemType, itemSpacing: CoreGraphics.CGFloat) -> Adyen.FormVerticalStackItemView<FormItemType>
```
```javascript
@_spi(AdyenInternal) override public var childItemViews: [any Adyen.AnyFormItemView] { get }
```
```javascript
@_spi(AdyenInternal) public final class FormButtonItem : FormItem
```
```javascript
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
@_spi(AdyenInternal) public let style: Adyen.FormButtonItemStyle { get }
```
```javascript
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var title: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var $title: Adyen.AdyenObservable<Swift.String?> { get }
```
```javascript
@_spi(AdyenInternal) public var showsActivityIndicator: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) public var $showsActivityIndicator: Adyen.AdyenObservable<Swift.Bool> { get }
```
```javascript
@_spi(AdyenInternal) public var enabled: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) public var $enabled: Adyen.AdyenObservable<Swift.Bool> { get }
```
```javascript
@_spi(AdyenInternal) public var buttonSelectionHandler: (() -> Swift.Void)? { get set }
```
```javascript
@_spi(AdyenInternal) public init(style: Adyen.FormButtonItemStyle) -> Adyen.FormButtonItem
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
public struct FormButtonItemStyle : ViewStyle
```
```javascript
public var button: Adyen.ButtonStyle { get set }
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public init(button: Adyen.ButtonStyle) -> Adyen.FormButtonItemStyle
```
```javascript
public init(button: Adyen.ButtonStyle, background: UIKit.UIColor) -> Adyen.FormButtonItemStyle
```
```javascript
public static func main(font: UIKit.UIFont, textColor: UIKit.UIColor, mainColor: UIKit.UIColor, cornerRadius: CoreGraphics.CGFloat) -> Adyen.FormButtonItemStyle
```
```javascript
public static func main(font: UIKit.UIFont, textColor: UIKit.UIColor, mainColor: UIKit.UIColor) -> Adyen.FormButtonItemStyle
```
```javascript
public static func main(font: UIKit.UIFont, textColor: UIKit.UIColor, mainColor: UIKit.UIColor, cornerRounding: Adyen.CornerRounding) -> Adyen.FormButtonItemStyle
```
```javascript
public static func secondary(font: UIKit.UIFont, textColor: UIKit.UIColor) -> Adyen.FormButtonItemStyle
```
```javascript
@_spi(AdyenInternal) public final class FormSearchButtonItem : FormItem
```
```javascript
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
@_spi(AdyenInternal) public let style: any Adyen.ViewStyle { get }
```
```javascript
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var placeholder: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var $placeholder: Adyen.AdyenObservable<Swift.String?> { get }
```
```javascript
@_spi(AdyenInternal) public let selectionHandler: () -> Swift.Void { get }
```
```javascript
@_spi(AdyenInternal) public init(placeholder: Swift.String, style: any Adyen.ViewStyle, identifier: Swift.String, selectionHandler: () -> Swift.Void) -> Adyen.FormSearchButtonItem
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) public final class FormErrorItem : FormItem, Hidable
```
```javascript
@_spi(AdyenInternal) public var message: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var $message: Adyen.AdyenObservable<Swift.String?> { get }
```
```javascript
@_spi(AdyenInternal) public let iconName: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public let style: Adyen.FormErrorItemStyle { get }
```
```javascript
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get set }
```
```javascript
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
@_spi(AdyenInternal) public init(message: Swift.String? = $DEFAULT_ARG, iconName: Swift.String = $DEFAULT_ARG, style: Adyen.FormErrorItemStyle = $DEFAULT_ARG) -> Adyen.FormErrorItem
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
public struct FormErrorItemStyle : ViewStyle
```
```javascript
public var message: Adyen.TextStyle { get set }
```
```javascript
public var cornerRounding: Adyen.CornerRounding { get set }
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public init(message: Adyen.TextStyle) -> Adyen.FormErrorItemStyle
```
```javascript
public init() -> Adyen.FormErrorItemStyle
```
```javascript
@_spi(AdyenInternal) public class FormImageItem : FormItem, Hidable
```
```javascript
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get set }
```
```javascript
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
@_spi(AdyenInternal) public var name: Swift.String { get set }
```
```javascript
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var size: CoreFoundation.CGSize { get set }
```
```javascript
@_spi(AdyenInternal) public var style: Adyen.ImageStyle? { get set }
```
```javascript
@_spi(AdyenInternal) public init(name: Swift.String, size: CoreFoundation.CGSize? = $DEFAULT_ARG, style: Adyen.ImageStyle? = $DEFAULT_ARG, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormImageItem
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) public protocol Hidable
```
```javascript
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get }
```
```javascript
@_spi(AdyenInternal) public var isVisible: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) public protocol FormItem<Self : AnyObject>
```
```javascript
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get }
```
```javascript
@_spi(AdyenInternal) public func build<Self where Self : Adyen.FormItem>(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) public func addingDefaultMargins<Self where Self : Adyen.FormItem>() -> Adyen.FormContainerItem
```
```javascript
@_spi(AdyenInternal) public var flatSubitems: [any Adyen.FormItem] { get }
```
```javascript
@_spi(AdyenInternal) public protocol ValidatableFormItem<Self : Adyen.FormItem> : FormItem
```
```javascript
@_spi(AdyenInternal) public var validationFailureMessage: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public func isValid<Self where Self : Adyen.ValidatableFormItem>() -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public protocol InputViewRequiringFormItem<Self : Adyen.FormItem> : FormItem
```
```javascript
@_spi(AdyenInternal) public class FormItemView<ItemType where ItemType : Adyen.FormItem> : AdyenCompatible, AdyenObserver, AnyFormItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public let item: ItemType { get }
```
```javascript
@_spi(AdyenInternal) public required init<ItemType where ItemType : Adyen.FormItem>(item: ItemType) -> Adyen.FormItemView<ItemType>
```
```javascript
@_spi(AdyenInternal) public var childItemViews: [any Adyen.AnyFormItemView] { get }
```
```javascript
@_spi(AdyenInternal) public func reset<ItemType where ItemType : Adyen.FormItem>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init<ItemType where ItemType : Adyen.FormItem>(frame: CoreFoundation.CGRect) -> Adyen.FormItemView<ItemType>
```
```javascript
@_spi(AdyenInternal) public protocol AnyFormItemView<Self : UIKit.UIView>
```
```javascript
@_spi(AdyenInternal) public var parentItemView: (any Adyen.AnyFormItemView)? { get }
```
```javascript
@_spi(AdyenInternal) public var childItemViews: [any Adyen.AnyFormItemView] { get }
```
```javascript
@_spi(AdyenInternal) public func reset<Self where Self : Adyen.AnyFormItemView>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public var parentItemView: (any Adyen.AnyFormItemView)? { get }
```
```javascript
@_spi(AdyenInternal) public var flatSubitemViews: [any Adyen.AnyFormItemView] { get }
```
```javascript
@_spi(AdyenInternal) public final class FormPhoneNumberItem : FormItem, InputViewRequiringFormItem, ValidatableFormItem
```
```javascript
@_spi(AdyenInternal) public var prefix: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public var phoneNumber: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public init(phoneNumber: Adyen.PhoneNumber?, selectableValues: [Adyen.PhoneExtension], style: Adyen.FormTextItemStyle, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, presenter: Adyen.WeakReferenceViewControllerPresenter) -> Adyen.FormPhoneNumberItem
```
```javascript
@_spi(AdyenInternal) override public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) override public init(style: Adyen.FormTextItemStyle) -> Adyen.FormPhoneNumberItem
```
```javascript
@_spi(AdyenInternal) public final class FormPhoneExtensionPickerItem : FormItem, ValidatableFormItem
```
```javascript
@_spi(AdyenInternal) public required init(preselectedExtension: Adyen.PhoneExtension?, selectableExtensions: [Adyen.PhoneExtension], validationFailureMessage: Swift.String?, style: Adyen.FormTextItemStyle, presenter: Adyen.WeakReferenceViewControllerPresenter, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormPhoneExtensionPickerItem
```
```javascript
@_spi(AdyenInternal) override public func resetValue() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) override public func updateValidationFailureMessage() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) override public func updateFormattedValue() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) override public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) override public init(preselectedValue: Adyen.PhoneExtension?, selectableValues: [Adyen.PhoneExtension], title: Swift.String, placeholder: Swift.String, style: Adyen.FormTextItemStyle, presenter: (any Adyen.ViewControllerPresenter)?, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormPhoneExtensionPickerItem
```
```javascript
@_spi(AdyenInternal) public final class FormPhoneExtensionPickerItemView : AdyenCompatible, AdyenObserver, AnyFormItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) @objc override public var accessibilityIdentifier: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public required init(item: Adyen.FormPhoneExtensionPickerItem) -> Adyen.FormPhoneExtensionPickerItemView
```
```javascript
@_spi(AdyenInternal) public final class FormSegmentedControlItem : FormItem
```
```javascript
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var style: Adyen.SegmentedControlStyle { get set }
```
```javascript
@_spi(AdyenInternal) public var selectionHandler: ((Swift.Int) -> Swift.Void)? { get set }
```
```javascript
@_spi(AdyenInternal) public init(items: [Swift.String], style: Adyen.SegmentedControlStyle, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormSegmentedControlItem
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) public class SelectableFormItem : FormItem, Hidable
```
```javascript
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
@_spi(AdyenInternal) public var title: Swift.String { get set }
```
```javascript
@_spi(AdyenInternal) public var imageUrl: Foundation.URL? { get set }
```
```javascript
@_spi(AdyenInternal) public var isSelected: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) public var $isSelected: Adyen.AdyenObservable<Swift.Bool> { get }
```
```javascript
@_spi(AdyenInternal) public var selectionHandler: (() -> Swift.Void)? { get set }
```
```javascript
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public let accessibilityLabel: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public let style: Adyen.SelectableFormItemStyle { get }
```
```javascript
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get set }
```
```javascript
@_spi(AdyenInternal) public init(title: Swift.String, imageUrl: Foundation.URL? = $DEFAULT_ARG, isSelected: Swift.Bool = $DEFAULT_ARG, style: Adyen.SelectableFormItemStyle, identifier: Swift.String? = $DEFAULT_ARG, accessibilityLabel: Swift.String? = $DEFAULT_ARG, selectionHandler: (() -> Swift.Void)? = $DEFAULT_ARG) -> Adyen.SelectableFormItem
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) public struct SelectableFormItemStyle : Equatable, ViewStyle
```
```javascript
@_spi(AdyenInternal) public var title: Adyen.TextStyle { get set }
```
```javascript
@_spi(AdyenInternal) public var imageStyle: Adyen.ImageStyle { get set }
```
```javascript
@_spi(AdyenInternal) public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
@_spi(AdyenInternal) public init(title: Adyen.TextStyle) -> Adyen.SelectableFormItemStyle
```
```javascript
@_spi(AdyenInternal) public static func ==(_: Adyen.SelectableFormItemStyle, _: Adyen.SelectableFormItemStyle) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public final class SelectableFormItemView : AdyenCompatible, AdyenObserver, AnyFormItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public required init(item: Adyen.SelectableFormItem) -> Adyen.SelectableFormItemView
```
```javascript
@_spi(AdyenInternal) @objc override public func didMoveToWindow() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public func layoutSubviews() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public final class FormSeparatorItem : FormItem
```
```javascript
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
@_spi(AdyenInternal) public let color: UIKit.UIColor { get }
```
```javascript
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public init(color: UIKit.UIColor) -> Adyen.FormSeparatorItem
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) public final class FormSpacerItem : FormItem
```
```javascript
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public let subitems: [any Adyen.FormItem] { get }
```
```javascript
@_spi(AdyenInternal) public let standardSpaceMultiplier: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public init(numberOfSpaces: Swift.Int = $DEFAULT_ARG) -> Adyen.FormSpacerItem
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) public final class FormSpacerItemView : AdyenCompatible, AdyenObserver, AnyFormItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public final class FormSplitItem : FormItem
```
```javascript
@_spi(AdyenInternal) public let style: any Adyen.ViewStyle { get }
```
```javascript
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get }
```
```javascript
@_spi(AdyenInternal) public init(items: any Adyen.FormItem..., style: any Adyen.ViewStyle) -> Adyen.FormSplitItem
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) public final class FormTextInputItem : FormItem, Hidable, InputViewRequiringFormItem, ValidatableFormItem
```
```javascript
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get set }
```
```javascript
@_spi(AdyenInternal) public var isEnabled: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) public var $isEnabled: Adyen.AdyenObservable<Swift.Bool> { get }
```
```javascript
@_spi(AdyenInternal) override public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) override public init(style: Adyen.FormTextItemStyle = $DEFAULT_ARG) -> Adyen.FormTextInputItem
```
```javascript
@_spi(AdyenInternal) override public func isValid() -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func focus() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public final class FormTextInputItemView : AdyenCompatible, AdyenObserver, AnyFormItemView, AnyFormTextItemView, AnyFormValidatableValueItemView, AnyFormValueItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITextFieldDelegate, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public required init(item: Adyen.FormTextInputItem) -> Adyen.FormTextInputItemView
```
```javascript
@_spi(AdyenInternal) public class FormTextItem : FormItem, InputViewRequiringFormItem, ValidatableFormItem
```
```javascript
@_spi(AdyenInternal) public var placeholder: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var $placeholder: Adyen.AdyenObservable<Swift.String?> { get }
```
```javascript
@_spi(AdyenInternal) override public var value: Swift.String { get set }
```
```javascript
@_spi(AdyenInternal) public var formatter: (any Adyen.Formatter)? { get set }
```
```javascript
@_spi(AdyenInternal) public var validator: (any Adyen.Validator)? { get set }
```
```javascript
@_spi(AdyenInternal) public var autocapitalizationType: UIKit.UITextAutocapitalizationType { get set }
```
```javascript
@_spi(AdyenInternal) public var autocorrectionType: UIKit.UITextAutocorrectionType { get set }
```
```javascript
@_spi(AdyenInternal) public var keyboardType: UIKit.UIKeyboardType { get set }
```
```javascript
@_spi(AdyenInternal) public var contentType: UIKit.UITextContentType? { get set }
```
```javascript
@_spi(AdyenInternal) public var allowsValidationWhileEditing: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) public var onDidBeginEditing: (() -> Swift.Void)? { get set }
```
```javascript
@_spi(AdyenInternal) public var onDidEndEditing: (() -> Swift.Void)? { get set }
```
```javascript
@_spi(AdyenInternal) public init(style: Adyen.FormTextItemStyle) -> Adyen.FormTextItem
```
```javascript
@_spi(AdyenInternal) override public func isValid() -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) override public func validationStatus() -> Adyen.ValidationStatus?
```
```javascript
public struct FormTextItemStyle : FormValueItemStyle, TintableStyle, ViewStyle
```
```javascript
public var title: Adyen.TextStyle { get set }
```
```javascript
public var text: Adyen.TextStyle { get set }
```
```javascript
public var placeholderText: Adyen.TextStyle? { get set }
```
```javascript
public var icon: Adyen.ImageStyle { get set }
```
```javascript
public var tintColor: UIKit.UIColor? { get set }
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public var errorColor: UIKit.UIColor { get set }
```
```javascript
public var separatorColor: UIKit.UIColor? { get set }
```
```javascript
public init(title: Adyen.TextStyle, text: Adyen.TextStyle, placeholderText: Adyen.TextStyle? = $DEFAULT_ARG, icon: Adyen.ImageStyle) -> Adyen.FormTextItemStyle
```
```javascript
public init(tintColor: UIKit.UIColor) -> Adyen.FormTextItemStyle
```
```javascript
public init() -> Adyen.FormTextItemStyle
```
```javascript
@_spi(AdyenInternal) public protocol FormTextItemViewDelegate<Self : AnyObject>
```
```javascript
@_spi(AdyenInternal) public func didReachMaximumLength<Self, T where Self : Adyen.FormTextItemViewDelegate, T : Adyen.FormTextItem>(in: Adyen.FormTextItemView<T>) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func didSelectReturnKey<Self, T where Self : Adyen.FormTextItemViewDelegate, T : Adyen.FormTextItem>(in: Adyen.FormTextItemView<T>) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public protocol AnyFormTextItemView<Self : Adyen.AnyFormItemView> : AnyFormItemView
```
```javascript
@_spi(AdyenInternal) public var delegate: (any Adyen.FormTextItemViewDelegate)? { get set }
```
```javascript
@_spi(AdyenInternal) public class FormTextItemView<ItemType where ItemType : Adyen.FormTextItem> : AdyenCompatible, AdyenObserver, AnyFormItemView, AnyFormTextItemView, AnyFormValidatableValueItemView, AnyFormValueItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITextFieldDelegate, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) override public var accessibilityLabelView: UIKit.UIView? { get }
```
```javascript
@_spi(AdyenInternal) public required init<ItemType where ItemType : Adyen.FormTextItem>(item: ItemType) -> Adyen.FormTextItemView<ItemType>
```
```javascript
@_spi(AdyenInternal) override public func reset<ItemType where ItemType : Adyen.FormTextItem>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public weak var delegate: (any Adyen.FormTextItemViewDelegate)? { get set }
```
```javascript
@_spi(AdyenInternal) public lazy var textField: Adyen.TextField { get set }
```
```javascript
@_spi(AdyenInternal) public var accessory: Adyen.FormTextItemView<ItemType>.AccessoryType { get set }
```
```javascript
@_spi(AdyenInternal) override public var isValid: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) override public func showValidation<ItemType where ItemType : Adyen.FormTextItem>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) override public func configureSeparatorView<ItemType where ItemType : Adyen.FormTextItem>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic var lastBaselineAnchor: UIKit.NSLayoutYAxisAnchor { get }
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic var canBecomeFirstResponder: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) @discardableResult @objc override public dynamic func becomeFirstResponder<ItemType where ItemType : Adyen.FormTextItem>() -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) @discardableResult @objc override public dynamic func resignFirstResponder<ItemType where ItemType : Adyen.FormTextItem>() -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic var isFirstResponder: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) @objc public func textFieldShouldReturn<ItemType where ItemType : Adyen.FormTextItem>(_: UIKit.UITextField) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) @objc public func textFieldDidEndEditing<ItemType where ItemType : Adyen.FormTextItem>(_: UIKit.UITextField) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc public func textFieldDidBeginEditing<ItemType where ItemType : Adyen.FormTextItem>(_: UIKit.UITextField) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) override public func updateValidationStatus<ItemType where ItemType : Adyen.FormTextItem>(forced: Swift.Bool = $DEFAULT_ARG) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func notifyDelegateOfMaxLengthIfNeeded<ItemType where ItemType : Adyen.FormTextItem>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public enum AccessoryType<ItemType where ItemType : Adyen.FormTextItem> : Equatable
```
```javascript
@_spi(AdyenInternal) public case invalid
```
```javascript
@_spi(AdyenInternal) public case valid
```
```javascript
@_spi(AdyenInternal) public case customView(UIKit.UIView)
```
```javascript
@_spi(AdyenInternal) public case none
```
```javascript
@_spi(AdyenInternal) public static func __derived_enum_equals<ItemType where ItemType : Adyen.FormTextItem>(_: Adyen.FormTextItemView<ItemType>.AccessoryType, _: Adyen.FormTextItemView<ItemType>.AccessoryType) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) @objc public final class TextField : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UIContentSizeCategoryAdjusting, UIContextMenuInteractionDelegate, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UIKeyInput, UILargeContentViewerItem, UILetterformAwareAdjusting, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITextDraggable, UITextDroppable, UITextInput, UITextInputTraits, UITextPasteConfigurationSupporting, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public var allowsEditingActions: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) @objc override public var accessibilityValue: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) @objc override public var font: UIKit.UIFont? { get set }
```
```javascript
@_spi(AdyenInternal) @objc override public func canPerformAction(_: ObjectiveC.Selector, withSender: Any?) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init(frame: CoreFoundation.CGRect) -> Adyen.TextField
```
```javascript
@_spi(AdyenInternal) @objc public required dynamic init(coder: Foundation.NSCoder) -> Adyen.TextField?
```
```javascript
@_spi(AdyenInternal) public func apply(placeholderText: Swift.String?, with: Adyen.TextStyle?) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public final class FormToggleItem : FormItem, Hidable
```
```javascript
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get set }
```
```javascript
@_spi(AdyenInternal) public init(style: Adyen.FormToggleItemStyle = $DEFAULT_ARG) -> Adyen.FormToggleItem
```
```javascript
@_spi(AdyenInternal) override public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
public struct FormToggleItemStyle : FormValueItemStyle, TintableStyle, ViewStyle
```
```javascript
public var title: Adyen.TextStyle { get set }
```
```javascript
public var tintColor: UIKit.UIColor? { get set }
```
```javascript
public var separatorColor: UIKit.UIColor? { get set }
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public init(title: Adyen.TextStyle) -> Adyen.FormToggleItemStyle
```
```javascript
public init() -> Adyen.FormToggleItemStyle
```
```javascript
@_spi(AdyenInternal) public final class FormToggleItemView : AdyenCompatible, AdyenObserver, AnyFormItemView, AnyFormValueItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public required init(item: Adyen.FormToggleItem) -> Adyen.FormToggleItemView
```
```javascript
@_spi(AdyenInternal) @discardableResult @objc override public func accessibilityActivate() -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) override public func reset() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public protocol PickerElement<Self : Swift.CustomStringConvertible, Self : Swift.Equatable> : CustomStringConvertible, Equatable
```
```javascript
@_spi(AdyenInternal) public var identifier: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public struct BasePickerElement<ElementType where ElementType : Swift.CustomStringConvertible> : CustomStringConvertible, Equatable, PickerElement
```
```javascript
@_spi(AdyenInternal) public let identifier: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public let element: ElementType { get }
```
```javascript
@_spi(AdyenInternal) public static func ==<ElementType where ElementType : Swift.CustomStringConvertible>(_: Adyen.BasePickerElement<ElementType>, _: Adyen.BasePickerElement<ElementType>) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public var description: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public init<ElementType where ElementType : Swift.CustomStringConvertible>(identifier: Swift.String, element: ElementType) -> Adyen.BasePickerElement<ElementType>
```
```javascript
@_spi(AdyenInternal) public class BaseFormPickerItem<ElementType where ElementType : Swift.CustomStringConvertible> : FormItem, Hidable, InputViewRequiringFormItem
```
```javascript
@_spi(AdyenInternal) public var isHidden: Adyen.AdyenObservable<Swift.Bool> { get set }
```
```javascript
@_spi(AdyenInternal) public var selectableValues: [Adyen.BasePickerElement<ElementType>] { get set }
```
```javascript
@_spi(AdyenInternal) public var $selectableValues: Adyen.AdyenObservable<[Adyen.BasePickerElement<ElementType>]> { get }
```
```javascript
@_spi(AdyenInternal) public init<ElementType where ElementType : Swift.CustomStringConvertible>(preselectedValue: Adyen.BasePickerElement<ElementType>, selectableValues: [Adyen.BasePickerElement<ElementType>], style: Adyen.FormTextItemStyle) -> Adyen.BaseFormPickerItem<ElementType>
```
```javascript
@_spi(AdyenInternal) public class BaseFormPickerItemView<T where T : Swift.CustomStringConvertible, T : Swift.Equatable> : AdyenCompatible, AdyenObserver, AnyFormItemView, AnyFormValueItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public required init<T where T : Swift.CustomStringConvertible, T : Swift.Equatable>(item: Adyen.BaseFormPickerItem<T>) -> Adyen.BaseFormPickerItemView<T>
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic var canBecomeFirstResponder: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) @discardableResult @objc override public dynamic func becomeFirstResponder<T where T : Swift.CustomStringConvertible, T : Swift.Equatable>() -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) @discardableResult @objc override public dynamic func resignFirstResponder<T where T : Swift.CustomStringConvertible, T : Swift.Equatable>() -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func initialize<T where T : Swift.CustomStringConvertible, T : Swift.Equatable>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public lazy var inputControl: any Adyen.PickerTextInputControl { get set }
```
```javascript
@_spi(AdyenInternal) @objc public func numberOfComponents<T where T : Swift.CustomStringConvertible, T : Swift.Equatable>(in: UIKit.UIPickerView) -> Swift.Int
```
```javascript
@_spi(AdyenInternal) @objc public func pickerView<T where T : Swift.CustomStringConvertible, T : Swift.Equatable>(_: UIKit.UIPickerView, numberOfRowsInComponent: Swift.Int) -> Swift.Int
```
```javascript
@_spi(AdyenInternal) @objc public func pickerView<T where T : Swift.CustomStringConvertible, T : Swift.Equatable>(_: UIKit.UIPickerView, titleForRow: Swift.Int, forComponent: Swift.Int) -> Swift.String?
```
```javascript
@_spi(AdyenInternal) @objc public func pickerView<T where T : Swift.CustomStringConvertible, T : Swift.Equatable>(_: UIKit.UIPickerView, didSelectRow: Swift.Int, inComponent: Swift.Int) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public protocol PickerTextInputControl<Self : UIKit.UIView>
```
```javascript
@_spi(AdyenInternal) public var onDidResignFirstResponder: (() -> Swift.Void)? { get set }
```
```javascript
@_spi(AdyenInternal) public var onDidBecomeFirstResponder: (() -> Swift.Void)? { get set }
```
```javascript
@_spi(AdyenInternal) public var onDidTap: (() -> Swift.Void)? { get set }
```
```javascript
@_spi(AdyenInternal) public var showChevron: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) public var label: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public typealias IssuerPickerItem = Adyen.BasePickerElement<Adyen.Issuer>
```
```javascript
@_spi(AdyenInternal) public final class FormIssuersPickerItem : FormItem, Hidable, InputViewRequiringFormItem
```
```javascript
@_spi(AdyenInternal) override public init(preselectedValue: Adyen.IssuerPickerItem, selectableValues: [Adyen.IssuerPickerItem], style: Adyen.FormTextItemStyle) -> Adyen.FormIssuersPickerItem
```
```javascript
@_spi(AdyenInternal) override public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
public protocol FormValueItemStyle<Self : Adyen.TintableStyle> : TintableStyle, ViewStyle
```
```javascript
public var separatorColor: UIKit.UIColor? { get }
```
```javascript
public var title: Adyen.TextStyle { get }
```
```javascript
@_spi(AdyenInternal) public class FormValueItem<ValueType, StyleType where ValueType : Swift.Equatable, StyleType : Adyen.FormValueItemStyle> : FormItem
```
```javascript
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get }
```
```javascript
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var value: ValueType { get set }
```
```javascript
@_spi(AdyenInternal) public var publisher: Adyen.AdyenObservable<ValueType> { get set }
```
```javascript
@_spi(AdyenInternal) public var style: StyleType { get set }
```
```javascript
@_spi(AdyenInternal) public var title: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var $title: Adyen.AdyenObservable<Swift.String?> { get }
```
```javascript
@_spi(AdyenInternal) public func build<ValueType, StyleType where ValueType : Swift.Equatable, StyleType : Adyen.FormValueItemStyle>(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) public class FormValueItemView<ValueType, Style, ItemType where ValueType : Swift.Equatable, Style : Adyen.FormValueItemStyle, ItemType : Adyen.FormValueItem<ValueType, Style>> : AdyenCompatible, AdyenObserver, AnyFormItemView, AnyFormValueItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public lazy var titleLabel: UIKit.UILabel { get set }
```
```javascript
@_spi(AdyenInternal) public required init<ValueType, Style, ItemType where ValueType : Swift.Equatable, Style : Adyen.FormValueItemStyle, ItemType : Adyen.FormValueItem<ValueType, Style>>(item: ItemType) -> Adyen.FormValueItemView<ValueType, Style, ItemType>
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic func didAddSubview<ValueType, Style, ItemType where ValueType : Swift.Equatable, Style : Adyen.FormValueItemStyle, ItemType : Adyen.FormValueItem<ValueType, Style>>(_: UIKit.UIView) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public var isEditing: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) public var showsSeparator: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) public func configureSeparatorView<ValueType, Style, ItemType where ValueType : Swift.Equatable, Style : Adyen.FormValueItemStyle, ItemType : Adyen.FormValueItem<ValueType, Style>>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public protocol AnyFormValueItemView<Self : Adyen.AnyFormItemView> : AnyFormItemView
```
```javascript
@_spi(AdyenInternal) public var isEditing: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) public protocol FormPickable<Self : Swift.Equatable> : Equatable
```
```javascript
@_spi(AdyenInternal) public var identifier: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public var icon: UIKit.UIImage? { get }
```
```javascript
@_spi(AdyenInternal) public var title: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public var subtitle: Swift.String? { get }
```
```javascript
@_spi(AdyenInternal) public var trailingText: Swift.String? { get }
```
```javascript
@_spi(AdyenInternal) public struct FormPickerElement : Equatable, FormPickable
```
```javascript
@_spi(AdyenInternal) public let identifier: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public let icon: UIKit.UIImage? { get }
```
```javascript
@_spi(AdyenInternal) public let title: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public let subtitle: Swift.String? { get }
```
```javascript
@_spi(AdyenInternal) public let trailingText: Swift.String? { get }
```
```javascript
@_spi(AdyenInternal) public init(identifier: Swift.String, icon: UIKit.UIImage? = $DEFAULT_ARG, title: Swift.String, subtitle: Swift.String? = $DEFAULT_ARG, trailingText: Swift.String? = $DEFAULT_ARG) -> Adyen.FormPickerElement
```
```javascript
@_spi(AdyenInternal) public static func __derived_struct_equals(_: Adyen.FormPickerElement, _: Adyen.FormPickerElement) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public class FormPickerItem<Value where Value : Adyen.FormPickable> : FormItem, ValidatableFormItem
```
```javascript
@_spi(AdyenInternal) public let localizationParameters: Adyen.LocalizationParameters? { get }
```
```javascript
@_spi(AdyenInternal) public var isOptional: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) override public var value: Value? { get set }
```
```javascript
@_spi(AdyenInternal) public var selectableValues: [Value] { get set }
```
```javascript
@_spi(AdyenInternal) public var $selectableValues: Adyen.AdyenObservable<[Value]> { get }
```
```javascript
@_spi(AdyenInternal) public init<Value where Value : Adyen.FormPickable>(preselectedValue: Value?, selectableValues: [Value], title: Swift.String, placeholder: Swift.String, style: Adyen.FormTextItemStyle, presenter: (any Adyen.ViewControllerPresenter)?, localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, identifier: Swift.String? = $DEFAULT_ARG) -> Adyen.FormPickerItem<Value>
```
```javascript
@_spi(AdyenInternal) public func updateOptionalStatus<Value where Value : Adyen.FormPickable>(isOptional: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func resetValue<Value where Value : Adyen.FormPickable>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) override public func build<Value where Value : Adyen.FormPickable>(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) override public func isValid<Value where Value : Adyen.FormPickable>() -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) override public func validationStatus<Value where Value : Adyen.FormPickable>() -> Adyen.ValidationStatus?
```
```javascript
@_spi(AdyenInternal) public func updateValidationFailureMessage<Value where Value : Adyen.FormPickable>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func updateFormattedValue<Value where Value : Adyen.FormPickable>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) override public init<Value where Value : Adyen.FormPickable>(value: Value?, style: Adyen.FormTextItemStyle, placeholder: Swift.String) -> Adyen.FormPickerItem<Value>
```
```javascript
@_spi(AdyenInternal) public class FormPickerItemView<Value where Value : Adyen.FormPickable> : AdyenCompatible, AdyenObserver, AnyFormItemView, AnyFormValidatableValueItemView, AnyFormValueItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) override public func showValidation<Value where Value : Adyen.FormPickable>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) override public func reset<Value where Value : Adyen.FormPickable>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public final class FormPickerSearchViewController<Option where Option : Adyen.FormPickable> : AdyenCompatible, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSExtensionRequestHandling, NSObjectProtocol, Sendable, UIActivityItemsConfigurationProviding, UIAppearanceContainer, UIContentContainer, UIFocusEnvironment, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UIStateRestoring, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring, ViewControllerPresenter
```
```javascript
@_spi(AdyenInternal) public init<Option where Option : Adyen.FormPickable>(localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, style: Adyen.FormPickerSearchViewController<Option>.Style = $DEFAULT_ARG, title: Swift.String?, options: [Option], selectionHandler: (Option) -> Swift.Void) -> Adyen.FormPickerSearchViewController<Option>
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init<Option where Option : Adyen.FormPickable>(navigationBarClass: Swift.AnyClass?, toolbarClass: Swift.AnyClass?) -> Adyen.FormPickerSearchViewController<Option>
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init<Option where Option : Adyen.FormPickable>(rootViewController: UIKit.UIViewController) -> Adyen.FormPickerSearchViewController<Option>
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init<Option where Option : Adyen.FormPickable>(nibName: Swift.String?, bundle: Foundation.Bundle?) -> Adyen.FormPickerSearchViewController<Option>
```
```javascript
@_spi(AdyenInternal) public class EmptyView<Option where Option : Adyen.FormPickable> : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, SearchResultsEmptyView, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) override public var searchTerm: Swift.String { get set }
```
```javascript
@_spi(AdyenInternal) public struct Style<Option where Option : Adyen.FormPickable> : ViewStyle
```
```javascript
@_spi(AdyenInternal) public var title: Adyen.TextStyle { get set }
```
```javascript
@_spi(AdyenInternal) public var subtitle: Adyen.TextStyle { get set }
```
```javascript
@_spi(AdyenInternal) public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
@_spi(AdyenInternal) public init<Option where Option : Adyen.FormPickable>() -> Adyen.FormPickerSearchViewController<Option>.EmptyView.Style
```
```javascript
@_spi(AdyenInternal) public struct Style<Option where Option : Adyen.FormPickable> : ViewStyle
```
```javascript
@_spi(AdyenInternal) public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
@_spi(AdyenInternal) public var emptyView: Adyen.FormPickerSearchViewController<Option>.EmptyView.Style { get set }
```
```javascript
@_spi(AdyenInternal) public init<Option where Option : Adyen.FormPickable>() -> Adyen.FormPickerSearchViewController<Option>.Style
```
```javascript
@_spi(AdyenInternal) public class FormSelectableValueItem<ValueType where ValueType : Swift.Equatable> : FormItem, ValidatableFormItem
```
```javascript
@_spi(AdyenInternal) public let placeholder: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public var selectionHandler: () -> Swift.Void { get set }
```
```javascript
@_spi(AdyenInternal) public var formattedValue: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var $formattedValue: Adyen.AdyenObservable<Swift.String?> { get }
```
```javascript
@_spi(AdyenInternal) public init<ValueType where ValueType : Swift.Equatable>(value: ValueType, style: Adyen.FormTextItemStyle, placeholder: Swift.String) -> Adyen.FormSelectableValueItem<ValueType>
```
```javascript
@_spi(AdyenInternal) public class FormSelectableValueItemView<ValueType, ItemType where ValueType : Swift.Equatable, ItemType : Adyen.FormSelectableValueItem<ValueType?>> : AdyenCompatible, AdyenObserver, AnyFormItemView, AnyFormValidatableValueItemView, AnyFormValueItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public required init<ValueType, ItemType where ValueType : Swift.Equatable, ItemType : Adyen.FormSelectableValueItem<ValueType?>>(item: ItemType) -> Adyen.FormSelectableValueItemView<ValueType, ItemType>
```
```javascript
@_spi(AdyenInternal) public class FormValidatableValueItem<ValueType where ValueType : Swift.Equatable> : FormItem, ValidatableFormItem
```
```javascript
@_spi(AdyenInternal) public var validationFailureMessage: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var $validationFailureMessage: Adyen.AdyenObservable<Swift.String?> { get }
```
```javascript
@_spi(AdyenInternal) public var onDidShowValidationError: ((any Adyen.ValidationError) -> Swift.Void)? { get set }
```
```javascript
@_spi(AdyenInternal) public func isValid<ValueType where ValueType : Swift.Equatable>() -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func validationStatus<ValueType where ValueType : Swift.Equatable>() -> Adyen.ValidationStatus?
```
```javascript
@_spi(AdyenInternal) public class FormValidatableValueItemView<ValueType, ItemType where ValueType : Swift.Equatable, ItemType : Adyen.FormValidatableValueItem<ValueType>> : AdyenCompatible, AdyenObserver, AnyFormItemView, AnyFormValidatableValueItemView, AnyFormValueItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public required init<ValueType, ItemType where ValueType : Swift.Equatable, ItemType : Adyen.FormValidatableValueItem<ValueType>>(item: ItemType) -> Adyen.FormValidatableValueItemView<ValueType, ItemType>
```
```javascript
@_spi(AdyenInternal) override public func configureSeparatorView<ValueType, ItemType where ValueType : Swift.Equatable, ItemType : Adyen.FormValidatableValueItem<ValueType>>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public var isValid: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) public func showValidation<ValueType, ItemType where ValueType : Swift.Equatable, ItemType : Adyen.FormValidatableValueItem<ValueType>>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func updateValidationStatus<ValueType, ItemType where ValueType : Swift.Equatable, ItemType : Adyen.FormValidatableValueItem<ValueType>>(forced: Swift.Bool = $DEFAULT_ARG) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public protocol AnyFormValidatableValueItemView<Self : Adyen.AnyFormValueItemView> : AnyFormItemView, AnyFormValueItemView
```
```javascript
@_spi(AdyenInternal) public func showValidation<Self where Self : Adyen.AnyFormValidatableValueItemView>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public var isValid: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) @objc public final class ListCell : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UIGestureRecognizerDelegate, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init(style: UIKit.UITableViewCell.CellStyle, reuseIdentifier: Swift.String?) -> Adyen.ListCell
```
```javascript
@_spi(AdyenInternal) public var item: Adyen.ListItem? { get set }
```
```javascript
@_spi(AdyenInternal) public class ListItem : Equatable, FormItem, Hashable
```
```javascript
@_spi(AdyenInternal) public var subitems: [any Adyen.FormItem] { get set }
```
```javascript
@_spi(AdyenInternal) public let style: Adyen.ListItemStyle { get }
```
```javascript
@_spi(AdyenInternal) public var title: Swift.String { get set }
```
```javascript
@_spi(AdyenInternal) public var subtitle: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var icon: Adyen.ListItem.Icon? { get set }
```
```javascript
@_spi(AdyenInternal) public var trailingText: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var selectionHandler: (() -> Swift.Void)? { get set }
```
```javascript
@_spi(AdyenInternal) public var deletionHandler: ((Foundation.IndexPath, @escaping Adyen.Completion<Swift.Bool>) -> Swift.Void)? { get set }
```
```javascript
@_spi(AdyenInternal) public var identifier: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public let accessibilityLabel: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public init(title: Swift.String, subtitle: Swift.String? = $DEFAULT_ARG, icon: Adyen.ListItem.Icon? = $DEFAULT_ARG, trailingText: Swift.String? = $DEFAULT_ARG, style: Adyen.ListItemStyle = $DEFAULT_ARG, identifier: Swift.String? = $DEFAULT_ARG, accessibilityLabel: Swift.String? = $DEFAULT_ARG, selectionHandler: (() -> Swift.Void)? = $DEFAULT_ARG) -> Adyen.ListItem
```
```javascript
@_spi(AdyenInternal) public func build(with: Adyen.FormItemViewBuilder) -> any Adyen.AnyFormItemView
```
```javascript
@_spi(AdyenInternal) public func startLoading() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func stopLoading() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public struct Icon : Equatable, Hashable
```
```javascript
@_spi(AdyenInternal) public enum Location : Equatable, Hashable
```
```javascript
@_spi(AdyenInternal) public case local(image: UIKit.UIImage)
```
```javascript
@_spi(AdyenInternal) public case remote(url: Foundation.URL?)
```
```javascript
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public static func __derived_enum_equals(_: Adyen.ListItem.Icon.Location, _: Adyen.ListItem.Icon.Location) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public let location: Adyen.ListItem.Icon.Location { get }
```
```javascript
@_spi(AdyenInternal) public let canBeModified: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) public init(location: Adyen.ListItem.Icon.Location, canBeModified: Swift.Bool = $DEFAULT_ARG) -> Adyen.ListItem.Icon
```
```javascript
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public static func __derived_struct_equals(_: Adyen.ListItem.Icon, _: Adyen.ListItem.Icon) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public init(url: Foundation.URL?, canBeModified: Swift.Bool = $DEFAULT_ARG) -> Adyen.ListItem.Icon
```
```javascript
@_spi(AdyenInternal) public init(image: UIKit.UIImage, canBeModified: Swift.Bool = $DEFAULT_ARG) -> Adyen.ListItem.Icon
```
```javascript
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public static func ==(_: Adyen.ListItem, _: Adyen.ListItem) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
public struct ListItemStyle : Equatable, ViewStyle
```
```javascript
public var title: Adyen.TextStyle { get set }
```
```javascript
public var subtitle: Adyen.TextStyle { get set }
```
```javascript
public var trailingText: Adyen.TextStyle { get set }
```
```javascript
public var image: Adyen.ImageStyle { get set }
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public init(title: Adyen.TextStyle, subtitle: Adyen.TextStyle, image: Adyen.ImageStyle) -> Adyen.ListItemStyle
```
```javascript
public init() -> Adyen.ListItemStyle
```
```javascript
public static func ==(_: Adyen.ListItemStyle, _: Adyen.ListItemStyle) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) @objc public final class ListItemView : AdyenCompatible, AnyFormItemView, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public var childItemViews: [any Adyen.AnyFormItemView] { get set }
```
```javascript
@_spi(AdyenInternal) public init(imageLoader: any Adyen.ImageLoading = $DEFAULT_ARG) -> Adyen.ListItemView
```
```javascript
@_spi(AdyenInternal) public func reset() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public var item: Adyen.ListItem? { get set }
```
```javascript
@_spi(AdyenInternal) @objc override public func didMoveToWindow() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public func layoutSubviews() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public func traitCollectionDidChange(_: UIKit.UITraitCollection?) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init(frame: CoreFoundation.CGRect) -> Adyen.ListItemView
```
```javascript
@_spi(AdyenInternal) public enum EditingStyle : Equatable, Hashable
```
```javascript
@_spi(AdyenInternal) public case delete
```
```javascript
@_spi(AdyenInternal) public case none
```
```javascript
@_spi(AdyenInternal) public static func __derived_enum_equals(_: Adyen.EditingStyle, _: Adyen.EditingStyle) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public struct ListSection : Equatable, Hashable
```
```javascript
@_spi(AdyenInternal) public let header: Adyen.ListSectionHeader? { get }
```
```javascript
@_spi(AdyenInternal) public var items: [Adyen.ListItem] { get }
```
```javascript
@_spi(AdyenInternal) public let footer: Adyen.ListSectionFooter? { get }
```
```javascript
@_spi(AdyenInternal) public var isEditable: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) public init(header: Adyen.ListSectionHeader? = $DEFAULT_ARG, items: [Adyen.ListItem], footer: Adyen.ListSectionFooter? = $DEFAULT_ARG) -> Adyen.ListSection
```
```javascript
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public static func ==(_: Adyen.ListSection, _: Adyen.ListSection) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public struct ListSectionHeader : Equatable, Hashable
```
```javascript
@_spi(AdyenInternal) public var title: Swift.String { get set }
```
```javascript
@_spi(AdyenInternal) public var style: Adyen.ListSectionHeaderStyle { get set }
```
```javascript
@_spi(AdyenInternal) public var editingStyle: Adyen.EditingStyle { get set }
```
```javascript
@_spi(AdyenInternal) public init(title: Swift.String, editingStyle: Adyen.EditingStyle = $DEFAULT_ARG, style: Adyen.ListSectionHeaderStyle) -> Adyen.ListSectionHeader
```
```javascript
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public static func ==(_: Adyen.ListSectionHeader, _: Adyen.ListSectionHeader) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
public struct ListSectionFooter : Equatable, Hashable
```
```javascript
public var title: Swift.String { get set }
```
```javascript
public var style: Adyen.ListSectionFooterStyle { get set }
```
```javascript
public init(title: Swift.String, style: Adyen.ListSectionFooterStyle) -> Adyen.ListSectionFooter
```
```javascript
public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
public static func ==(_: Adyen.ListSectionFooter, _: Adyen.ListSectionFooter) -> Swift.Bool
```
```javascript
public var hashValue: Swift.Int { get }
```
```javascript
public struct ListSectionFooterStyle : ViewStyle
```
```javascript
public var title: Adyen.TextStyle { get set }
```
```javascript
public var separatorColor: UIKit.UIColor { get set }
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public init(title: Adyen.TextStyle) -> Adyen.ListSectionFooterStyle
```
```javascript
public init() -> Adyen.ListSectionFooterStyle
```
```javascript
public struct ListSectionHeaderStyle : ViewStyle
```
```javascript
public var title: Adyen.TextStyle { get set }
```
```javascript
public var trailingButton: Adyen.ButtonStyle { get set }
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public init(title: Adyen.TextStyle) -> Adyen.ListSectionHeaderStyle
```
```javascript
public init() -> Adyen.ListSectionHeaderStyle
```
```javascript
@_spi(AdyenInternal) @objc public final class ListViewController : AdyenCompatible, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSExtensionRequestHandling, NSObjectProtocol, Sendable, UIActivityItemsConfigurationProviding, UIAppearanceContainer, UIContentContainer, UIFocusEnvironment, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UIScrollViewDelegate, UIStateRestoring, UITableViewDataSource, UITableViewDelegate, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring, ViewControllerPresenter
```
```javascript
@_spi(AdyenInternal) public let style: any Adyen.ViewStyle { get }
```
```javascript
@_spi(AdyenInternal) public weak var delegate: (any Adyen.ViewControllerDelegate)? { get set }
```
```javascript
@_spi(AdyenInternal) public init(style: any Adyen.ViewStyle) -> Adyen.ListViewController
```
```javascript
@_spi(AdyenInternal) @objc override public var preferredContentSize: CoreFoundation.CGSize { get set }
```
```javascript
@_spi(AdyenInternal) public var sections: [Adyen.ListSection] { get }
```
```javascript
@_spi(AdyenInternal) public func reload(newSections: [Adyen.ListSection], animated: Swift.Bool = $DEFAULT_ARG) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func deleteItem(at: Foundation.IndexPath, animated: Swift.Bool = $DEFAULT_ARG) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public func viewDidLoad() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public func viewDidAppear(_: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public func viewWillAppear(_: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public func tableView(_: UIKit.UITableView, viewForHeaderInSection: Swift.Int) -> UIKit.UIView?
```
```javascript
@_spi(AdyenInternal) @objc override public func tableView(_: UIKit.UITableView, viewForFooterInSection: Swift.Int) -> UIKit.UIView?
```
```javascript
@_spi(AdyenInternal) @objc override public func tableView(_: UIKit.UITableView, heightForFooterInSection: Swift.Int) -> CoreGraphics.CGFloat
```
```javascript
@_spi(AdyenInternal) @objc override public func tableView(_: UIKit.UITableView, heightForHeaderInSection: Swift.Int) -> CoreGraphics.CGFloat
```
```javascript
@_spi(AdyenInternal) @objc override public func tableView(_: UIKit.UITableView, didSelectRowAt: Foundation.IndexPath) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public func tableView(_: UIKit.UITableView, editingStyleForRowAt: Foundation.IndexPath) -> UIKit.UITableViewCell.EditingStyle
```
```javascript
@_spi(AdyenInternal) public func stopLoading() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init(style: UIKit.UITableView.Style) -> Adyen.ListViewController
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init(nibName: Swift.String?, bundle: Foundation.Bundle?) -> Adyen.ListViewController
```
```javascript
public struct ApplePayStyle
```
```javascript
public var paymentButtonStyle: PassKit.PKPaymentButtonStyle? { get set }
```
```javascript
public var paymentButtonType: PassKit.PKPaymentButtonType { get set }
```
```javascript
public var cornerRadius: CoreGraphics.CGFloat { get set }
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public var hintLabel: Adyen.TextStyle { get set }
```
```javascript
public init(paymentButtonStyle: PassKit.PKPaymentButtonStyle? = $DEFAULT_ARG, paymentButtonType: PassKit.PKPaymentButtonType = $DEFAULT_ARG, cornerRadius: CoreGraphics.CGFloat = $DEFAULT_ARG, backgroundColor: UIKit.UIColor = $DEFAULT_ARG, hintLabel: Adyen.TextStyle = $DEFAULT_ARG) -> Adyen.ApplePayStyle
```
```javascript
public struct ButtonStyle : Equatable, ViewStyle
```
```javascript
public var title: Adyen.TextStyle { get set }
```
```javascript
public var cornerRounding: Adyen.CornerRounding { get set }
```
```javascript
public var borderColor: UIKit.UIColor? { get set }
```
```javascript
public var borderWidth: CoreGraphics.CGFloat { get set }
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public init(title: Adyen.TextStyle) -> Adyen.ButtonStyle
```
```javascript
public init(title: Adyen.TextStyle, cornerRadius: CoreGraphics.CGFloat) -> Adyen.ButtonStyle
```
```javascript
public init(title: Adyen.TextStyle, cornerRounding: Adyen.CornerRounding) -> Adyen.ButtonStyle
```
```javascript
public init(title: Adyen.TextStyle, cornerRadius: CoreGraphics.CGFloat, background: UIKit.UIColor) -> Adyen.ButtonStyle
```
```javascript
public init(title: Adyen.TextStyle, cornerRounding: Adyen.CornerRounding, background: UIKit.UIColor) -> Adyen.ButtonStyle
```
```javascript
public static func __derived_struct_equals(_: Adyen.ButtonStyle, _: Adyen.ButtonStyle) -> Swift.Bool
```
```javascript
public enum CornerRounding : Equatable
```
```javascript
public case none
```
```javascript
public case fixed(CoreGraphics.CGFloat)
```
```javascript
public case percent(CoreGraphics.CGFloat)
```
```javascript
@_spi(AdyenInternal) public static func ==(_: Adyen.CornerRounding, _: Adyen.CornerRounding) -> Swift.Bool
```
```javascript
public struct FormComponentStyle : TintableStyle, ViewStyle
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public var sectionHeader: Adyen.TextStyle { get set }
```
```javascript
public var textField: Adyen.FormTextItemStyle { get set }
```
```javascript
public var toggle: Adyen.FormToggleItemStyle { get set }
```
```javascript
public var hintLabel: Adyen.TextStyle { get set }
```
```javascript
public var footnoteLabel: Adyen.TextStyle { get set }
```
```javascript
public var linkTextLabel: Adyen.TextStyle { get set }
```
```javascript
public var mainButtonItem: Adyen.FormButtonItemStyle { get set }
```
```javascript
public var secondaryButtonItem: Adyen.FormButtonItemStyle { get set }
```
```javascript
public var segmentedControlStyle: Adyen.SegmentedControlStyle { get set }
```
```javascript
public var addressStyle: Adyen.AddressStyle { get set }
```
```javascript
public var errorStyle: Adyen.FormErrorItemStyle { get set }
```
```javascript
public var tintColor: UIKit.UIColor? { get set }
```
```javascript
public var separatorColor: UIKit.UIColor? { get set }
```
```javascript
public init(textField: Adyen.FormTextItemStyle, toggle: Adyen.FormToggleItemStyle, mainButton: Adyen.FormButtonItemStyle, secondaryButton: Adyen.FormButtonItemStyle, helper: Adyen.TextStyle, sectionHeader: Adyen.TextStyle) -> Adyen.FormComponentStyle
```
```javascript
public init(textField: Adyen.FormTextItemStyle, toggle: Adyen.FormToggleItemStyle, mainButton: Adyen.ButtonStyle, secondaryButton: Adyen.ButtonStyle) -> Adyen.FormComponentStyle
```
```javascript
public init(tintColor: UIKit.UIColor) -> Adyen.FormComponentStyle
```
```javascript
public init() -> Adyen.FormComponentStyle
```
```javascript
public struct ImageStyle : Equatable, TintableStyle, ViewStyle
```
```javascript
public var borderColor: UIKit.UIColor? { get set }
```
```javascript
public var borderWidth: CoreGraphics.CGFloat { get set }
```
```javascript
public var cornerRounding: Adyen.CornerRounding { get set }
```
```javascript
public var clipsToBounds: Swift.Bool { get set }
```
```javascript
public var contentMode: UIKit.UIView.ContentMode { get set }
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public var tintColor: UIKit.UIColor? { get set }
```
```javascript
public init(borderColor: UIKit.UIColor?, borderWidth: CoreGraphics.CGFloat, cornerRadius: CoreGraphics.CGFloat, clipsToBounds: Swift.Bool, contentMode: UIKit.UIView.ContentMode) -> Adyen.ImageStyle
```
```javascript
public init(borderColor: UIKit.UIColor?, borderWidth: CoreGraphics.CGFloat, cornerRounding: Adyen.CornerRounding, clipsToBounds: Swift.Bool, contentMode: UIKit.UIView.ContentMode) -> Adyen.ImageStyle
```
```javascript
public static func ==(_: Adyen.ImageStyle, _: Adyen.ImageStyle) -> Swift.Bool
```
```javascript
public struct ListComponentStyle : ViewStyle
```
```javascript
public var listItem: Adyen.ListItemStyle { get set }
```
```javascript
public var sectionHeader: Adyen.ListSectionHeaderStyle { get set }
```
```javascript
public var partialPaymentSectionFooter: Adyen.ListSectionFooterStyle { get set }
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public init(listItem: Adyen.ListItemStyle, sectionHeader: Adyen.ListSectionHeaderStyle) -> Adyen.ListComponentStyle
```
```javascript
public init() -> Adyen.ListComponentStyle
```
```javascript
public enum CancelButtonStyle
```
```javascript
public case system
```
```javascript
public case legacy
```
```javascript
public case custom(UIKit.UIImage)
```
```javascript
public enum ToolbarMode : Equatable, Hashable
```
```javascript
public case leftCancel
```
```javascript
public case rightCancel
```
```javascript
public case natural
```
```javascript
public static func __derived_enum_equals(_: Adyen.ToolbarMode, _: Adyen.ToolbarMode) -> Swift.Bool
```
```javascript
public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
public var hashValue: Swift.Int { get }
```
```javascript
public struct NavigationStyle : TintableStyle, ViewStyle
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public var separatorColor: UIKit.UIColor? { get set }
```
```javascript
public var tintColor: UIKit.UIColor? { get set }
```
```javascript
public var cornerRadius: CoreGraphics.CGFloat { get set }
```
```javascript
public var barTitle: Adyen.TextStyle { get set }
```
```javascript
public var cancelButton: Adyen.CancelButtonStyle { get set }
```
```javascript
public var toolbarMode: Adyen.ToolbarMode { get set }
```
```javascript
public init() -> Adyen.NavigationStyle
```
```javascript
public struct ProgressViewStyle : ViewStyle
```
```javascript
public let progressTintColor: UIKit.UIColor { get }
```
```javascript
public let trackTintColor: UIKit.UIColor { get }
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public init(progressTintColor: UIKit.UIColor, trackTintColor: UIKit.UIColor) -> Adyen.ProgressViewStyle
```
```javascript
public struct SegmentedControlStyle : TintableStyle, ViewStyle
```
```javascript
public var textStyle: Adyen.TextStyle { get set }
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public var tintColor: UIKit.UIColor? { get set }
```
```javascript
public init(textStyle: Adyen.TextStyle, backgroundColor: UIKit.UIColor = $DEFAULT_ARG, tintColor: UIKit.UIColor = $DEFAULT_ARG) -> Adyen.SegmentedControlStyle
```
```javascript
public struct TextStyle : Equatable, ViewStyle
```
```javascript
public var font: UIKit.UIFont { get set }
```
```javascript
public var color: UIKit.UIColor { get set }
```
```javascript
public var disabledColor: UIKit.UIColor { get set }
```
```javascript
public var textAlignment: UIKit.NSTextAlignment { get set }
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public var cornerRounding: Adyen.CornerRounding { get set }
```
```javascript
public init(font: UIKit.UIFont, color: UIKit.UIColor, disabledColor: UIKit.UIColor = $DEFAULT_ARG, textAlignment: UIKit.NSTextAlignment, cornerRounding: Adyen.CornerRounding = $DEFAULT_ARG, backgroundColor: UIKit.UIColor = $DEFAULT_ARG) -> Adyen.TextStyle
```
```javascript
public init(font: UIKit.UIFont, color: UIKit.UIColor) -> Adyen.TextStyle
```
```javascript
public static func ==(_: Adyen.TextStyle, _: Adyen.TextStyle) -> Swift.Bool
```
```javascript
public var stringAttributes: [Foundation.NSAttributedString.Key : Any] { get }
```
```javascript
public protocol ViewStyle
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public protocol TintableStyle<Self : Adyen.ViewStyle> : ViewStyle
```
```javascript
public var tintColor: UIKit.UIColor? { get set }
```
```javascript
@_spi(AdyenInternal) @objc public final class ADYViewController : AdyenCompatible, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSExtensionRequestHandling, NSObjectProtocol, Sendable, UIActivityItemsConfigurationProviding, UIAppearanceContainer, UIContentContainer, UIFocusEnvironment, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UIStateRestoring, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring, ViewControllerPresenter
```
```javascript
@_spi(AdyenInternal) public init(view: UIKit.UIView, title: Swift.String? = $DEFAULT_ARG) -> Adyen.ADYViewController
```
```javascript
@_spi(AdyenInternal) @objc override public func loadView() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public var preferredContentSize: CoreFoundation.CGSize { get set }
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init(nibName: Swift.String?, bundle: Foundation.Bundle?) -> Adyen.ADYViewController
```
```javascript
public struct LookupAddressModel
```
```javascript
public let identifier: Swift.String { get }
```
```javascript
public let postalAddress: Adyen.PostalAddress { get }
```
```javascript
public init(identifier: Swift.String, postalAddress: Adyen.PostalAddress) -> Adyen.LookupAddressModel
```
```javascript
public protocol AddressLookupProvider<Self : AnyObject>
```
```javascript
public func lookUp<Self where Self : Adyen.AddressLookupProvider>(searchTerm: Swift.String, resultHandler: ([Adyen.LookupAddressModel]) -> Swift.Void) -> Swift.Void
```
```javascript
public func complete<Self where Self : Adyen.AddressLookupProvider>(incompleteAddress: Adyen.LookupAddressModel, resultHandler: (Swift.Result<Adyen.PostalAddress, any Swift.Error>) -> Swift.Void) -> Swift.Void
```
```javascript
public func complete<Self where Self : Adyen.AddressLookupProvider>(incompleteAddress: Adyen.LookupAddressModel, resultHandler: (Swift.Result<Adyen.PostalAddress, any Swift.Error>) -> Swift.Void) -> Swift.Void
```
```javascript
public struct AddressLookupStyle : ViewStyle
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public var search: Adyen.AddressLookupSearchStyle { get set }
```
```javascript
public var form: Adyen.FormComponentStyle { get set }
```
```javascript
public init(search: Adyen.AddressLookupSearchStyle = $DEFAULT_ARG, form: Adyen.FormComponentStyle = $DEFAULT_ARG) -> Adyen.AddressLookupStyle
```
```javascript
@_spi(AdyenInternal) @objc public class AddressLookupViewController : AdyenCompatible, AdyenObserver, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSExtensionRequestHandling, NSObjectProtocol, Sendable, UIActivityItemsConfigurationProviding, UIAppearanceContainer, UIContentContainer, UIFocusEnvironment, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UIStateRestoring, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring, ViewControllerPresenter
```
```javascript
@_spi(AdyenInternal) public init(viewModel: Adyen.AddressLookupViewController.ViewModel) -> Adyen.AddressLookupViewController
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic func viewDidLoad() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init(navigationBarClass: Swift.AnyClass?, toolbarClass: Swift.AnyClass?) -> Adyen.AddressLookupViewController
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init(rootViewController: UIKit.UIViewController) -> Adyen.AddressLookupViewController
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init(nibName: Swift.String?, bundle: Foundation.Bundle?) -> Adyen.AddressLookupViewController
```
```javascript
@_spi(AdyenInternal) public struct ViewModel
```
```javascript
@_spi(AdyenInternal) public init(for: Adyen.FormAddressPickerItem.AddressType, style: Adyen.AddressLookupStyle = $DEFAULT_ARG, localizationParameters: Adyen.LocalizationParameters?, supportedCountryCodes: [Swift.String]?, initialCountry: Swift.String, prefillAddress: Adyen.PostalAddress? = $DEFAULT_ARG, lookupProvider: any Adyen.AddressLookupProvider, completionHandler: (Adyen.PostalAddress?) -> Swift.Void) -> Adyen.AddressLookupViewController.ViewModel
```
```javascript
@_spi(AdyenInternal) @objc public class AddressInputFormViewController : AdyenCompatible, AdyenObserver, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, FormTextItemViewDelegate, FormViewProtocol, Hashable, NSCoding, NSExtensionRequestHandling, NSObjectProtocol, PreferredContentSizeConsumer, Sendable, UIActivityItemsConfigurationProviding, UIAppearanceContainer, UIContentContainer, UIFocusEnvironment, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UIStateRestoring, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring, ViewControllerPresenter
```
```javascript
@_spi(AdyenInternal) public init(viewModel: Adyen.AddressInputFormViewController.ViewModel) -> Adyen.AddressInputFormViewController
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic func viewDidLoad() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) override public init(style: any Adyen.ViewStyle, localizationParameters: Adyen.LocalizationParameters?) -> Adyen.AddressInputFormViewController
```
```javascript
@_spi(AdyenInternal) public typealias ShowSearchHandler = (Adyen.PostalAddress) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public struct ViewModel
```
```javascript
@_spi(AdyenInternal) public init(for: Adyen.FormAddressPickerItem.AddressType, style: Adyen.FormComponentStyle, localizationParameters: Adyen.LocalizationParameters?, initialCountry: Swift.String, prefillAddress: Adyen.PostalAddress?, supportedCountryCodes: [Swift.String]?, addressViewModelBuilder: any Adyen.AddressViewModelBuilder = $DEFAULT_ARG, handleShowSearch: Adyen.AddressInputFormViewController.ShowSearchHandler? = $DEFAULT_ARG, completionHandler: (Adyen.PostalAddress?) -> Swift.Void) -> Adyen.AddressInputFormViewController.ViewModel
```
```javascript
public struct AddressLookupSearchStyle : ViewStyle
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
public var manualEntryListItem: Adyen.ListItemStyle { get set }
```
```javascript
public var emptyView: Adyen.EmptyStateViewStyle { get set }
```
```javascript
public init() -> Adyen.AddressLookupSearchStyle
```
```javascript
@_spi(AdyenInternal) public protocol SearchResultsEmptyView<Self : UIKit.UIView>
```
```javascript
@_spi(AdyenInternal) public var searchTerm: Swift.String { get set }
```
```javascript
@_spi(AdyenInternal) @objc public class SearchViewController : AdyenCompatible, AdyenObserver, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSExtensionRequestHandling, NSObjectProtocol, Sendable, UIActivityItemsConfigurationProviding, UIAppearanceContainer, UIBarPositioningDelegate, UIContentContainer, UIFocusEnvironment, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UISearchBarDelegate, UIStateRestoring, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring, ViewControllerPresenter
```
```javascript
@_spi(AdyenInternal) public weak var delegate: (any Adyen.ViewControllerDelegate)? { get set }
```
```javascript
@_spi(AdyenInternal) public lazy var resultsListViewController: Adyen.ListViewController { get set }
```
```javascript
@_spi(AdyenInternal) public init(viewModel: Adyen.SearchViewController.ViewModel, emptyView: any Adyen.SearchResultsEmptyView) -> Adyen.SearchViewController
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic func viewDidLoad() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic func viewWillAppear(_: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic func viewDidAppear(_: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic var preferredContentSize: CoreFoundation.CGSize { get set }
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init(nibName: Swift.String?, bundle: Foundation.Bundle?) -> Adyen.SearchViewController
```
```javascript
@_spi(AdyenInternal) public struct ViewModel
```
```javascript
@_spi(AdyenInternal) public typealias ResultProvider = (Swift.String, @escaping ([Adyen.ListItem]) -> Swift.Void) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public init(localizationParameters: Adyen.LocalizationParameters? = $DEFAULT_ARG, style: any Adyen.ViewStyle, searchBarPlaceholder: Swift.String? = $DEFAULT_ARG, shouldFocusSearchBarOnAppearance: Swift.Bool = $DEFAULT_ARG, resultProvider: Adyen.SearchViewController.ViewModel.ResultProvider) -> Adyen.SearchViewController.ViewModel
```
```javascript
@_spi(AdyenInternal) @objc public dynamic func searchBar(_: UIKit.UISearchBar, textDidChange: Swift.String) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc public dynamic func searchBarSearchButtonClicked(_: UIKit.UISearchBar) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public final class SecuredViewController<ChildViewController where ChildViewController : UIKit.UIViewController> : AdyenCompatible, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSExtensionRequestHandling, NSObjectProtocol, Sendable, UIActivityItemsConfigurationProviding, UIAppearanceContainer, UIContentContainer, UIFocusEnvironment, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UIStateRestoring, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring, ViewControllerPresenter
```
```javascript
@_spi(AdyenInternal) public weak var delegate: (any Adyen.ViewControllerDelegate)? { get set }
```
```javascript
@_spi(AdyenInternal) @objc override public var preferredContentSize: CoreFoundation.CGSize { get set }
```
```javascript
@_spi(AdyenInternal) @objc override public var title: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public init<ChildViewController where ChildViewController : UIKit.UIViewController>(child: ChildViewController, style: any Adyen.ViewStyle) -> Adyen.SecuredViewController<ChildViewController>
```
```javascript
@_spi(AdyenInternal) @objc override public func viewDidLoad<ChildViewController where ChildViewController : UIKit.UIViewController>() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public func viewDidAppear<ChildViewController where ChildViewController : UIKit.UIViewController>(_: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public func viewWillAppear<ChildViewController where ChildViewController : UIKit.UIViewController>(_: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init<ChildViewController where ChildViewController : UIKit.UIViewController>(nibName: Swift.String?, bundle: Foundation.Bundle?) -> Adyen.SecuredViewController<ChildViewController>
```
```javascript
@_spi(AdyenInternal) public protocol ViewControllerDelegate<Self : AnyObject>
```
```javascript
@_spi(AdyenInternal) public func viewDidLoad<Self where Self : Adyen.ViewControllerDelegate>(viewController: UIKit.UIViewController) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func viewDidAppear<Self where Self : Adyen.ViewControllerDelegate>(viewController: UIKit.UIViewController) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func viewWillAppear<Self where Self : Adyen.ViewControllerDelegate>(viewController: UIKit.UIViewController) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func viewDidLoad<Self where Self : Adyen.ViewControllerDelegate>(viewController: UIKit.UIViewController) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func viewDidAppear<Self where Self : Adyen.ViewControllerDelegate>(viewController: UIKit.UIViewController) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func viewWillAppear<Self where Self : Adyen.ViewControllerDelegate>(viewController: UIKit.UIViewController) -> Swift.Void
```
```javascript
@objc public final class ContainerView : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
public init(body: UIKit.UIView, padding: UIKit.UIEdgeInsets = $DEFAULT_ARG) -> Adyen.ContainerView
```
```javascript
public func setupConstraints() -> Swift.Void
```
```javascript
@objc override public dynamic init(frame: CoreFoundation.CGRect) -> Adyen.ContainerView
```
```javascript
@_spi(AdyenInternal) @objc public final class CopyLabelView : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, Localizable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public var localizationParameters: Adyen.LocalizationParameters? { get set }
```
```javascript
@_spi(AdyenInternal) public init(text: Swift.String, style: Adyen.TextStyle) -> Adyen.CopyLabelView
```
```javascript
@_spi(AdyenInternal) @objc override public var canBecomeFirstResponder: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) @discardableResult @objc override public func becomeFirstResponder() -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init(frame: CoreFoundation.CGRect) -> Adyen.CopyLabelView
```
```javascript
public struct EmptyStateViewStyle : ViewStyle
```
```javascript
public var title: Adyen.TextStyle { get set }
```
```javascript
public var subtitle: Adyen.TextStyle { get set }
```
```javascript
public var backgroundColor: UIKit.UIColor { get set }
```
```javascript
@_spi(AdyenInternal) public class EmptyStateView<SubtitleLabel where SubtitleLabel : UIKit.UIView> : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, SearchResultsEmptyView, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public var searchTerm: Swift.String { get set }
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init<SubtitleLabel where SubtitleLabel : UIKit.UIView>(frame: CoreFoundation.CGRect) -> Adyen.EmptyStateView<SubtitleLabel>
```
```javascript
@_spi(AdyenInternal) @objc public class LinkTextView : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UIContentSizeCategoryAdjusting, UICoordinateSpace, UIDynamicItem, UIFindInteractionDelegate, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UIFocusItemScrollableContainer, UIKeyInput, UILargeContentViewerItem, UILetterformAwareAdjusting, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UIScrollViewDelegate, UITextDraggable, UITextDroppable, UITextInput, UITextInputTraits, UITextPasteConfigurationSupporting, UITextViewDelegate, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public init(linkSelectionHandler: (Swift.Int) -> Swift.Void) -> Adyen.LinkTextView
```
```javascript
@_spi(AdyenInternal) public func update(text: Swift.String, style: Adyen.TextStyle, linkRangeDelimiter: Swift.String = $DEFAULT_ARG) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init(frame: CoreFoundation.CGRect, textContainer: UIKit.NSTextContainer?) -> Adyen.LinkTextView
```
```javascript
@_spi(AdyenInternal) @objc public dynamic func textView(_: UIKit.UITextView, shouldInteractWith: Foundation.URL, in: Foundation.NSRange, interaction: UIKit.UITextItemInteraction) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) @objc public final class LoadingView : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UIContextMenuInteractionDelegate, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public var disableUserInteractionWhileLoading: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) public var spinnerAppearanceDelay: Dispatch.DispatchTimeInterval { get set }
```
```javascript
@_spi(AdyenInternal) public init(contentView: UIKit.UIView) -> Adyen.LoadingView
```
```javascript
@_spi(AdyenInternal) public var showsActivityIndicator: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init(frame: CoreFoundation.CGRect) -> Adyen.LoadingView
```
```javascript
@_spi(AdyenInternal) @objc public final class SubmitButton : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UIContextMenuInteractionDelegate, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public init(style: Adyen.ButtonStyle) -> Adyen.SubmitButton
```
```javascript
@_spi(AdyenInternal) public var title: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) @objc override public var accessibilityIdentifier: Swift.String? { get set }
```
```javascript
@_spi(AdyenInternal) public var showsActivityIndicator: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) @objc override public func layoutSubviews() -> Swift.Void
```
```javascript
@_spi(AdyenInternal) @objc override public var isHighlighted: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) @objc override public dynamic init(frame: CoreFoundation.CGRect) -> Adyen.SubmitButton
```
```javascript
@_spi(AdyenInternal) public enum AdyenCoder
```
```javascript
@_spi(AdyenInternal) public static func decode<T where T : Swift.Decodable>(_: Foundation.Data) throws -> T
```
```javascript
@_spi(AdyenInternal) public static func decode<T where T : Swift.Decodable>(_: Swift.String) throws -> T
```
```javascript
@_spi(AdyenInternal) public static func decodeBase64<T where T : Swift.Decodable>(_: Swift.String) throws -> T
```
```javascript
@_spi(AdyenInternal) public static func encode(_: some Swift.Encodable) throws -> Foundation.Data
```
```javascript
@_spi(AdyenInternal) public static func encode(_: some Swift.Encodable) throws -> Swift.String
```
```javascript
@_spi(AdyenInternal) public static func encodeBase64(_: some Swift.Encodable) throws -> Swift.String
```
```javascript
@_spi(AdyenInternal) public class Analytics
```
```javascript
@_spi(AdyenInternal) public enum Flavor : Equatable, Hashable, RawRepresentable
```
```javascript
@_spi(AdyenInternal) public case components
```
```javascript
@_spi(AdyenInternal) public case dropin
```
```javascript
@_spi(AdyenInternal) public init(rawValue: Swift.String) -> Adyen.Analytics.Flavor?
```
```javascript
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public struct Event
```
```javascript
@_spi(AdyenInternal) public init(component: Swift.String, flavor: Adyen.Analytics.Flavor, environment: any AdyenNetworking.AnyAPIEnvironment) -> Adyen.Analytics.Event
```
```javascript
@_spi(AdyenInternal) public init(component: Swift.String, flavor: Adyen.Analytics.Flavor, context: Adyen.APIContext) -> Adyen.Analytics.Event
```
```javascript
@_spi(AdyenInternal) public static var isEnabled: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) public static func sendEvent(component: Swift.String, flavor: Adyen.Analytics.Flavor, environment: any AdyenNetworking.AnyAPIEnvironment) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public static func sendEvent(component: Swift.String, flavor: Adyen.Analytics.Flavor, context: Adyen.APIContext) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public static func sendEvent(_: Adyen.Analytics.Event) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public protocol AnyAppLauncher
```
```javascript
@_spi(AdyenInternal) public func openCustomSchemeUrl<Self where Self : Adyen.AnyAppLauncher>(_: Foundation.URL, completion: ((Swift.Bool) -> Swift.Void)?) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func openUniversalAppUrl<Self where Self : Adyen.AnyAppLauncher>(_: Foundation.URL, completion: ((Swift.Bool) -> Swift.Void)?) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public struct AppLauncher : AnyAppLauncher
```
```javascript
@_spi(AdyenInternal) public init() -> Adyen.AppLauncher
```
```javascript
@_spi(AdyenInternal) public func openCustomSchemeUrl(_: Foundation.URL, completion: ((Swift.Bool) -> Swift.Void)?) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func openUniversalAppUrl(_: Foundation.URL, completion: ((Swift.Bool) -> Swift.Void)?) -> Swift.Void
```
```javascript
public typealias Completion = (T) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public typealias AssertionListener = (Swift.String) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public enum AdyenAssertion
```
```javascript
@_spi(AdyenInternal) public static func assertionFailure(message: () -> Swift.String) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public static func assert(message: () -> Swift.String, condition: () -> Swift.Bool) -> Swift.Void
```
```javascript
public enum AdyenLogging
```
```javascript
public static var isEnabled: Swift.Bool { get set }
```
```javascript
@_spi(AdyenInternal) public func adyenPrint(_: Any..., separator: Swift.String = $DEFAULT_ARG, terminator: Swift.String = $DEFAULT_ARG) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public struct Region : CustomStringConvertible, Decodable, Equatable
```
```javascript
@_spi(AdyenInternal) public let identifier: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public let name: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public var description: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public static func __derived_struct_equals(_: Adyen.Region, _: Adyen.Region) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public init(from: any Swift.Decoder) throws -> Adyen.Region
```
```javascript
public final class LogoURLProvider
```
```javascript
public init(environment: any AdyenNetworking.AnyAPIEnvironment) -> Adyen.LogoURLProvider
```
```javascript
public func logoURL(withName: Swift.String, size: Adyen.LogoURLProvider.Size = $DEFAULT_ARG) -> Foundation.URL
```
```javascript
public static func logoURL(for: Adyen.Issuer, localizedParameters: Adyen.LocalizationParameters?, paymentMethod: Adyen.IssuerListPaymentMethod, environment: any AdyenNetworking.AnyAPIEnvironment) -> Foundation.URL
```
```javascript
public static func logoURL(withName: Swift.String, environment: any AdyenNetworking.AnyAPIEnvironment, size: Adyen.LogoURLProvider.Size = $DEFAULT_ARG) -> Foundation.URL
```
```javascript
public enum Size : Equatable, Hashable, RawRepresentable
```
```javascript
public case small
```
```javascript
public case medium
```
```javascript
public case large
```
```javascript
public init(rawValue: Swift.String) -> Adyen.LogoURLProvider.Size?
```
```javascript
public typealias RawValue = Swift.String
```
```javascript
public var rawValue: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public enum PhoneNumberPaymentMethod : Equatable, Hashable
```
```javascript
@_spi(AdyenInternal) public case qiwiWallet
```
```javascript
@_spi(AdyenInternal) public case mbWay
```
```javascript
@_spi(AdyenInternal) public case generic
```
```javascript
@_spi(AdyenInternal) public static func __derived_enum_equals(_: Adyen.PhoneNumberPaymentMethod, _: Adyen.PhoneNumberPaymentMethod) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public struct PhoneExtensionsQuery
```
```javascript
@_spi(AdyenInternal) public let codes: [Swift.String] { get }
```
```javascript
@_spi(AdyenInternal) public init(codes: [Swift.String]) -> Adyen.PhoneExtensionsQuery
```
```javascript
@_spi(AdyenInternal) public init(paymentMethod: Adyen.PhoneNumberPaymentMethod) -> Adyen.PhoneExtensionsQuery
```
```javascript
@_spi(AdyenInternal) public enum PhoneExtensionsRepository
```
```javascript
@_spi(AdyenInternal) public static func get(with: Adyen.PhoneExtensionsQuery) -> [Adyen.PhoneExtension]
```
```javascript
@_spi(AdyenInternal) public struct IBANSpecification
```
```javascript
@_spi(AdyenInternal) public static let highestMaximumLength: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public let countryCode: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public let length: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public let structure: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public let example: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public init(forCountryCode: Swift.String) -> Adyen.IBANSpecification?
```
```javascript
@_spi(AdyenInternal) public class KeyboardObserver
```
```javascript
@_spi(AdyenInternal) public var keyboardRect: CoreFoundation.CGRect { get }
```
```javascript
@_spi(AdyenInternal) public var $keyboardRect: Adyen.AdyenObservable<CoreFoundation.CGRect> { get }
```
```javascript
@_spi(AdyenInternal) public init() -> Adyen.KeyboardObserver
```
```javascript
@_spi(AdyenInternal) public func localizedString(_: Adyen.LocalizationKey, _: Adyen.LocalizationParameters?, _: any Swift.CVarArg...) -> Swift.String
```
```javascript
@_spi(AdyenInternal) public enum PaymentStyle
```
```javascript
@_spi(AdyenInternal) public case needsRedirectToThirdParty(Swift.String)
```
```javascript
@_spi(AdyenInternal) public case immediate
```
```javascript
@_spi(AdyenInternal) public func localizedSubmitButtonTitle(with: Adyen.Amount?, style: Adyen.PaymentStyle, _: Adyen.LocalizationParameters?) -> Swift.String
```
```javascript
public struct LocalizationParameters : Equatable
```
```javascript
public static func ==(_: Adyen.LocalizationParameters, _: Adyen.LocalizationParameters) -> Swift.Bool
```
```javascript
public var locale: Swift.String? { get }
```
```javascript
public var tableName: Swift.String? { get }
```
```javascript
public var keySeparator: Swift.String? { get }
```
```javascript
public var bundle: Foundation.Bundle? { get }
```
```javascript
public init(bundle: Foundation.Bundle? = $DEFAULT_ARG, tableName: Swift.String? = $DEFAULT_ARG, keySeparator: Swift.String? = $DEFAULT_ARG, locale: Swift.String? = $DEFAULT_ARG) -> Adyen.LocalizationParameters
```
```javascript
public init(enforcedLocale: Swift.String) -> Adyen.LocalizationParameters
```
```javascript
public final class AdyenObservable<ValueType where ValueType : Swift.Equatable> : EventPublisher
```
```javascript
public init<ValueType where ValueType : Swift.Equatable>(_: ValueType) -> Adyen.AdyenObservable<ValueType>
```
```javascript
public var wrappedValue: ValueType { get set }
```
```javascript
public typealias Event = ValueType
```
```javascript
public var eventHandlers: [Adyen.EventHandlerToken : Adyen.EventHandler<Adyen.AdyenObservable<ValueType>.Event>] { get set }
```
```javascript
public var projectedValue: Adyen.AdyenObservable<ValueType> { get }
```
```javascript
public protocol AdyenObserver<Self : AnyObject>
```
```javascript
@_spi(AdyenInternal) @discardableResult public func observe<Self, T where Self : Adyen.AdyenObserver, T : Adyen.EventPublisher>(_: T, eventHandler: Adyen.EventHandler<T.Event>) -> Adyen.Observation
```
```javascript
@_spi(AdyenInternal) @discardableResult public func bind<Self, Value, Target where Self : Adyen.AdyenObserver, Value : Swift.Equatable, Target : AnyObject>(_: Adyen.AdyenObservable<Value>, to: Target, at: Swift.ReferenceWritableKeyPath<Target, Value>) -> Adyen.Observation
```
```javascript
@_spi(AdyenInternal) @discardableResult public func bind<Self, Value, Target where Self : Adyen.AdyenObserver, Value : Swift.Equatable, Target : AnyObject>(_: Adyen.AdyenObservable<Value>, to: Target, at: Swift.ReferenceWritableKeyPath<Target, Value?>) -> Adyen.Observation
```
```javascript
@_spi(AdyenInternal) @discardableResult public func bind<Self, Value, Result, Target where Self : Adyen.AdyenObserver, Value : Swift.Equatable, Target : AnyObject>(_: Adyen.AdyenObservable<Value>, to: Target, at: Swift.ReferenceWritableKeyPath<Target, Result>, with: ((Value) -> Result)) -> Adyen.Observation
```
```javascript
@_spi(AdyenInternal) @discardableResult public func bind<Self, Value, Result, Target where Self : Adyen.AdyenObserver, Value : Swift.Equatable, Target : AnyObject>(_: Adyen.AdyenObservable<Value>, at: Swift.KeyPath<Value, Result>, to: Target, at: Swift.ReferenceWritableKeyPath<Target, Result>) -> Adyen.Observation
```
```javascript
@_spi(AdyenInternal) @discardableResult public func bind<Self, Value, Result, Target where Self : Adyen.AdyenObserver, Value : Swift.Equatable, Target : AnyObject>(_: Adyen.AdyenObservable<Value>, at: Swift.KeyPath<Value, Result>, to: Target, at: Swift.ReferenceWritableKeyPath<Target, Result?>) -> Adyen.Observation
```
```javascript
@_spi(AdyenInternal) public func remove<Self where Self : Adyen.AdyenObserver>(_: Adyen.Observation) -> Swift.Void
```
```javascript
public protocol EventPublisher<Self : AnyObject>
```
```javascript
public associatedtype Event
```
```javascript
public var eventHandlers: [Adyen.EventHandlerToken : Adyen.EventHandler<Self.Event>] { get set }
```
```javascript
@_spi(AdyenInternal) public func addEventHandler<Self where Self : Adyen.EventPublisher>(_: Adyen.EventHandler<Self.Event>) -> Adyen.EventHandlerToken
```
```javascript
@_spi(AdyenInternal) public func removeEventHandler<Self where Self : Adyen.EventPublisher>(with: Adyen.EventHandlerToken) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func publish<Self where Self : Adyen.EventPublisher>(_: Self.Event) -> Swift.Void
```
```javascript
public typealias EventHandler = (Event) -> Swift.Void
```
```javascript
public struct EventHandlerToken : Equatable, Hashable
```
```javascript
public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
public static func __derived_struct_equals(_: Adyen.EventHandlerToken, _: Adyen.EventHandlerToken) -> Swift.Bool
```
```javascript
public var hashValue: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public struct Observation : Equatable, Hashable
```
```javascript
@_spi(AdyenInternal) public static func ==(_: Adyen.Observation, _: Adyen.Observation) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public protocol PublicKeyConsumer<Self : Adyen.PaymentComponent> : AdyenContextAware, Component, PartialPaymentOrderAware, PaymentComponent, PaymentMethodAware
```
```javascript
@_spi(AdyenInternal) public var publicKeyProvider: any Adyen.AnyPublicKeyProvider { get }
```
```javascript
@_spi(AdyenInternal) public typealias PublicKeySuccessHandler = (Swift.String) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func fetchCardPublicKey<Self where Self : Adyen.PublicKeyConsumer>(notifyingDelegateOnFailure: Swift.Bool, successHandler: Self.PublicKeySuccessHandler? = $DEFAULT_ARG) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public protocol AnyPublicKeyProvider<Self : AnyObject>
```
```javascript
@_spi(AdyenInternal) public typealias CompletionHandler = (Swift.Result<Swift.String, any Swift.Error>) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func fetch<Self where Self : Adyen.AnyPublicKeyProvider>(completion: Self.CompletionHandler) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public final class PublicKeyProvider : AnyPublicKeyProvider
```
```javascript
@_spi(AdyenInternal) public convenience init(apiContext: Adyen.APIContext) -> Adyen.PublicKeyProvider
```
```javascript
@_spi(AdyenInternal) public func fetch(completion: Adyen.PublicKeyProvider.CompletionHandler) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public enum Error : Equatable, Error, Hashable, LocalizedError, Sendable
```
```javascript
@_spi(AdyenInternal) public case invalidClientKey
```
```javascript
@_spi(AdyenInternal) public var errorDescription: Swift.String? { get }
```
```javascript
@_spi(AdyenInternal) public static func __derived_enum_equals(_: Adyen.PublicKeyProvider.Error, _: Adyen.PublicKeyProvider.Error) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public final class Throttler
```
```javascript
@_spi(AdyenInternal) public init(minimumDelay: Foundation.TimeInterval, queue: Dispatch.DispatchQueue = $DEFAULT_ARG) -> Adyen.Throttler
```
```javascript
@_spi(AdyenInternal) public func throttle(_: () -> Swift.Void) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public enum ViewIdentifierBuilder
```
```javascript
@_spi(AdyenInternal) public static func build(scopeInstance: Any, postfix: Swift.String) -> Swift.String
```
```javascript
@_spi(AdyenInternal) public enum AddressAnalyticsValidationError : AnalyticsValidationError, Equatable, Error, Hashable, LocalizedError, Sendable, ValidationError
```
```javascript
@_spi(AdyenInternal) public case postalCodeEmpty
```
```javascript
@_spi(AdyenInternal) public case postalCodePartial
```
```javascript
@_spi(AdyenInternal) public var analyticsErrorCode: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public var analyticsErrorMessage: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public static func __derived_enum_equals(_: Adyen.AddressAnalyticsValidationError, _: Adyen.AddressAnalyticsValidationError) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public struct BalanceChecker
```
```javascript
@_spi(AdyenInternal) public enum Error : Equatable, Error, Hashable, LocalizedError, Sendable
```
```javascript
@_spi(AdyenInternal) public case unexpectedCurrencyCode
```
```javascript
@_spi(AdyenInternal) public case zeroBalance
```
```javascript
@_spi(AdyenInternal) public var errorDescription: Swift.String? { get }
```
```javascript
@_spi(AdyenInternal) public static func __derived_enum_equals(_: Adyen.BalanceChecker.Error, _: Adyen.BalanceChecker.Error) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public var hashValue: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public struct Result
```
```javascript
@_spi(AdyenInternal) public let isBalanceEnough: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) public let remainingBalanceAmount: Adyen.Amount { get }
```
```javascript
@_spi(AdyenInternal) public let amountToPay: Adyen.Amount { get }
```
```javascript
@_spi(AdyenInternal) public init() -> Adyen.BalanceChecker
```
```javascript
@_spi(AdyenInternal) public func check(balance: Adyen.Balance, isEnoughToPay: Adyen.Amount) throws -> Adyen.BalanceChecker.Result
```
```javascript
@_spi(AdyenInternal) public final class BrazilSocialSecurityNumberValidator : CombinedValidator, StatusValidator, Validator
```
```javascript
@_spi(AdyenInternal) public let firstValidator: any Adyen.Validator { get }
```
```javascript
@_spi(AdyenInternal) public let secondValidator: any Adyen.Validator { get }
```
```javascript
@_spi(AdyenInternal) public init() -> Adyen.BrazilSocialSecurityNumberValidator
```
```javascript
@_spi(AdyenInternal) public func validate(_: Swift.String) -> Adyen.ValidationStatus
```
```javascript
@_spi(AdyenInternal) public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
public enum ClientKeyError : Equatable, Error, Hashable, LocalizedError, Sendable
```
```javascript
public case invalidClientKey
```
```javascript
public var errorDescription: Swift.String? { get }
```
```javascript
public static func __derived_enum_equals(_: Adyen.ClientKeyError, _: Adyen.ClientKeyError) -> Swift.Bool
```
```javascript
public func hash(into: inout Swift.Hasher) -> Swift.Void
```
```javascript
public var hashValue: Swift.Int { get }
```
```javascript
@_spi(AdyenInternal) public final class ClientKeyValidator : Validator
```
```javascript
@_spi(AdyenInternal) public init() -> Adyen.ClientKeyValidator
```
```javascript
@_spi(AdyenInternal) override public init(regularExpression: Swift.String, minimumLength: Swift.Int? = $DEFAULT_ARG, maximumLength: Swift.Int? = $DEFAULT_ARG) -> Adyen.ClientKeyValidator
```
```javascript
@_spi(AdyenInternal) public struct CountryCodeValidator : Validator
```
```javascript
@_spi(AdyenInternal) public init() -> Adyen.CountryCodeValidator
```
```javascript
@_spi(AdyenInternal) public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func maximumLength(for: Swift.String) -> Swift.Int
```
```javascript
@_spi(AdyenInternal) public struct CurrencyCodeValidator : Validator
```
```javascript
@_spi(AdyenInternal) public init() -> Adyen.CurrencyCodeValidator
```
```javascript
@_spi(AdyenInternal) public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func maximumLength(for: Swift.String) -> Swift.Int
```
```javascript
@_spi(AdyenInternal) public final class DateValidator : Validator
```
```javascript
@_spi(AdyenInternal) public init(format: Adyen.DateValidator.Format) -> Adyen.DateValidator
```
```javascript
@_spi(AdyenInternal) public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func maximumLength(for: Swift.String) -> Swift.Int
```
```javascript
@_spi(AdyenInternal) public enum Format : Equatable, Hashable, RawRepresentable
```
```javascript
@_spi(AdyenInternal) public case kcpFormat
```
```javascript
@_spi(AdyenInternal) public init(rawValue: Swift.String) -> Adyen.DateValidator.Format?
```
```javascript
@_spi(AdyenInternal) public typealias RawValue = Swift.String
```
```javascript
@_spi(AdyenInternal) public var rawValue: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public class EmailValidator : Validator
```
```javascript
@_spi(AdyenInternal) public init() -> Adyen.EmailValidator
```
```javascript
@_spi(AdyenInternal) override public init(regularExpression: Swift.String, minimumLength: Swift.Int? = $DEFAULT_ARG, maximumLength: Swift.Int? = $DEFAULT_ARG) -> Adyen.EmailValidator
```
```javascript
@_spi(AdyenInternal) public final class IBANValidator : Validator
```
```javascript
@_spi(AdyenInternal) public init() -> Adyen.IBANValidator
```
```javascript
@_spi(AdyenInternal) public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func maximumLength(for: Swift.String) -> Swift.Int
```
```javascript
@_spi(AdyenInternal) public class LengthValidator : Validator
```
```javascript
@_spi(AdyenInternal) public var minimumLength: Swift.Int? { get set }
```
```javascript
@_spi(AdyenInternal) public var maximumLength: Swift.Int? { get set }
```
```javascript
@_spi(AdyenInternal) public init(minimumLength: Swift.Int? = $DEFAULT_ARG, maximumLength: Swift.Int? = $DEFAULT_ARG) -> Adyen.LengthValidator
```
```javascript
@_spi(AdyenInternal) public init(exactLength: Swift.Int) -> Adyen.LengthValidator
```
```javascript
@_spi(AdyenInternal) public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func maximumLength(for: Swift.String) -> Swift.Int
```
```javascript
@_spi(AdyenInternal) public class NumericStringValidator : Validator
```
```javascript
@_spi(AdyenInternal) override public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) override public init(minimumLength: Swift.Int? = $DEFAULT_ARG, maximumLength: Swift.Int? = $DEFAULT_ARG) -> Adyen.NumericStringValidator
```
```javascript
@_spi(AdyenInternal) override public init(exactLength: Swift.Int) -> Adyen.NumericStringValidator
```
```javascript
@_spi(AdyenInternal) public final class PhoneNumberValidator : Validator
```
```javascript
@_spi(AdyenInternal) public init() -> Adyen.PhoneNumberValidator
```
```javascript
@_spi(AdyenInternal) override public init(regularExpression: Swift.String, minimumLength: Swift.Int? = $DEFAULT_ARG, maximumLength: Swift.Int? = $DEFAULT_ARG) -> Adyen.PhoneNumberValidator
```
```javascript
@_spi(AdyenInternal) public final class PostalCodeValidator : StatusValidator, Validator
```
```javascript
@_spi(AdyenInternal) public func validate(_: Swift.String) -> Adyen.ValidationStatus
```
```javascript
@_spi(AdyenInternal) override public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) override public init(minimumLength: Swift.Int? = $DEFAULT_ARG, maximumLength: Swift.Int? = $DEFAULT_ARG) -> Adyen.PostalCodeValidator
```
```javascript
@_spi(AdyenInternal) override public init(exactLength: Swift.Int) -> Adyen.PostalCodeValidator
```
```javascript
@_spi(AdyenInternal) public class RegularExpressionValidator : Validator
```
```javascript
@_spi(AdyenInternal) public init(regularExpression: Swift.String, minimumLength: Swift.Int? = $DEFAULT_ARG, maximumLength: Swift.Int? = $DEFAULT_ARG) -> Adyen.RegularExpressionValidator
```
```javascript
@_spi(AdyenInternal) override public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) override public func maximumLength(for: Swift.String) -> Swift.Int
```
```javascript
@_spi(AdyenInternal) override public init(minimumLength: Swift.Int? = $DEFAULT_ARG, maximumLength: Swift.Int? = $DEFAULT_ARG) -> Adyen.RegularExpressionValidator
```
```javascript
@_spi(AdyenInternal) override public init(exactLength: Swift.Int) -> Adyen.RegularExpressionValidator
```
```javascript
@_spi(AdyenInternal) public enum ValidationStatus
```
```javascript
@_spi(AdyenInternal) public case valid
```
```javascript
@_spi(AdyenInternal) public case invalid(any Adyen.ValidationError)
```
```javascript
@_spi(AdyenInternal) public var isValid: Swift.Bool { get }
```
```javascript
@_spi(AdyenInternal) public var validationError: (any Adyen.ValidationError)? { get }
```
```javascript
@_spi(AdyenInternal) public protocol ValidationError<Self : Foundation.LocalizedError> : Error, LocalizedError, Sendable
```
```javascript
@_spi(AdyenInternal) public protocol Validator
```
```javascript
@_spi(AdyenInternal) public func isValid<Self where Self : Adyen.Validator>(_: Swift.String) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public func maximumLength<Self where Self : Adyen.Validator>(for: Swift.String) -> Swift.Int
```
```javascript
@_spi(AdyenInternal) public protocol StatusValidator<Self : Adyen.Validator> : Validator
```
```javascript
@_spi(AdyenInternal) public func validate<Self where Self : Adyen.StatusValidator>(_: Swift.String) -> Adyen.ValidationStatus
```
```javascript
@_spi(AdyenInternal) public func ||(_: any Adyen.Validator, _: any Adyen.Validator) -> any Adyen.Validator
```
```javascript
@_spi(AdyenInternal) public func &&(_: any Adyen.Validator, _: any Adyen.Validator) -> any Adyen.Validator
```
```javascript
@_spi(AdyenInternal) public protocol CombinedValidator<Self : Adyen.Validator> : Validator
```
```javascript
@_spi(AdyenInternal) public var firstValidator: any Adyen.Validator { get }
```
```javascript
@_spi(AdyenInternal) public var secondValidator: any Adyen.Validator { get }
```
```javascript
@_spi(AdyenInternal) public func maximumLength<Self where Self : Adyen.CombinedValidator>(for: Swift.String) -> Swift.Int
```
```javascript
@_spi(AdyenInternal) public final class ORValidator : CombinedValidator, Validator
```
```javascript
@_spi(AdyenInternal) public let firstValidator: any Adyen.Validator { get }
```
```javascript
@_spi(AdyenInternal) public let secondValidator: any Adyen.Validator { get }
```
```javascript
@_spi(AdyenInternal) public init(firstValidator: any Adyen.Validator, secondValidator: any Adyen.Validator) -> Adyen.ORValidator
```
```javascript
@_spi(AdyenInternal) public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
@_spi(AdyenInternal) public final class ANDValidator : CombinedValidator, Validator
```
```javascript
@_spi(AdyenInternal) public let firstValidator: any Adyen.Validator { get }
```
```javascript
@_spi(AdyenInternal) public let secondValidator: any Adyen.Validator { get }
```
```javascript
@_spi(AdyenInternal) public init(firstValidator: any Adyen.Validator, secondValidator: any Adyen.Validator) -> Adyen.ANDValidator
```
```javascript
@_spi(AdyenInternal) public func isValid(_: Swift.String) -> Swift.Bool
```
```javascript
@objc public dynamic class Bundle : AdyenCompatible, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSObjectProtocol, Sendable
```
```javascript
@_spi(AdyenInternal) public typealias AdyenBase = Foundation.Bundle
```
```javascript
@_spi(AdyenInternal) public enum Adyen
```
```javascript
@_spi(AdyenInternal) public static var localizedEditCopy: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public static var localizedDoneCopy: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public static let coreInternalResources: Foundation.Bundle { get }
```
```javascript
@objc public dynamic class UIViewController : AdyenCompatible, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSExtensionRequestHandling, NSObjectProtocol, Sendable, UIActivityItemsConfigurationProviding, UIAppearanceContainer, UIContentContainer, UIFocusEnvironment, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UIStateRestoring, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring, ViewControllerPresenter
```
```javascript
@_spi(AdyenInternal) public func presentViewController(_: UIKit.UIViewController, animated: Swift.Bool) -> Swift.Void
```
```javascript
@_spi(AdyenInternal) public func dismissViewController(animated: Swift.Bool) -> Swift.Void
```
```javascript
@objc public dynamic class UIImageView : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityContentSizeCategoryImageAdjusting, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) @discardableResult public func load(url: Foundation.URL, using: any Adyen.ImageLoading, placeholder: UIKit.UIImage? = $DEFAULT_ARG) -> any Adyen.AdyenCancellable
```
```javascript
@_spi(AdyenInternal) public convenience init(style: Adyen.ImageStyle) -> UIKit.UIImageView
```
```javascript
@objc public dynamic class NSLayoutConstraint : AdyenCompatible, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSObjectProtocol
```
```javascript
@_spi(AdyenInternal) public typealias AdyenBase = UIKit.NSLayoutConstraint
```
```javascript
@objc public dynamic enum NSTextAlignment : AdyenCompatible, Equatable, Hashable, RawRepresentable, Sendable
```
```javascript
@_spi(AdyenInternal) public typealias AdyenBase = UIKit.NSTextAlignment
```
```javascript
public enum Result<Success, Failure where Failure : Swift.Error> : Equatable, Hashable, Sendable
```
```javascript
@_spi(AdyenInternal) public func handle<Success, Failure where Failure : Swift.Error>(success: (Success) -> Swift.Void, failure: (Failure) -> Swift.Void) -> Swift.Void
```
```javascript
public struct String : AdyenCompatible, BidirectionalCollection, CVarArg, CodingKeyRepresentable, Collection, Comparable, CustomDebugStringConvertible, CustomReflectable, CustomStringConvertible, Decodable, Encodable, Equatable, ExpressibleByExtendedGraphemeClusterLiteral, ExpressibleByStringInterpolation, ExpressibleByStringLiteral, ExpressibleByUnicodeScalarLiteral, Hashable, LosslessStringConvertible, MirrorPath, RangeReplaceableCollection, Sendable, Sequence, StringProtocol, TextOutputStream, TextOutputStreamable, Transferable
```
```javascript
@_spi(AdyenInternal) public enum Adyen
```
```javascript
@_spi(AdyenInternal) public static let securedString: Swift.String { get }
```
```javascript
@_spi(AdyenInternal) public typealias AdyenBase = Swift.String
```
```javascript
public enum Optional<Wrapped> : AdyenCompatible, Commands, CustomDebugStringConvertible, CustomReflectable, CustomizableToolbarContent, Decodable, DecodableWithConfiguration, Encodable, EncodableWithConfiguration, Equatable, ExpressibleByNilLiteral, Gesture, Hashable, Sendable, TableColumnContent, TableRowContent, ToolbarContent, View
```
```javascript
@_spi(AdyenInternal) public typealias AdyenBase = Wrapped?
```
```javascript
public struct Double : AdditiveArithmetic, AdyenCompatible, Animatable, BinaryFloatingPoint, CVarArg, Comparable, CustomDebugStringConvertible, CustomReflectable, CustomStringConvertible, Decodable, Encodable, Equatable, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral, FloatingPoint, Hashable, LosslessStringConvertible, Numeric, SIMDScalar, Sendable, SignedNumeric, Strideable, TextOutputStreamable, VectorArithmetic
```
```javascript
@_spi(AdyenInternal) public typealias AdyenBase = Swift.Double
```
```javascript
@objc public dynamic class UIButton : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityContentSizeCategoryImageAdjusting, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UIContextMenuInteractionDelegate, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UISpringLoadedInteractionSupporting, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public convenience init(style: Adyen.ButtonStyle) -> UIKit.UIButton
```
```javascript
@objc public dynamic class UIColor : CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSCopying, NSItemProviderReading, NSItemProviderWriting, NSObjectProtocol, NSSecureCoding, Sendable
```
```javascript
public enum Adyen
```
```javascript
public static var dimmBackground: UIKit.UIColor { get }
```
```javascript
public static var componentBackground: UIKit.UIColor { get }
```
```javascript
public static var secondaryComponentBackground: UIKit.UIColor { get }
```
```javascript
public static var componentLabel: UIKit.UIColor { get }
```
```javascript
public static var componentSecondaryLabel: UIKit.UIColor { get }
```
```javascript
public static var componentTertiaryLabel: UIKit.UIColor { get }
```
```javascript
public static var componentQuaternaryLabel: UIKit.UIColor { get }
```
```javascript
public static var componentPlaceholderText: UIKit.UIColor { get }
```
```javascript
public static var componentSeparator: UIKit.UIColor { get }
```
```javascript
public static var componentLoadingMessageColor: UIKit.UIColor { get }
```
```javascript
public static var paidSectionFooterTitleColor: UIKit.UIColor { get }
```
```javascript
public static var paidSectionFooterTitleBackgroundColor: UIKit.UIColor { get }
```
```javascript
public static let defaultBlue: UIKit.UIColor { get }
```
```javascript
public static let defaultRed: UIKit.UIColor { get }
```
```javascript
public static let errorRed: UIKit.UIColor { get }
```
```javascript
public static let lightGray: UIKit.UIColor { get }
```
```javascript
public static let green40: UIKit.UIColor { get }
```
```javascript
@objc public dynamic class UIFont : AdyenCompatible, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSCopying, NSObjectProtocol, NSSecureCoding, Sendable
```
```javascript
@_spi(AdyenInternal) public typealias AdyenBase = UIKit.UIFont
```
```javascript
@objc public dynamic class UILabel : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UIContentSizeCategoryAdjusting, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UILetterformAwareAdjusting, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public convenience init(style: Adyen.TextStyle) -> UIKit.UILabel
```
```javascript
@objc public dynamic class UIProgressView : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public convenience init(style: Adyen.ProgressViewStyle) -> UIKit.UIProgressView
```
```javascript
@objc public dynamic class UIView : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public func accessibilityMarkAsSelected(_: Swift.Bool) -> Swift.Void
```
```javascript
@objc public dynamic class UILayoutGuide : CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, UIPopoverPresentationControllerSourceItem
```
```javascript
@objc public dynamic class UIResponder : AdyenCompatible, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSObjectProtocol, Sendable, UIActivityItemsConfigurationProviding, UIPasteConfigurationSupporting, UIResponderStandardEditActions, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public typealias AdyenBase = UIKit.UIResponder
```
```javascript
public struct URL : AdyenCompatible, CustomDebugStringConvertible, CustomStringConvertible, Decodable, Encodable, Equatable, Hashable, ReferenceConvertible, Sendable, Transferable
```
```javascript
@_spi(AdyenInternal) public typealias AdyenBase = Foundation.URL
```
```javascript
@objc public dynamic class UISearchBar : AdyenCompatible, CALayerDelegate, CVarArg, CustomDebugStringConvertible, CustomStringConvertible, Equatable, Hashable, NSCoding, NSObjectProtocol, Sendable, UIAccessibilityIdentification, UIActivityItemsConfigurationProviding, UIAppearance, UIAppearanceContainer, UIBarPositioning, UICoordinateSpace, UIDynamicItem, UIFocusEnvironment, UIFocusItem, UIFocusItemContainer, UILargeContentViewerItem, UILookToDictateCapable, UIPasteConfigurationSupporting, UIPopoverPresentationControllerSourceItem, UIResponderStandardEditActions, UITextInputTraits, UITraitChangeObservable, UITraitEnvironment, UIUserActivityRestoring
```
```javascript
@_spi(AdyenInternal) public static func prominent(placeholder: Swift.String?, backgroundColor: UIKit.UIColor, delegate: any UIKit.UISearchBarDelegate) -> UIKit.UISearchBar
```
