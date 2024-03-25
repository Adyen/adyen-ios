//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) @testable import AdyenActions
import PassKit
import UIKit
import XCTest

class VoucherViewTests: XCTestCase {
    
    let action: VoucherAction = .boletoBancairoSantander(
        .init(
            paymentMethodType: .boletoBancairoSantander,
            totalAmount: .init(value: 100, currencyCode: "EUR", localeIdentifier: nil),
            reference: "reference",
            expiresAt: Date(),
            downloadUrl: URL(string: "https://google.com")!, passCreationToken: nil
        )
    )

    func testCustomUI() throws {
        
        let style = getMockStyle()
        
        let sut = try getSut(model: getMockModel(action: action, mainButtonType: .save, style: style))
        
        check(layer: sut.findView(by: "logo")!.layer, forCornerRounding: style.logoCornerRounding)
        check(label: sut.findView(by: "amountLabel")!, forStyle: style.amountLabel)
        check(label: sut.findView(by: "currencyLabel")!, forStyle: style.currencyLabel)
        check(submitButton: sut.findView(by: "mainButton")! as! SubmitButton, forStyle: style.mainButton)
        check(button: sut.findView(by: "secondaryButton")!, forStyle: style.secondaryButton)
        
    }
    
    func testApplePayButton() throws {
        let appleWalletButtonExpectation = expectation(description: "Apple wallet button tapped")
        
        let delegateMock = VoucherViewDelegateMock()
        delegateMock.onAddToAppleWallet = { _ in
            appleWalletButtonExpectation.fulfill()
        }
        
        let sut = try getSut(
            model: getMockModel(
                action: action,
                mainButtonType: .addToAppleWallet,
                style: getMockStyle()
            )
        )
        sut.delegate = delegateMock
        
        let mainButton = sut.findView(by: "mainButton")
        let addToAppleWalletButton: PKAddPassButton? = sut.findView(by: "appleWalletButton")
        
        XCTAssertNil(mainButton)
        XCTAssertNotNil(addToAppleWalletButton)
        
        addToAppleWalletButton!.sendActions(for: .touchUpInside)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testMainSecondaryButtons() throws {
        let mainButtonExpectation = expectation(description: "Main button tapped")
        let secondaryButtonExpectation = expectation(description: "Secondary button tapped")
        
        let delegateMock = VoucherViewDelegateMock()
        delegateMock.onMainButtonTap = { _, _ in
            mainButtonExpectation.fulfill()
        }
        delegateMock.onSecondaryButtonTap = { _, _ in
            secondaryButtonExpectation.fulfill()
        }
        
        let mockModel = getMockModel(
            action: action,
            mainButtonType: .save,
            style: getMockStyle()
        )
        
        let sut = try getSut(model: mockModel)
        sut.delegate = delegateMock
        
        let mainButton: SubmitButton? = sut.findView(by: "mainButton")
        let secondaryButton: UIButton? = sut.findView(by: "secondaryButton")
        let addToAppleWalletButton: PKAddPassButton? = sut.findView(by: "appleWalletButton")
        
        XCTAssertNil(addToAppleWalletButton)
        
        XCTAssertEqual(mainButton?.title, mockModel.mainButton)
        XCTAssertEqual(secondaryButton?.title(for: .normal), mockModel.secondaryButtonTitle)
        
        mainButton?.sendActions(for: .touchUpInside)
        secondaryButton?.sendActions(for: .touchUpInside)
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testModel() throws {
        let imageLoader = ImageLoaderMock()
        let imageLoadingExpectation = expectation(description: "ImageLoader.load was called")
        
        let mockModel = getMockModel(
            action: action,
            mainButtonType: .save,
            style: getMockStyle(),
            imageLoader: imageLoader
        )
        
        imageLoader.imageProvider = { url in
            imageLoadingExpectation.fulfill()
            XCTAssertEqual(url, mockModel.logoUrl)
            return nil
        }
        
        let sut = try getSut(model: mockModel)
        
        let amountLabel: UILabel? = sut.findView(by: "amountLabel")
        let currencyLabel: UILabel? = sut.findView(by: "currencyLabel")
        let logo: UIImageView? = sut.findView(by: "logo")
        
        XCTAssertEqual(amountLabel?.text, mockModel.amount)
        XCTAssertEqual(currencyLabel?.text, mockModel.currency)
        
        wait(for: [imageLoadingExpectation], timeout: 0.1)
    }
    
    func testCopyCodeAnimation() throws {
        let mockModel = getMockModel(
            action: action,
            mainButtonType: .save,
            style: getMockStyle(),
            imageLoader: ImageLoaderMock()
        )
        
        let sut = try getSut(model: mockModel)
        
        sut.showCopyCodeConfirmation(resetAfter: .milliseconds(5))
        
        let secondaryButton: UIButton = try XCTUnwrap(sut.findView(by: "secondaryButton"))
        XCTAssertEqual(secondaryButton.title(for: .normal), mockModel.codeConfirmationTitle)
        XCTAssertEqual(secondaryButton.titleColor(for: .normal), mockModel.style.codeConfirmationColor)
        
        wait { secondaryButton.title(for: .normal) == mockModel.secondaryButtonTitle }
        XCTAssertEqual(secondaryButton.titleColor(for: .normal), mockModel.style.secondaryButton.title.color)
    }
    
    func getSut(model: VoucherView.Model) throws -> VoucherView {
        let sut = VoucherView(model: model)

        let viewController = UIViewController()
        viewController.view = sut
        sut.frame = UIScreen.main.bounds

        setupRootViewController(viewController)

        return sut
    }
    
    func getMockModel(
        action: VoucherAction,
        mainButtonType: VoucherView.Model.Button,
        style: VoucherView.Model.Style,
        imageLoader: ImageLoading = ImageLoaderMock()
    ) -> VoucherView.Model {
        VoucherView.Model(
            action: action,
            identifier: "identifier",
            amount: "100",
            currency: "EUR",
            logoUrl: URL(string: "https://adyen.com")!,
            mainButton: "Main Button",
            secondaryButtonTitle: "Secondary Button",
            codeConfirmationTitle: "Code Copied!",
            mainButtonType: mainButtonType,
            style: style,
            imageLoader: imageLoader
        )
    }
    
    func getMockStyle() -> VoucherView.Model.Style {
        let editButton = ButtonStyle(
            title: TextStyle(
                font: .preferredFont(forTextStyle: .callout),
                color: .blue,
                textAlignment: .justified
            ),
            cornerRadius: 4,
            background: .black
        )
        
        let doneButton = ButtonStyle(
            title: TextStyle(
                font: .preferredFont(forTextStyle: .caption1),
                color: .red,
                textAlignment: .right
            ),
            cornerRadius: 6,
            background: .red
        )
        
        let mainButton = ButtonStyle(
            title: TextStyle(
                font: .preferredFont(forTextStyle: .caption2),
                color: .cyan,
                textAlignment: .left
            ),
            cornerRadius: 8,
            background: .yellow
        )
        
        let secondaryButton = ButtonStyle(
            title: TextStyle(
                font: .preferredFont(forTextStyle: .title3),
                color: .brown,
                textAlignment: .justified
            ),
            cornerRadius: 10,
            background: .darkText
        )
        
        let amountLabel = TextStyle(
            font: .preferredFont(forTextStyle: .body),
            color: .brown,
            textAlignment: .center,
            cornerRounding: .fixed(20),
            backgroundColor: .red
        )
        
        let currencyLabel = TextStyle(
            font: .preferredFont(forTextStyle: .title3),
            color: .blue,
            textAlignment: .left,
            cornerRounding: .fixed(10),
            backgroundColor: .brown
        )
        
        return VoucherView.Model.Style(
            editButton: editButton,
            doneButton: doneButton,
            mainButton: mainButton,
            secondaryButton: secondaryButton,
            codeConfirmationColor: .red,
            amountLabel: amountLabel,
            currencyLabel: currencyLabel,
            logoCornerRounding: .fixed(12),
            backgroundColor: .magenta
        )
    }

}
