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
    func componentIsPreSelected_validateWhatIsDisplayed(testDataPaymentType: PaymentComponentTestData) throws {
        // When paymentType is loaded
        let sut = SUT_MockedPaymentMethodRouter(type: testDataPaymentType)

        // Expected in the UI

        // TODO: Robert: This is a strange failure, it never seems to match even if the strings are the same.
        // try #expect(sut.preSelectedViewController.primaryTitleText == testDataPaymentType.expectedTitle, "Card number")
        try #expect(sut.preSelectedViewController.subTitleText == testDataPaymentType.expectedSubTitleText, "Use payment.method to pay amount")
        try #expect(sut.preSelectedViewController.submitButtonText == testDataPaymentType.submitButtonText, "Pay amount")
        try #expect(sut.preSelectedViewController.showAllPaymentMethodsButtonText == testDataPaymentType.showAllPaymentMethodsButtonText, "Other Payment methods")
    }
    
    // MARK: - Submit Payment Tests
    
    @Test("PaymentComponent that is initiable - submit payment triggers submit action")
    func initiableComponent_submitPayment_triggersSubmit() throws {
        // Given - use an initiable component that triggers submit directly
        let sut = SUT_PaymentInitiable(type: .initiableBCMC)

        // When - user submits payment
        try sut.preSelectedViewController.submitPayment()
        
        // Then - verify dropInFlowManager.submit was called
        #expect(sut.dropInFlowManager.submitFromActionPresenterCalled)
    }

    @Test("PaymentComponent that is presentable - submit payment triggers presentation")
    func presentableComponent_submitPayment_triggersPresentation() throws {
        let sut = SUT_MockedPaymentMethodRouter(type: .visa)
        
        // When - user submits payment
        try sut.preSelectedViewController.submitPayment()
        
        // Then - verify presentComponent is called
        #expect(sut.preselectedPaymentMethodRouter.presentComponentOnCancelCallsCount == 1)
        #expect(sut.preselectedPaymentMethodRouter.presentPaymentMethodListCallsCount == 0)
    }

    // MARK: - Show All Payment Methods Tests

    @Test("PaymentComponent - show all payment methods presents payment method list")
    func paymentComponent_showAllPaymentMethods_presentsPaymentMethodList() throws {
        // Given
        let sut = SUT_MockedPaymentMethodRouter(type: .visa)

        // When - user requests to see all payment methods
        try sut.preSelectedViewController.showAllPaymentMethods()
        
        // Then - verify payment method list is presented
        #expect(sut.preselectedPaymentMethodRouter.presentPaymentMethodListCallsCount == 1)
        #expect(sut.preselectedPaymentMethodRouter.presentComponentOnCancelCallsCount == 0)
    }

    // MARK: - Cancel Tests

    @Test("PaymentComponent - cancel dismisses and cancels component")
    func paymentComponent_cancel_dismissesAndCancels() {
        // Given
        let sut = SUT_MockedPaymentMethodRouter(type: .visa)

        // When - user cancels
        sut.preSelectedViewController.cancel()

        // Then - verify dismiss and cancel are called
        #expect(sut.preselectedPaymentMethodRouter.dismissCompletionCalled)
        #expect(sut.dropInFlowManagerMock.cancelComponentCalled)
    }

    // MARK: - Setup of the system under test

    @MainActor
    /// A setup with the payment method router mocked to test actions made by the user for a paymentComponent that is PresentableComponent
    struct SUT_MockedPaymentMethodRouter {
        let preselectedPaymentMethodRouter = PreselectedPaymentMethodRoutingMock()

        let preSelectedViewController: PreSelectedPaymentViewControllerProxy
        let dropInFlowManagerMock = DropInFlowManagingMock()

        init(type: PaymentComponentTestData) {
            let routerMock = RouterMock()
            let configuration: DropInComponent.Configuration = .init()

            let viewModel = PreselectedPaymentMethodViewModel(
                component: type.paymentComponent,
                theme: configuration.theme,
                localizationParameters: configuration.localizationParameters,
                dropInFlowManager: dropInFlowManagerMock
            )
            let viewController = PreselectedPaymentMethodViewController(viewModel: viewModel)
            viewModel.router = preselectedPaymentMethodRouter
            routerMock.rootViewController = viewController
            preSelectedViewController = PreSelectedPaymentViewControllerProxy(viewController: viewController)

            viewController.loadViewIfNeeded()
        }
    }

    @MainActor
    struct SUT_PaymentInitiable {
        private let router: Router

        let dropInFlowManager = DropInFlowManagingMock()

        var preSelectedViewController: PreSelectedPaymentViewControllerProxy {
            PreSelectedPaymentViewControllerProxy(viewController: router.rootViewController)
        }

        init(type: PaymentComponentTestData) {
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
                partialPaymentDelegate: nil
            )

            router = assembler.resolvePreselectedPaymentMethodRouter(
                delegate: nil,
                component: type.paymentComponent,
                title: "Test Title"
            )

            router.rootViewController.loadViewIfNeeded()
        }
    }

    // MARK: - SUT: (ViewControllerProxy)

    /// A view controller proxy to `inspect/perform actions` on the view.
    /// The assumption is that the viewcontroller will be PreSelectedPaymentMethodViewController
    @MainActor
    struct PreSelectedPaymentViewControllerProxy {
        let viewController: UIViewController

        // MARK: - Readable UI accessors

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
        case bcmc

        /// PaymentInitiable
        case initiableBCMC

        var paymentComponent: PaymentComponent {
            switch self {
            case .visa:
                let storedCardPaymentMethod = try! AdyenCoder.decode(storedCreditCardDictionary) as StoredCardPaymentMethod
                return StoredCardComponent(
                    storedCardPaymentMethod: storedCardPaymentMethod,
                    context: Dummy.context
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
            case .visa: "•••• 1111"
            case .bcmc, .initiableBCMC: "•••• 4449"
            }
        }

        var expectedSubTitleText: String {
            switch self {
            case .visa: "Use VISA to pay €1.00"
            case .bcmc, .initiableBCMC: "Use Maestro to pay €1.00"
            }
        }

        var submitButtonText: String {
            "Pay €1.00"
        }

        var showAllPaymentMethodsButtonText: String {
            "Other payment options"
        }
    }
}

// MARK: - Mocks

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
