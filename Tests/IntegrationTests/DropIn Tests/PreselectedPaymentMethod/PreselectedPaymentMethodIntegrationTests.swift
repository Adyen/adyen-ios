//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenCard
@testable import AdyenDropIn
@testable import AdyenEncryption
@_spi(AdyenInternal) @testable import AdyenUI
import Testing
import UIKit

@MainActor
struct PreselectedPaymentMethodIntegrationTests {

    // MARK: - UI Display Tests

    @Test("PaymentComponent - UI fields", arguments: PaymentComponentTestData.allCases)
    func componentIsPreSelected_validateWhatIsDisplayed(testData: PaymentComponentTestData) throws {
        // When paymentType is loaded
        let (preSelectedViewController, _, _) = makeSUT(component: testData.paymentComponent)

        preSelectedViewController.load()
        // Expected in the UI

        try #expect(preSelectedViewController.primaryTitleText == testData.expectedTitle, "Card number")
        try #expect(preSelectedViewController.subTitleText == testData.expectedSubTitleText, "Use payment.method")
        try #expect(preSelectedViewController.submitButtonText == testData.submitButtonText, "Pay button title is incorrect")
        try #expect(preSelectedViewController.showAllPaymentMethodsButtonText == testData.showAllPaymentMethodsButtonText, "Other Payment methods")
    }
    
    // MARK: - Submit Payment Tests
    
    @Test("PaymentComponent that is initiable - submit payment triggers submit action")
    func initiableComponent_submitPayment_triggersSubmit() throws {
        // Given - use an initiable component that triggers submit directly
        let dropInFlowManager = DropInFlowManagingMock()
        let preSelectedViewController = makeSUT(
            dropInFlowManager: dropInFlowManager,
            component: PaymentComponentTestData.initiableBCMC.paymentComponent
        )

        // When - user submits payment
        preSelectedViewController.load()
        try preSelectedViewController.submitPayment()
        
        // Then - verify dropInFlowManager.submit was called
        #expect(dropInFlowManager.submitFromActionPresenterCalled)
    }

    @Test("PaymentComponent that is presentable - submit payment triggers presentation")
    func presentableComponent_submitPayment_triggersPresentation() throws {
        let mockedRouter = PreselectedPaymentMethodRoutingMock()
        let (preSelectedViewController, _, _) = makeSUT(mockedRouter: mockedRouter, component: PaymentComponentTestData.visa.paymentComponent)

        // When - user submits payment
        preSelectedViewController.load()
        try preSelectedViewController.submitPayment()
        
        // Then - verify presentComponent is called
        #expect(mockedRouter.presentComponentOnCancelCallsCount == 1)
        #expect(mockedRouter.presentPaymentMethodListCallsCount == 0)
    }

    // MARK: - Show All Payment Methods Tests

    @Test("PaymentComponent - show all payment methods presents payment method list")
    func paymentComponent_showAllPaymentMethods_presentsPaymentMethodList() throws {
        // Given
        let mockedRouter = PreselectedPaymentMethodRoutingMock()
        let (preSelectedViewController, _, _) = makeSUT(mockedRouter: mockedRouter, component: PaymentComponentTestData.visa.paymentComponent)

        // When - user requests to see all payment methods
        preSelectedViewController.load()
        try preSelectedViewController.showAllPaymentMethods()
        
        // Then - verify payment method list is presented
        #expect(mockedRouter.presentPaymentMethodListCallsCount == 1)
        #expect(mockedRouter.presentComponentOnCancelCallsCount == 0)
    }

    // MARK: - Sending event on didLoad

    @Test("On preselected payment method load - we send an info event on load")
    func paymentComponent_onLoad_sendsInfoEvent() throws {
        // Given
        let (preSelectedViewController, _, analyticsProviderMock) = makeSUT(component: PaymentComponentTestData.visa.paymentComponent)

        preSelectedViewController.load()

        // Then - verify info event is sent on load
        #expect(analyticsProviderMock.infos.count == 1)
        let infoEvent = try #require(analyticsProviderMock.infos.first)
        #expect(infoEvent.component == "dropin")
        #expect(infoEvent.type == AnalyticsEventInfo.InfoType.rendered)
    }

