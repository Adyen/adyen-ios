//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

class BasicPersonalInfoFormComponentTests: XCTestCase {

    lazy var paymentMethod = SevenElevenPaymentMethod(type: .econtextSevenEleven, name: "test_name")
    let payment = Payment(amount: Amount(value: 2, currencyCode: "IDR"), countryCode: "ID")

    func testLocalizationWithCustomTableName() throws {
        let localization = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        let config = BasicPersonalInfoFormComponent.Configuration(localizationParameters: localization)
        let sut = SevenElevenComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: config
        )

        XCTAssertEqual(sut.firstNameItem?.title, localizedString(.firstName, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.firstNameItem?.placeholder, localizedString(.firstName, sut.configuration.localizationParameters))
        XCTAssertNil(sut.firstNameItem?.validationFailureMessage)

        XCTAssertEqual(sut.lastNameItem?.title, localizedString(.lastName, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.lastNameItem?.placeholder, localizedString(.lastName, sut.configuration.localizationParameters))
        XCTAssertNil(sut.lastNameItem?.validationFailureMessage)

        XCTAssertEqual(sut.emailItem?.title, localizedString(.emailItemTitle, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.emailItem?.placeholder, localizedString(.emailItemPlaceHolder, sut.configuration.localizationParameters))
        XCTAssertEqual(sut.emailItem?.validationFailureMessage, localizedString(.emailItemInvalid, sut.configuration.localizationParameters))

        XCTAssertNotNil(sut.button.title)
        XCTAssertEqual(sut.button.title, localizedString(.confirmPurchase, sut.configuration.localizationParameters))
    }

    func testLocalizationWithCustomKeySeparator() {
        let config = BasicPersonalInfoFormComponent.Configuration(localizationParameters: LocalizationParameters(tableName: "AdyenUIHostCustomSeparator", keySeparator: "_"))
        let sut = SevenElevenComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: config
        )

        XCTAssertEqual(sut.firstNameItem?.title, localizedString(LocalizationKey(key: "adyen_firstName"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.firstNameItem?.placeholder, localizedString(LocalizationKey(key: "adyen_firstName"), sut.configuration.localizationParameters))
        XCTAssertNil(sut.firstNameItem?.validationFailureMessage)

        XCTAssertEqual(sut.lastNameItem?.title, localizedString(LocalizationKey(key: "adyen_lastName"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.lastNameItem?.placeholder, localizedString(LocalizationKey(key: "adyen_lastName"), sut.configuration.localizationParameters))
        XCTAssertNil(sut.lastNameItem?.validationFailureMessage)

        XCTAssertEqual(sut.emailItem?.title, localizedString(LocalizationKey(key: "adyen_emailItem_title"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.emailItem?.placeholder, localizedString(LocalizationKey(key: "adyen_emailItem_placeHolder"), sut.configuration.localizationParameters))
        XCTAssertEqual(sut.emailItem?.validationFailureMessage, localizedString(LocalizationKey(key: "adyen_emailItem_invalid"), sut.configuration.localizationParameters))

        XCTAssertNotNil(sut.button.title)
        XCTAssertEqual(sut.button.title, localizedString(LocalizationKey(key: "adyen_confirmPurchase"), sut.configuration.localizationParameters))
    }

    func testUIConfiguration() throws {
        // Given
        let customColors = AdyenColors(container: .systemYellow, primary: .systemPink, highlight: .systemBlue)
        let customTheme = AdyenTheme(colors: customColors).primaryButton(backgroundColor: .systemRed, textColor: .white)

        var config = BasicPersonalInfoFormComponent.Configuration()
        config.theme = customTheme
        let sut = SevenElevenComponent(paymentMethod: paymentMethod, context: Dummy.context, configuration: config)

        // When
        setupRootViewController(sut.viewController)
        wait(for: .milliseconds(300))

        // Then
        let view = sut.viewController.view
        let firstNameView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(view?.findView(with: ViewIdentifier.firstName))
        let firstNameTitleLabel: UILabel = try XCTUnwrap(view?.findView(with: ViewIdentifier.firstNameTitleLabel))
        let firstNameTextField: UITextField = try XCTUnwrap(view?.findView(with: ViewIdentifier.firstNameTextField))
        let lastNameView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(view?.findView(with: ViewIdentifier.lastName))
        let lastNameTitleLabel: UILabel = try XCTUnwrap(view?.findView(with: ViewIdentifier.lastNameTitleLabel))
        let lastNameTextField: UITextField = try XCTUnwrap(view?.findView(with: ViewIdentifier.lastNameTextField))
        let emailView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(view?.findView(with: ViewIdentifier.email))
        let emailTitleLabel: UILabel = try XCTUnwrap(view?.findView(with: ViewIdentifier.emailTitleLabel))
        let emailTextField: UITextField = try XCTUnwrap(view?.findView(with: ViewIdentifier.emailTextField))
        let phoneNumberView: FormPhoneNumberItemView = try XCTUnwrap(view?.findView(with: ViewIdentifier.phone))
        let phoneNumberViewTitleLabel: UILabel = try XCTUnwrap(view?.findView(with: ViewIdentifier.phoneTitleLabel))
        let phoneNumberViewTextField: UITextField = try XCTUnwrap(view?.findView(with: ViewIdentifier.phoneTextField))
        let payButtonItemView: FormButtonItemView = try XCTUnwrap(view?.findView(with: ViewIdentifier.payButton))

        XCTAssertEqual(firstNameTitleLabel.textColor, .systemPink)
        XCTAssertEqual(firstNameTextField.textColor, .systemPink)
        XCTAssertEqual(lastNameTitleLabel.textColor, .systemPink)
        XCTAssertEqual(lastNameTextField.textColor, .systemPink)
        XCTAssertEqual(emailTitleLabel.textColor, .systemPink)
        XCTAssertEqual(emailTextField.textColor, .systemPink)
        XCTAssertEqual(phoneNumberViewTitleLabel.textColor, .systemPink)
        XCTAssertEqual(phoneNumberViewTextField.textColor, .systemPink)
        XCTAssertEqual(firstNameView.backgroundColor, .systemYellow)
        XCTAssertEqual(lastNameView.backgroundColor, .systemYellow)
        XCTAssertEqual(emailView.backgroundColor, .systemYellow)
        XCTAssertEqual(phoneNumberView.backgroundColor, .systemYellow)
        XCTAssertEqual(payButtonItemView.button.backgroundColor, .systemRed)
    }

    private func assertTextInputUI(
        _ identifier: String,
        view: UIView,
        style: FormTextItemStyle,
        isFirstField: Bool
    ) {

        let textView: FormTextInputItemView? = view.findView(with: identifier)
        let textViewTitleLabel: UILabel? = view.findView(with: "\(identifier).titleLabel")
        let textViewTextField: UITextField? = view.findView(with: "\(identifier).textField")

        // TODO: Fix textView, textViewTitleLabel, textViewTextField UI asserts
//        XCTAssertEqual(textView?.backgroundColor, .red)
//        XCTAssertEqual(textViewTitleLabel?.textColor, isFirstField ? view.tintColor : style.title.color)
//        XCTAssertEqual(textViewTitleLabel?.backgroundColor, style.title.backgroundColor)
//        XCTAssertEqual(textViewTitleLabel?.textAlignment, style.title.textAlignment)
//        XCTAssertEqual(textViewTitleLabel?.font, style.title.font)
//        XCTAssertEqual(textViewTextField?.backgroundColor, style.backgroundColor)
//        XCTAssertEqual(textViewTextField?.textAlignment, style.text.textAlignment)
//        XCTAssertEqual(textViewTextField?.textColor, style.text.color)
//        XCTAssertEqual(textViewTextField?.font, style.text.font)
    }

    func testSubmitForm() throws {
        let sut = SevenElevenComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: BasicPersonalInfoFormComponent.Configuration()
        )
        let delegate = PaymentComponentDelegateMock()
        sut.delegate = delegate

        let delegateExpectation = expectation(description: "PaymentComponentDelegate must be called when submit button is clicked.")
        delegate.onDidSubmit = { data, component in
            XCTAssertTrue(component === sut)
            XCTAssertTrue(data.paymentMethod is BasicPersonalInfoFormDetails)
            let data = data.paymentMethod as! BasicPersonalInfoFormDetails
            XCTAssertEqual(data.firstName, "Mohamed")
            XCTAssertEqual(data.lastName, "Smith")
            XCTAssertEqual(data.emailAddress, "mohamed.smith@domain.com")
            XCTAssertEqual(data.telephoneNumber, "+11233456789")

            sut.stopLoading()
            delegateExpectation.fulfill()
            XCTAssertEqual(sut.viewController.view.isUserInteractionEnabled, true)
            XCTAssertEqual(sut.button.showsActivityIndicator, false)
        }

        setupRootViewController(sut.viewController)
        
        wait(for: .milliseconds(300))
        
        let submitButton: UIControl? = sut.viewController.view.findView(with: ViewIdentifier.payButton)

        let firstNameView: FormTextInputItemView! = sut.viewController.view.findView(with: ViewIdentifier.firstName)
        self.populate(textItemView: firstNameView, with: "Mohamed")

        let lastNameView: FormTextInputItemView! = sut.viewController.view.findView(with: ViewIdentifier.lastName)
        self.populate(textItemView: lastNameView, with: "Smith")

        let emailView: FormTextInputItemView! = sut.viewController.view.findView(with: ViewIdentifier.email)
        self.populate(textItemView: emailView, with: "mohamed.smith@domain.com")

        let phoneNumberView: FormPhoneNumberItemView! = sut.viewController.view.findView(with: ViewIdentifier.phone)
        self.populate(textItemView: phoneNumberView, with: "1233456789")

        submitButton?.sendActions(for: .touchUpInside)
        
        waitForExpectations(timeout: 10)
    }

    func testBigTitle() {
        let sut = SevenElevenComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: BasicPersonalInfoFormComponent.Configuration()
        )

        setupRootViewController(sut.viewController)

        wait(for: .milliseconds(300))
        
        XCTAssertNil(sut.viewController.view.findView(with: "AdyenComponents.BasicPersonalInfoFormComponent.Test name"))
        XCTAssertEqual(sut.viewController.title, self.paymentMethod.name)
    }

    func testRequiresModalPresentation() {
        let paymentMethod = SevenElevenPaymentMethod(type: .econtextSevenEleven, name: "Test name")
        let sut = SevenElevenComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: BasicPersonalInfoFormComponent.Configuration()
        )
        XCTAssertEqual(sut.requiresModalPresentation, true)
    }

    func testBasicPersonalInfoFormPrefilling() throws {
        // Given
        let config = BasicPersonalInfoFormComponent.Configuration(shopperInformation: shopperInformation)
        let prefillSut = SevenElevenComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: config
        )
        
        setupRootViewController(prefillSut.viewController)

        // Then
        let view: UIView = prefillSut.viewController.view

        let firstNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: ViewIdentifier.firstName))
        let expectedFirstName = try XCTUnwrap(shopperInformation.shopperName?.firstName)
        let firstName = firstNameView.item.value
        XCTAssertEqual(expectedFirstName, firstName)

        let lastNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: ViewIdentifier.lastName))
        let expectedLastName = try XCTUnwrap(shopperInformation.shopperName?.lastName)
        let lastName = lastNameView.item.value
        XCTAssertEqual(expectedLastName, lastName)

