//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenCard
@testable import AdyenDropIn
import XCTest

class PreselectedPaymentComponentDelegateMock: PreselectedPaymentMethodComponentDelegate {
    
    var didRequestAllPaymentMethodsCalled: Bool = false
    var didProceedCalled: Bool = false
    var componentToProceed: PaymentComponent?
    
    func didRequestAllPaymentMethods() {
        didRequestAllPaymentMethodsCalled = true
    }
    
    func didProceed(with component: PaymentComponent) {
        didProceedCalled = true
        componentToProceed = component
    }
}

class PreselectedPaymentComponentTests: XCTestCase {
    
    let payment = Payment(amount: Payment.Amount(value: 4200, currencyCode: "EUR"), countryCode: "DE")
    var sut: PreselectedPaymentMethodComponent!
    var component: StoredPaymentMethodComponent!
    var delegate: PreselectedPaymentComponentDelegateMock!
    
    override func setUp() {
        component = StoredPaymentMethodComponent(paymentMethod: getStoredCard())
        component.payment = payment
        sut = PreselectedPaymentMethodComponent(component: component, title: "Test title", style: FormComponentStyle(), listItemStyle: ListItemStyle())
        
        delegate = PreselectedPaymentComponentDelegateMock()
        sut.delegate = delegate
    }
    
    override func tearDown() {
        sut = nil
        delegate = nil
    }
    
    func testTitle() {
        XCTAssertEqual(sut.viewController.title, "Test title")
    }
    
    func testUIElements() {
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.defaultComponent"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.openAllButton"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.separator"))
        XCTAssertNotNil(sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.submitButton"))
    }
    
    func testPressSubmitButton() {
        let button: SubmitButton! = sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.submitButton.button")
        button.sendActions(for: .touchUpInside)
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertTrue(self.delegate.didProceedCalled)
            XCTAssertFalse(self.delegate.didRequestAllPaymentMethodsCalled)
            XCTAssertTrue(self.delegate.componentToProceed === self.component)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testPressOpenAllButton() {
        let button: SubmitButton! = sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.openAllButton.button")
        button!.sendActions(for: .touchUpInside)
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertFalse(self.delegate.didProceedCalled)
            XCTAssertTrue(self.delegate.didRequestAllPaymentMethodsCalled)
            XCTAssertNil(self.delegate.componentToProceed)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testUICustomisation() {
        var formStyle = sut.style
        formStyle.backgroundColor = .green
        formStyle.separatorColor = .red
        formStyle.mainButton = ButtonStyle(title: TextStyle(font: .systemFont(ofSize: 20), color: .cyan, textAlignment: .center), cornerRadius: 0, background: .brown)
        formStyle.secondaryButton = ButtonStyle(title: TextStyle(font: .systemFont(ofSize: 22), color: .brown, textAlignment: .center), cornerRadius: 0, background: .cyan)
        
        var listStyle = sut.listItemStyle
        listStyle.backgroundColor = .blue
        listStyle.image.backgroundColor = .red
        listStyle.title.color = .white
        listStyle.subtitle.color = .white
        
        component = StoredPaymentMethodComponent(paymentMethod: getStoredCard())
        sut = PreselectedPaymentMethodComponent(component: component, title: "", style: formStyle, listItemStyle: listStyle)
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let listView = sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.defaultComponent")
        let listViewTitle: UILabel! = listView!.findView(by: "titleLabel")
        let listViewSubtitle: UILabel! = listView!.findView(by: "subtitleLabel")
        
        let submitButtonContainer = sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.submitButton")
        let submitButton = submitButtonContainer!.findView(by: "button")
        let submitButtonLabel: UILabel! = submitButton!.findView(by: "titleLabel")
        
        let openAllButtonContainer = sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.openAllButton")
        let openAllButton = openAllButtonContainer!.findView(by: "button")
        let openAllButtonLabel: UILabel! = openAllButton!.findView(by: "titleLabel")
        
        let separator = sut.viewController.view.findView(by: "separatorLine")
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertEqual(listView!.backgroundColor, .blue)
            XCTAssertEqual(listViewTitle.textColor, .white)
            XCTAssertEqual(listViewSubtitle.textColor, .white)
            
            XCTAssertEqual(submitButton!.backgroundColor, .brown)
            XCTAssertEqual(submitButtonLabel.textColor, .cyan)
            
            XCTAssertEqual(openAllButton!.backgroundColor, .cyan)
            XCTAssertEqual(openAllButtonLabel.textColor, .brown)
            
            XCTAssertEqual(separator!.backgroundColor, .red)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testPayButtonTitle() {
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let submitButtonContainer = sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.submitButton")
        let submitButton = submitButtonContainer!.findView(by: "button")
        let submitButtonLabel: UILabel! = submitButton!.findView(by: "titleLabel")
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertEqual(submitButtonLabel.text, "Pay")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testPaypalComponent() {
        component = StoredPaymentMethodComponent(paymentMethod: getStoredPaypal())
        sut = PreselectedPaymentMethodComponent(component: component, title: "", style: FormComponentStyle(), listItemStyle: ListItemStyle())
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let listView: ListItemView? = sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.defaultComponent")
        let listViewTitle: UILabel! = listView!.findView(by: "titleLabel")
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertEqual(listViewTitle.text, "PayPal")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testStoredCardComponent() {
        component = StoredPaymentMethodComponent(paymentMethod: getStoredCard())
        sut = PreselectedPaymentMethodComponent(component: component, title: "", style: FormComponentStyle(), listItemStyle: ListItemStyle())
        
        UIApplication.shared.keyWindow?.rootViewController = sut.viewController
        
        let listView = sut.viewController.view.findView(with: "AdyenDropIn.PreselectedPaymentMethodComponent.defaultComponent")
        let listViewTitle: UILabel! = listView!.findView(by: "titleLabel")
        let listViewSubtitle: UILabel! = listView!.findView(by: "subtitleLabel")
        
        let expectation = XCTestExpectation(description: "Dummy Expectation")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            XCTAssertEqual(listViewTitle.text, "•••• 1111")
            XCTAssertEqual(listViewSubtitle.text, "Expires 08/18")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func getStoredCard() -> StoredCardPaymentMethod {
        return try! Coder.decode(storedCardDictionary) as StoredCardPaymentMethod
    }
    
    func getStoredPaypal() -> StoredPayPalPaymentMethod {
        return try! Coder.decode(storedPayPalDictionary) as StoredPayPalPaymentMethod
    }
    
}