    // MARK: - Cancel Tests

    @Test("PaymentComponent - cancel dismisses and cancels component")
    func paymentComponent_cancel_dismissesAndCancels() {
        // Given
        let testData = PaymentComponentTestData.visa
        let mockedRouter = PreselectedPaymentMethodRoutingMock()
        let (preSelectedViewController, dropInFlowManagerMock, _) = makeSUT(mockedRouter: mockedRouter, component: testData.paymentComponent)

        preSelectedViewController.load()
        // When - user cancels
        preSelectedViewController.cancel()

        // Then - verify dismiss and cancel are called
        #expect(mockedRouter.dismissCompletionCalled)
        #expect(dropInFlowManagerMock.cancelComponentCalled)
    }

    // MARK: - Setup of the system under test

    /// A setup with the payment method router mocked to test actions made by the user for a paymentComponent that is PresentableComponent
    private func makeSUT(
        mockedRouter: PreselectedPaymentMethodRoutingMock? = nil,
        component: PaymentComponent
    ) -> (
        preSelectedViewController: PreSelectedPaymentViewControllerProxy,
        dropInFlowManagerMock: DropInFlowManagingMock,
        analyticsProviderMock: AnalyticsProviderMock
    ) {
        let mockedRouter = mockedRouter ?? PreselectedPaymentMethodRoutingMock()
        let dropInFlowManagerMock = DropInFlowManagingMock()
        let analyticsProviderMock = AnalyticsProviderMock()
        let routerMock = RouterMock()
        let configuration: DropInComponent.Configuration = .init()

        let viewModel = PreselectedPaymentMethodViewModel(
            component: component,
            theme: configuration.theme,
            localizationParameters: configuration.localizationParameters,
            analyticsProvider: analyticsProviderMock,
            dropInAnalyticsConfiguration: DropInAnalyticsConfiguration(configuration: configuration),
            dropInFlowManager: dropInFlowManagerMock
        )
        let viewController = PreselectedPaymentMethodViewController(viewModel: viewModel)
        viewModel.router = mockedRouter
        routerMock.rootViewController = viewController
        let preSelectedViewController = PreSelectedPaymentViewControllerProxy(viewController: viewController)

        return (preSelectedViewController, dropInFlowManagerMock, analyticsProviderMock)
    }

    private func makeSUT(
        dropInFlowManager: DropInFlowManagingMock,
        component: PaymentComponent
    ) -> PreSelectedPaymentViewControllerProxy {
        let paymentMethodListAssemblerMock = PaymentMethodListAssemblerProtocolMock()
        let componentContainerAssemblerMock = ComponentContainerAssemblerProtocolMock()
        let componentContainerRouterMock = RouterMock()
        componentContainerRouterMock.rootViewController = UIViewController()
        componentContainerAssemblerMock.resolveComponentContainerRouterForDelegateOnCancelReturnValue = componentContainerRouterMock

        let assembler = PreselectedPaymentMethodAssembler(
            paymentMethodListAssembler: paymentMethodListAssemblerMock,
            componentContainerAssembler: componentContainerAssemblerMock,
            configuration: .init(),
            dropInFlowManager: dropInFlowManager,
            partialPaymentDelegate: nil,
            analyticsProvider: AnalyticsProviderMock()
        )

        let router = assembler.resolvePreselectedPaymentMethodRouter(
            delegate: nil,
            component: component,
            title: "Test Title"
        )

        return PreSelectedPaymentViewControllerProxy(viewController: router.rootViewController)
    }

    // MARK: - SUT: (ViewControllerProxy)

    /// A view controller proxy to `inspect/perform actions` on the view.
    /// The assumption is that the viewcontroller will be PreSelectedPaymentMethodViewController
    @MainActor
    struct PreSelectedPaymentViewControllerProxy {
        let viewController: UIViewController

        // MARK: - Readable UI accessors

        func load() {
            viewController.loadViewIfNeeded()
        }

        var primaryTitleText: String {
            get throws {
                let titleLabel = try #require(viewController.view.findView(by: "title") as? UILabel)
                return try #require(titleLabel.text)
            }
        }

