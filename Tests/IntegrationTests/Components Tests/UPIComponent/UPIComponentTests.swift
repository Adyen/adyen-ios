//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenComponents
import XCTest

// MARK: - UPIComponentTests

class UPIComponentTests: XCTestCase {
    
    // MARK: - UPI App List Title Tests

    func test_appsListTitle_withLocalAppsInstalled_shouldShowOnYourDevice() throws {
        // Given - tez is installed
        let schemeChecker = URLSchemeCheckerMock()
        schemeChecker.openableSchemes = ["tez"]
        
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upiWithApps),
            context: Dummy.context,
            urlSchemeChecker: schemeChecker
        )
        
        // Then - title should indicate local apps
        XCTAssertEqual(sut.appsListTitleItem.content.text, "On your device")
    }
    
    func test_appsListTitle_withNoLocalAppsInstalled_shouldShowOptions() throws {
        // Given - no apps installed
        let schemeChecker = URLSchemeCheckerMock()
        schemeChecker.openableSchemes = []
        
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upiWithApps),
            context: Dummy.context,
            urlSchemeChecker: schemeChecker
        )
        
        // Then - title should indicate fallback options
        XCTAssertEqual(sut.appsListTitleItem.content.text, "Options")
    }
    
    // MARK: - App Detection Tests
    
    func test_availableUPI_withInstalledApps_shouldReturnOnlyInstalledApps() throws {
        // Given - only tez (Google Pay) is installed
        let schemeChecker = URLSchemeCheckerMock()
        schemeChecker.openableSchemes = ["tez", "payzapp", "hdfcbank"]

        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upiWithApps),
            context: Dummy.context,
            urlSchemeChecker: schemeChecker
        )
        
        // Then - should only show installed apps
        XCTAssertEqual(sut.upiAppsList.count, 1)
        XCTAssertEqual(sut.upiAppsList.first?.identifier, "gpay")
    }
    
    func test_availableUPI_withNoInstalledApps_shouldFallbackToAllBackendApps() throws {
        // Given - no apps installed
        let schemeChecker = URLSchemeCheckerMock()
        schemeChecker.openableSchemes = []
        
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upiWithApps),
            context: Dummy.context,
            urlSchemeChecker: schemeChecker
        )
        
        // Then - should show all apps from backend as fallback
        XCTAssertTrue(sut.upiAppsList.count > 0)
    }
    
    func test_availableUPI_withMultipleInstalledApps_shouldReturnAllInstalledApps() throws {
        // Given - tez and phonepe are installed
        let schemeChecker = URLSchemeCheckerMock()
        schemeChecker.openableSchemes = ["tez", "phonepe"]
        
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upiWithApps),
            context: Dummy.context,
            urlSchemeChecker: schemeChecker
        )
        
        // Then - should show both installed apps
        XCTAssertEqual(sut.upiAppsList.count, 2)
        let identifiers = sut.upiAppsList.map(\.identifier)
        XCTAssertTrue(identifiers.contains("gpay"))
        XCTAssertTrue(identifiers.contains("phonepe"))
    }
    
    func test_availableUPI_withAppNotInBackendList_shouldNotShowApp() throws {
        // Given - "someRandomApp" is installed but not in backend apps list
        let schemeChecker = URLSchemeCheckerMock()
        schemeChecker.openableSchemes = ["someRandomApp"]
        
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upiWithApps),
            context: Dummy.context,
            urlSchemeChecker: schemeChecker
        )
        
        // Then - should fallback to all backend apps since no matching local apps
        // Note: UPIPaymentMethod has hardcoded mock apps
        XCTAssertTrue(sut.upiAppsList.count > 0)
        XCTAssertTrue(sut.installedUPIApps.isEmpty)
    }
    
    func test_availableUPI_withMixedInstalledApps_shouldOnlyShowMatchingApps() throws {
        // Given - tez is installed (matches backend), "randomApp" is installed (doesn't match)
        let schemeChecker = URLSchemeCheckerMock()
        schemeChecker.openableSchemes = ["tez", "randomApp"]
        
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upiWithApps),
            context: Dummy.context,
            urlSchemeChecker: schemeChecker
        )
        
        // Then - should only show gpay (which uses tez scheme), not randomApp
        XCTAssertEqual(sut.upiAppsList.count, 1)
        XCTAssertEqual(sut.upiAppsList.first?.identifier, "gpay")
    }
    
    func test_installedUPIApps_withInstalledApps_shouldNotBeEmpty() throws {
        // Given
        let schemeChecker = URLSchemeCheckerMock()
        schemeChecker.openableSchemes = ["tez"]

        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upiWithApps),
            context: Dummy.context,
            urlSchemeChecker: schemeChecker
        )
        
        // Then
        XCTAssertFalse(sut.installedUPIApps.isEmpty)
    }
    
    func test_installedUPIApps_withNoInstalledApps_shouldBeEmpty() throws {
        // Given
        let schemeChecker = URLSchemeCheckerMock()
        schemeChecker.openableSchemes = []
        
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upiWithApps),
            context: Dummy.context,
            urlSchemeChecker: schemeChecker
        )
        
        // Then
        XCTAssertTrue(sut.installedUPIApps.isEmpty)
    }
    
    func test_installedUPIApps_withNilApps_shouldBeEmpty() throws {
        // Given - upi has no apps property
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upi),
            context: Dummy.context
        )
        
        // Then
        XCTAssertTrue(sut.installedUPIApps.isEmpty)
    }

    func test_availableUPIApps_withNilApps_shouldBeEmpty() throws {
        // Given - upi has no apps property
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upi),
            context: Dummy.context
        )

        // Then
        XCTAssertTrue(sut.availableUPIApps.isEmpty)
    }
    
    func test_installedUPIApps_withMultipleInstalledApps_shouldReturnAllMatching() throws {
        // Given - tez (gpay) and phonepe are installed
        let schemeChecker = URLSchemeCheckerMock()
        schemeChecker.openableSchemes = ["tez", "phonepe"]
        
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upiWithApps),
            context: Dummy.context,
            urlSchemeChecker: schemeChecker
        )
        
        // Then
        XCTAssertEqual(sut.installedUPIApps.count, 2)
        let identifiers = sut.installedUPIApps.map(\.identifier)
        XCTAssertTrue(identifiers.contains("gpay"))
        XCTAssertTrue(identifiers.contains("phonepe"))
    }

    func test_init_withApps() throws {
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upiWithApps),
            context: Dummy.context
        )
        
        XCTAssertEqual(sut.currentSelectedItemIdentifier, nil)
    }
    
    func test_init_withoutApps_shouldSetSelectedItemIdentifierToNil() throws {
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upi),
            context: Dummy.context
        )
        
        XCTAssertEqual(sut.currentSelectedItemIdentifier, nil)
    }

    func test_paymentMethodType_isUpi() throws {
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upi),
            context: Dummy.context
        )

        XCTAssertEqual(sut.paymentMethod.type, .upi)
    }

    func test_shouldRequireModalPresentation() throws {
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upi),
            context: Dummy.context
        )

        XCTAssertTrue(sut.requiresModalPresentation)
    }

    func test_requiresKeyboardInput() throws {
        let sut = try UPIComponent(
            paymentMethod: AdyenCoder.decode(upi),
            context: Dummy.context
        )
        
        let securedViewController = try XCTUnwrap(sut.viewController as? SecuredViewController<FormViewController>)
        let childViewController = securedViewController.childViewController

        XCTAssertTrue(childViewController.requiresKeyboardInput)
    }

    func testSubmit_shouldCallPaymentDelegateDidSubmit() throws {
        // Given
        let paymentMethod: UPIPaymentMethod = try AdyenCoder.decode(upi)
        let sut = UPIComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context
        )
        
        // Switch to upiCollect flow where VPA input is used
        sut.upiFlowSelectionItem.selectionHandler?(1)

        setupRootViewController(sut.viewController)

        let didSubmitExpectation = XCTestExpectation(description: "Expect delegate.didSubmit() to be called.")

        let delegateMock = PaymentComponentDelegateMock()
        sut.delegate = delegateMock
        delegateMock.onDidSubmit = { data, component in
            didSubmitExpectation.fulfill()
        }

        // VPA input is visible in upiCollect flow
        let vpaInputItem: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.virtualPaymentAddressInputItem"))
        self.populate(textItemView: vpaInputItem, with: "testvpa@icici")

        // When
        sut.submit()

        // Then
        wait(for: [didSubmitExpectation], timeout: 10)
        XCTAssertEqual(delegateMock.didSubmitCallsCount, 1)
    }

    func testValidateGivenValidInputShouldReturnFormViewControllerValidateResult() throws {
        // Given
        let paymentMethod: UPIPaymentMethod = try AdyenCoder.decode(upi)
        let configuration = UPIComponent.Configuration(showsSubmitButton: false)
        let sut = UPIComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )

        let vpaInputItem: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.viewController.view.findView(with: "AdyenComponents.UPIComponent.virtualPaymentAddressInputItem"))
        self.populate(textItemView: vpaInputItem, with: "testvpa@icici")

        let formViewController = try XCTUnwrap((sut.viewController as? SecuredViewController<FormViewController>)?.childViewController)
        let expectedResult = formViewController.validate()

        // When
        let validationResult = sut.validate()

        // Then
        XCTAssertTrue(validationResult)
        XCTAssertEqual(expectedResult, validationResult)
    }

    func testValidateGivenInvalidInputShouldReturnFormViewControllerValidateResult() throws {
        // Given
        let paymentMethod: UPIPaymentMethod = try AdyenCoder.decode(upi)
        let configuration = UPIComponent.Configuration(showsSubmitButton: false)
        let sut = UPIComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: configuration
        )
        
        // Load the view to trigger form setup
        _ = sut.viewController.view
        
        // Switch to upiCollect flow where VPA input is required for validation
        sut.upiFlowSelectionItem.selectionHandler?(1)

        // When - validate without providing VPA input
        let validationResult = sut.validate()

        // Then - should fail because VPA is empty
        XCTAssertFalse(validationResult)
    }
    
    // MARK: - Analytics Tests
    
    func test_viewDidLoad_shouldSendInitialAnalytics() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        let paymentMethod: UPIPaymentMethod = try AdyenCoder.decode(upi)
        let sut = UPIComponent(paymentMethod: paymentMethod, context: context)
        
        // When
        sut.viewDidLoad(viewController: UIViewController())
        
        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
    }
    
    func test_viewDidLoad_shouldSendRenderedEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        let paymentMethod: UPIPaymentMethod = try AdyenCoder.decode(upi)
        let sut = UPIComponent(paymentMethod: paymentMethod, context: context)
        
        // When
        sut.viewDidLoad(viewController: UIViewController())
        
        // Then
        let renderedEvents = analyticsProviderMock.infos.filter { $0.type == .rendered }
        XCTAssertEqual(renderedEvents.count, 1)
        XCTAssertEqual(renderedEvents.first?.component, "upi")
    }
    
    func test_viewDidAppear_withAppsAvailable_shouldSendUPIIntentDisplayedEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        let schemeChecker = URLSchemeCheckerMock()
        schemeChecker.openableSchemes = ["tez"]
        
        let paymentMethod: UPIPaymentMethod = try AdyenCoder.decode(upiWithApps)
        let sut = UPIComponent(
            paymentMethod: paymentMethod,
            context: context,
            urlSchemeChecker: schemeChecker
        )
        
        // When
        sut.viewDidAppear(viewController: UIViewController())
        
        // Then
        let displayedEvents = analyticsProviderMock.infos.filter { $0.type == .displayed }
        XCTAssertEqual(displayedEvents.count, 1)
        XCTAssertEqual(displayedEvents.first?.component, "upi_intent")
        XCTAssertEqual(displayedEvents.first?.target, .listDetected)
    }
    
    func test_viewDidAppear_withNoInstalledApps_shouldSendUPIIntentDisplayedEventWithIssuerListTarget() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        let schemeChecker = URLSchemeCheckerMock()
        schemeChecker.openableSchemes = []
        
        let paymentMethod: UPIPaymentMethod = try AdyenCoder.decode(upiWithApps)
        let sut = UPIComponent(
            paymentMethod: paymentMethod,
            context: context,
            urlSchemeChecker: schemeChecker
        )
        
        // When
        sut.viewDidAppear(viewController: UIViewController())
        
        // Then
        let displayedEvents = analyticsProviderMock.infos.filter { $0.type == .displayed }
        XCTAssertEqual(displayedEvents.count, 1)
        XCTAssertEqual(displayedEvents.first?.component, "upi_intent")
        XCTAssertEqual(displayedEvents.first?.target, .issuerList)
    }
    
    func test_viewDidAppear_withInstalledApps_shouldIncludePresentedValuesInDisplayedEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        let schemeChecker = URLSchemeCheckerMock()
        schemeChecker.openableSchemes = ["tez", "phonepe"]
        
        let paymentMethod: UPIPaymentMethod = try AdyenCoder.decode(upiWithApps)
        let sut = UPIComponent(
            paymentMethod: paymentMethod,
            context: context,
            urlSchemeChecker: schemeChecker
        )
        
        // When
        sut.viewDidAppear(viewController: UIViewController())
        
        // Then
        let displayedEvents = analyticsProviderMock.infos.filter { $0.type == .displayed }
        XCTAssertEqual(displayedEvents.count, 1)
        
        let presentedValues = displayedEvents.first?.presentedValues
        XCTAssertNotNil(presentedValues)
        XCTAssertTrue(presentedValues?.contains("gpay") ?? false)
        XCTAssertTrue(presentedValues?.contains("phonepe") ?? false)
    }
    
    func test_viewDidAppear_withNoApps_shouldSendUPICollectDisplayedEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        let paymentMethod: UPIPaymentMethod = try AdyenCoder.decode(upi)
        let sut = UPIComponent(paymentMethod: paymentMethod, context: context)
        
        // When
        sut.viewDidAppear(viewController: UIViewController())
        
        // Then
        let displayedEvents = analyticsProviderMock.infos.filter { $0.type == .displayed }
        XCTAssertEqual(displayedEvents.count, 1)
        XCTAssertEqual(displayedEvents.first?.component, "upi_collect")
    }
    
    func test_switchingToCollectFlow_shouldSendUPICollectDisplayedEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        let schemeChecker = URLSchemeCheckerMock()
        schemeChecker.openableSchemes = ["tez"]
        
        let paymentMethod: UPIPaymentMethod = try AdyenCoder.decode(upiWithApps)
        let sut = UPIComponent(
            paymentMethod: paymentMethod,
            context: context,
            urlSchemeChecker: schemeChecker
        )
        
        // Clear any initial events
        analyticsProviderMock.clearAll()
        
        // When - switch to UPI Collect flow (index 1)
        sut.upiFlowSelectionItem.selectionHandler?(1)
        
        // Then
        let displayedEvents = analyticsProviderMock.infos.filter { $0.type == .displayed }
        XCTAssertEqual(displayedEvents.count, 1)
        XCTAssertEqual(displayedEvents.first?.component, "upi_collect")
    }
    
    func test_switchingBackToIntentFlow_shouldSendUPIIntentDisplayedEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        let schemeChecker = URLSchemeCheckerMock()
        schemeChecker.openableSchemes = ["tez"]
        
        let paymentMethod: UPIPaymentMethod = try AdyenCoder.decode(upiWithApps)
        let sut = UPIComponent(
            paymentMethod: paymentMethod,
            context: context,
            urlSchemeChecker: schemeChecker
        )
        
        // Switch to collect first
        sut.upiFlowSelectionItem.selectionHandler?(1)
        
        // Clear events
        analyticsProviderMock.clearAll()
        
        // When - switch back to UPI Intent flow (index 0)
        sut.upiFlowSelectionItem.selectionHandler?(0)
        
        // Then
        let displayedEvents = analyticsProviderMock.infos.filter { $0.type == .displayed }
        XCTAssertEqual(displayedEvents.count, 1)
        XCTAssertEqual(displayedEvents.first?.component, "upi_intent")
    }
    
    func test_selectingUPIApp_shouldSendSelectedEvent() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        let schemeChecker = URLSchemeCheckerMock()
        schemeChecker.openableSchemes = ["tez"]
        
        let paymentMethod: UPIPaymentMethod = try AdyenCoder.decode(upiWithApps)
        let sut = UPIComponent(
            paymentMethod: paymentMethod,
            context: context,
            urlSchemeChecker: schemeChecker
        )
        
        // Clear any initial events
        analyticsProviderMock.clearAll()
        
        // When - select the first app (gpay)
        let firstAppItem = sut.upiAppsList.first
        firstAppItem?.selectionHandler?()
        
        // Then
        let selectedEvents = analyticsProviderMock.infos.filter { $0.type == .selected }
        XCTAssertEqual(selectedEvents.count, 1)
        XCTAssertEqual(selectedEvents.first?.component, "upi_intent")
        XCTAssertEqual(selectedEvents.first?.issuer, "gpay")
        XCTAssertEqual(selectedEvents.first?.target, .listDetected)
    }
    
    func test_selectingUPIApp_withNoInstalledApps_shouldSendSelectedEventWithIssuerListTarget() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        let schemeChecker = URLSchemeCheckerMock()
        schemeChecker.openableSchemes = []
        
        let paymentMethod: UPIPaymentMethod = try AdyenCoder.decode(upiWithApps)
        let sut = UPIComponent(
            paymentMethod: paymentMethod,
            context: context,
            urlSchemeChecker: schemeChecker
        )
        
        // Clear any initial events
        analyticsProviderMock.clearAll()
        
        // When - select the first app (bhim - first in the list when no apps installed)
        let firstAppItem = sut.upiAppsList.first
        firstAppItem?.selectionHandler?()
        
        // Then
        let selectedEvents = analyticsProviderMock.infos.filter { $0.type == .selected }
        XCTAssertEqual(selectedEvents.count, 1)
        XCTAssertEqual(selectedEvents.first?.component, "upi_intent")
        XCTAssertEqual(selectedEvents.first?.issuer, "bhim")
        XCTAssertEqual(selectedEvents.first?.target, .issuerList)
    }

}