        let phoneNumberView: FormPhoneNumberItemView = try XCTUnwrap(view.findView(by: ViewIdentifier.phone))
        let expectedPhoneNumber = try XCTUnwrap(shopperInformation.phoneNumber?.value)
        let phoneNumber = phoneNumberView.item.value
        XCTAssertEqual(expectedPhoneNumber, phoneNumber)

        let emailView: FormTextInputItemView = try XCTUnwrap(view.findView(by: ViewIdentifier.email))
        let expectedEmail = try XCTUnwrap(shopperInformation.emailAddress)
        let email = emailView.item.value
        XCTAssertEqual(expectedEmail, email)
    }

    func testBasicPersonalInfoForm_givenNoShopperInformation_shouldNotPrefill() throws {
        // Given
        let sut = SevenElevenComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context,
            configuration: BasicPersonalInfoFormComponent.Configuration()
        )
        setupRootViewController(sut.viewController)

        wait(for: .milliseconds(300))

        // Then
        let view: UIView = sut.viewController.view

        let firstNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: ViewIdentifier.firstName))
        let firstName = firstNameView.item.value
        XCTAssertTrue(firstName.isEmpty)

        let lastNameView: FormTextInputItemView = try XCTUnwrap(view.findView(by: ViewIdentifier.lastName))
        let lastName = lastNameView.item.value
        XCTAssertTrue(lastName.isEmpty)

        let phoneNumberView: FormPhoneNumberItemView = try XCTUnwrap(view.findView(by: ViewIdentifier.phone))
        let phoneNumber = phoneNumberView.item.value
        XCTAssertTrue(phoneNumber.isEmpty)

        let emailView: FormTextInputItemView = try XCTUnwrap(view.findView(by: ViewIdentifier.email))
        let email = emailView.item.value
        XCTAssertTrue(email.isEmpty)
    }

    // MARK: - Private

    private enum ViewIdentifier {
        static let firstName = "AdyenComponents.BasicPersonalInfoFormComponent.firstNameItem"
        static let lastName = "AdyenComponents.BasicPersonalInfoFormComponent.lastNameItem"
        static let phone = "AdyenComponents.BasicPersonalInfoFormComponent.phoneNumberItem"
        static let phoneTitleLabel = "AdyenComponents.BasicPersonalInfoFormComponent.phoneNumberItem.titleLabel"
        static let phoneTextField = "AdyenComponents.BasicPersonalInfoFormComponent.phoneNumberItem.textField"
        static let email = "AdyenComponents.BasicPersonalInfoFormComponent.emailItem"
        static let payButton = "AdyenComponents.BasicPersonalInfoFormComponent.payButtonItem.button"
        static let payButtonTitleLabel = "AdyenComponents.BasicPersonalInfoFormComponent.payButtonItem.button.titleLabel"
    }

    private var shopperInformation: PrefilledShopperInformation {
        let billingAddress = PostalAddressMocks.newYorkPostalAddress
        let deliveryAddress = PostalAddressMocks.losAngelesPostalAddress
        return .init(
            shopperName: ShopperName(firstName: "Katrina", lastName: "Del Mar"),
            emailAddress: "katrina@mail.com",
            phoneNumber: .init(value: "1234567890", callingCode: "+1"),
            billingAddress: billingAddress,
            deliveryAddress: deliveryAddress,
            socialSecurityNumber: "78542134370"
        )
    }
}