        var subTitleText: String {
            get throws {
                let secondaryTitleLabel = try #require(viewController.view.findView(by: "subTitle") as? UILabel)
                return try #require(secondaryTitleLabel.text)
            }
        }

        var submitButtonText: String {
            get throws {
                let button = try submitButton()
                return try #require(button.title)
            }
        }

        var showAllPaymentMethodsButtonText: String {
            get throws {
                let button = try showAllPaymentMethodsButton()
                return try #require(button.title)
            }
        }

        // MARK: - UI elements

        func submitButton() throws -> FormButton {
            try #require(
                viewController.view.findView(by: "primaryButton") as? FormButton,
                "Cannot find submitButton - Check if the element exists in the view."
            )
        }

        func showAllPaymentMethodsButton() throws -> FormButton {
            try #require(
                viewController.view.findView(by: "secondaryButton") as? FormButton,
                "Cannot find showAllPaymentMethodsButton - Check if the element exists in the view."
            )
        }

        // MARK: - User Actions

        func submitPayment() throws {
            let button = try submitButton()
            button.sendActions(for: .touchUpInside)
        }

        func showAllPaymentMethods() throws {
            let button = try showAllPaymentMethodsButton()
            button.sendActions(for: .touchUpInside)
        }

        func cancel() {
            let cancelButton = viewController.navigationItem.leftBarButtonItem
            _ = cancelButton?.target?.perform(cancelButton?.action)
        }
    }

    // MARK: - Test data
    
    enum PaymentComponentTestData: CaseIterable {
        // PrsentableComponent
        case visa
        case visaWithoutAmount
        case visaWithZeroAmount

        case bcmc

        /// PaymentInitiable
        case initiableBCMC

        @MainActor
        var paymentComponent: PaymentComponent {
            switch self {
            case .visa:
                let storedCardPaymentMethod = try! AdyenCoder.decode(storedCreditCardDictionary) as StoredCardPaymentMethod
                return StoredCardComponent(
                    storedCardPaymentMethod: storedCardPaymentMethod,
                    context: Dummy.context(with: Amount(value: 100, currencyCode: "EUR")),
                    theme: CheckoutTheme()
                )

            case .visaWithoutAmount:
                let storedCardPaymentMethod = try! AdyenCoder.decode(storedCreditCardDictionary) as StoredCardPaymentMethod
                return StoredCardComponent(
                    storedCardPaymentMethod: storedCardPaymentMethod,
                    context: Dummy.context(with: nil),
                    theme: CheckoutTheme()
                )

            case .visaWithZeroAmount:
                let storedCardPaymentMethod = try! AdyenCoder.decode(storedCreditCardDictionary) as StoredCardPaymentMethod
                return StoredCardComponent(
                    storedCardPaymentMethod: storedCardPaymentMethod,
                    context: Dummy.context(with: Amount(value: 0, currencyCode: "EUR")),
                    theme: CheckoutTheme()
                )

            case .bcmc:
                let paymentMethod = try! AdyenCoder.decode(storedBcmcDictionary) as StoredBCMCPaymentMethod
                return StoredPaymentMethodComponent(
                    paymentMethod: paymentMethod,
                    context: Dummy.context
                )

            case .initiableBCMC:
                let paymentMethod = try! AdyenCoder.decode(storedBcmcDictionary) as StoredBCMCPaymentMethod
                // Need to create a Mock Component that implements both PaymentComponent and PaymentInitiable
                // to check if the dropInFlowManager's submit is called
                return InitiablePaymentComponentMock(paymentMethod: paymentMethod, context: Dummy.context)
            }
        }

        var expectedTitle: String {
            switch self {
            case .visa, .visaWithoutAmount, .visaWithZeroAmount: "\(String.Adyen.securedString)1111"
            case .bcmc, .initiableBCMC: "\(String.Adyen.securedString)4449"
            }
        }

        var expectedSubTitleText: String {
            switch self {
            case .visa, .visaWithoutAmount, .visaWithZeroAmount: "Use VISA"
            case .bcmc, .initiableBCMC: "Use Maestro"
            }
        }

        var submitButtonText: String {
            switch self {
            case .visa, .bcmc, .initiableBCMC: "Pay €1.00"
            case .visaWithoutAmount: "Pay"
            case .visaWithZeroAmount: "Confirm preauthorization"
            }
        }

        var showAllPaymentMethodsButtonText: String {
            "Other payment options"
        }
    }
}

