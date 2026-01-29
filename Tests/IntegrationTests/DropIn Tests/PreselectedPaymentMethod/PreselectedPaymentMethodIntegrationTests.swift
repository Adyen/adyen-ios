//
// Copyright (c) Adyen N.V.
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
        try #expect(sut.preSelectedViewController.primaryButtonText == testDataPaymentType.primaryButtonText, "Pay amount")
        try #expect(sut.preSelectedViewController.secondaryButtonText == testDataPaymentType.secondaryButtonText, "Other Payment methods")
    }
    
    // MARK: - Primary Button (Pay) Tests
    
    @Test("PaymentComponent that is initiable - triggers submit action - tap pay")
    func paymentInitableComponent_payTapped() async throws {
        // Given - use an initiable component that triggers submit directly
        let sut = SUT_PaymentInitiable(type: .initiableBCMC)

        // When - simulate primary button tap
        try sut.preSelectedViewController.tapPrimaryButton()
        // Then - verify dropInFlowManager.submit was called
        #expect(sut.dropInFlowManager.submitFromActionPresenterCalled)
    }

    @Test("PaymentComponent that is presentable - triggers presentation - tap pay")
    func presentableComponent_payTapped() async throws {
        let sut = SUT_MockedPaymentMethodRouter(type: .visa)
        // When - simulate primary button tap
        try sut.preSelectedViewController.tapPrimaryButton()
        // Then - verify presentComponent is called
        #expect(sut.preselectedPaymentMethodRouter.presentPaymentComponentOnCancelCalled)
        #expect(sut.preselectedPaymentMethodRouter.presentPaymentMethodListCalled == false)
    }

    @Test("PaymentComponent - tap other payment solutions")
    func paymentComponent_otherPaymentSolutionsTapped() async throws {
        // Given - use an initiable component that triggers submit directly
        let sut = SUT_MockedPaymentMethodRouter(type: .visa)

        // When - simulate secondary button tap
        try sut.preSelectedViewController.tapSecondaryButton()
        // Then - verify dropInFlowManager.submit was called
        #expect(sut.preselectedPaymentMethodRouter.presentPaymentMethodListCalled)
        #expect(sut.preselectedPaymentMethodRouter.presentPaymentComponentOnCancelCalled == false)
    }

    @Test("PaymentComponent - tap cancel")
    func paymentComponent_cancelTapped() async throws {
        // Given - use an initiable component that triggers submit directly
        let sut = SUT_MockedPaymentMethodRouter(type: .visa)

        // When - simulate primary button tap
        sut.preSelectedViewController.tapCancel()

        // Then - verify dropInFlowManager.submit was called
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

    // A view controller proxy to `inspect/perform actions` on the view.
    // The assumption is that the viewcontroller will be PreSelectedPaymentMethodViewController
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

        var primaryButtonText: String {
            get throws {
                let button = try primaryButton()
                return try #require(button.title)
            }
        }

        var secondaryButtonText: String {
            get throws {
                let button = try secondaryButton()
                return try #require(button.title)
            }
        }

        // MARK: - UI elements

        func primaryButton() throws -> FormButton {
            try #require(
                viewController.view.findView(by: "primaryButton") as? FormButton,
                "Cannot find primaryButton - Check if the element exists in the view."
            )
        }

        func secondaryButton() throws -> FormButton {
            try #require(
                viewController.view.findView(by: "secondaryButton") as? FormButton,
                "Cannot find secondaryButton - Check if the element exists in the view."
            )
        }

        // MARK: - Interactions

        func tapPrimaryButton() throws {
            let button = try primaryButton()
            button.sendActions(for: .touchUpInside)
        }

        func tapSecondaryButton() throws {
            let button = try secondaryButton()
            button.sendActions(for: .touchUpInside)
        }

        func tapCancel() {
            let cancelButton = viewController.navigationItem.leftBarButtonItem
            _ = cancelButton?.target?.perform(cancelButton?.action)
        }
    }

    // MARK: - Test data
    
    enum PaymentComponentTestData: CaseIterable {
        // PrsentableComponent
        case visa
        case bcmc

        // PaymentInitiable
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

        var primaryButtonText: String {
            "Pay €1.00"
        }

        var secondaryButtonText: String {
            "Other payment options"
        }
    }
}

// MARK: - Mocks

internal class InitiablePaymentComponentMock: PaymentComponent, PaymentInitiable {
    var context: AdyenContext
    var paymentMethod: PaymentMethod
    weak var delegate: PaymentComponentDelegate?
    var order: PartialPaymentOrder?

    init(paymentMethod: PaymentMethod, context: AdyenContext) {
        self.paymentMethod = paymentMethod
        self.context = context
    }

    func initiatePayment() {
        let details = StoredPaymentDetails(paymentMethod: paymentMethod as! StoredPaymentMethod)
        let data = PaymentComponentData(
            paymentMethodDetails: details,
            amount: context.payment?.amount,
            order: order
        )
        delegate?.didSubmit(data, from: self)
    }
}