// MARK: - Mocks

internal class DropInFlowManagingMock: DropInFlowManaging {
    var submitFromActionPresenterCallsCount = 0
    var submitFromActionPresenterCalled: Bool {
        submitFromActionPresenterCallsCount > 0
    }

    var submitFromActionPresenterReceivedArguments: (
        data: PaymentComponentData,
        component: PaymentComponent,
        actionPresenter: ActionPresenter
    )?

    func submit(_ data: PaymentComponentData, from component: PaymentComponent, actionPresenter: ActionPresenter) {
        submitFromActionPresenterCallsCount += 1
        submitFromActionPresenterReceivedArguments = (data, component, actionPresenter)
    }

    var failWithFromCallsCount = 0
    var failWithFromCalled: Bool {
        failWithFromCallsCount > 0
    }

    func fail(with error: Error, from component: PaymentComponent) {
        failWithFromCallsCount += 1
    }

    var cancelComponentCallsCount = 0
    var cancelComponentCalled: Bool {
        cancelComponentCallsCount > 0
    }

    func cancel(component: PaymentComponent) {
        cancelComponentCallsCount += 1
    }

    var handleActionCallsCount = 0

    func handle(action: Action) {
        handleActionCallsCount += 1
    }
}

internal class PreselectedPaymentMethodRoutingMock: PreselectedPaymentMethodRouting {
    var presentPaymentMethodListCallsCount = 0

    func presentPaymentMethodList() {
        presentPaymentMethodListCallsCount += 1
    }

    var presentComponentOnCancelCallsCount = 0

    func present(component: PaymentComponent) {
        presentComponentOnCancelCallsCount += 1
    }

    var presentActionComponentOnCancelCallsCount = 0

    func present(actionComponent: PresentableComponent, onCancel: (() -> Void)?) {
        presentActionComponentOnCancelCallsCount += 1
    }

    var dismissCompletionCallsCount = 0
    var dismissCompletionCalled: Bool {
        dismissCompletionCallsCount > 0
    }

    func dismiss(completion: (() -> Void)?) {
        dismissCompletionCallsCount += 1
        completion?()
    }
}

internal class RouterMock: Router {
    var childRouter: Router?
    var rootViewController: UIViewController = .init()
}

internal class PaymentMethodListAssemblerProtocolMock: PaymentMethodListAssemblerProtocol {
    var resolvePaymentMethodListRouterDelegateReturnValue: Router?

    func resolvePaymentMethodListRouter(delegate: PaymentMethodListRouterListener?) -> Router {
        resolvePaymentMethodListRouterDelegateReturnValue ?? RouterMock()
    }
}

internal class ComponentContainerAssemblerProtocolMock: ComponentContainerAssemblerProtocol {
    var resolveComponentContainerRouterForDelegateOnCancelReturnValue: Router?

    func resolveComponentContainerRouter(for component: PresentableComponent, listener: ComponentContainerRouterListener) -> Router {
        resolveComponentContainerRouterForDelegateOnCancelReturnValue ?? RouterMock()
    }
}

internal class InitiablePaymentComponentMock: PaymentComponent, InitiablePaymentComponent {

    var context: AdyenContext
    var paymentMethod: PaymentMethod
    weak var delegate: PaymentComponentDelegate?
    var order: PartialPaymentOrder?

    init(paymentMethod: PaymentMethod, context: AdyenContext) {
        self.paymentMethod = paymentMethod
        self.context = context
    }

    func initiatePayment() {}

    func initiatePayment(delegate: PaymentComponentDelegate) {
        self.delegate = delegate
        let details = StoredPaymentDetails(paymentMethod: paymentMethod as! StoredPaymentMethod)
        let data = PaymentComponentData(
            paymentMethodDetails: details,
            amount: context.amount,
            order: order
        )
        self.delegate?.didSubmit(data, from: self)
    }
}
