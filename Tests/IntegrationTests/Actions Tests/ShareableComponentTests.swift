//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
import UIKit
import XCTest

@MainActor
final class ShareableComponentTests: XCTestCase {

    // MARK: - Voucher

    func test_voucherSaveAsImage_withoutPhotoLibraryUsageDescription_shouldExcludeSaveToCameraRoll() throws {
        let sut = VoucherComponent(context: Dummy.context)
        let action = try AdyenCoder.decode(dokuIndomaretAction) as VoucherAction

        let shareSheet = try presentShareSheet(on: sut, hasPhotoLibraryAddUsageDescription: false) {
            sut.mainButtonTap(sourceView: UIView(), action: action)
        }

        XCTAssertEqual(shareSheet.excludedActivityTypes, [.saveToCameraRoll])
    }

    func test_voucherSaveAsImage_withPhotoLibraryUsageDescription_shouldKeepSaveToCameraRoll() throws {
        let sut = VoucherComponent(context: Dummy.context)
        let action = try AdyenCoder.decode(dokuIndomaretAction) as VoucherAction

        let shareSheet = try presentShareSheet(on: sut, hasPhotoLibraryAddUsageDescription: true) {
            sut.mainButtonTap(sourceView: UIView(), action: action)
        }

        XCTAssertNil(shareSheet.excludedActivityTypes)
    }

    func test_voucherDownloadShare_withPhotoLibraryUsageDescription_shouldKeepSaveToCameraRoll() throws {
        let sut = VoucherComponent(context: Dummy.context)
        let action = try AdyenCoder.decode(boletoAction) as VoucherAction
        let downloadable = try XCTUnwrap(action.anyAction as? Downloadable)

        let shareSheet = try presentShareSheet(on: sut, hasPhotoLibraryAddUsageDescription: true) {
            sut.mainButtonTap(sourceView: UIView(), downloadable: downloadable)
        }

        XCTAssertNil(shareSheet.excludedActivityTypes)
    }

    func test_voucherDownloadShare_withoutPhotoLibraryUsageDescription_shouldStillPresentShareSheet() throws {
        let sut = VoucherComponent(context: Dummy.context)
        let action = try AdyenCoder.decode(boletoAction) as VoucherAction
        let downloadable = try XCTUnwrap(action.anyAction as? Downloadable)

        let shareSheet = try presentShareSheet(on: sut, hasPhotoLibraryAddUsageDescription: false) {
            sut.mainButtonTap(sourceView: UIView(), downloadable: downloadable)
        }

        XCTAssertEqual(shareSheet.excludedActivityTypes, [.saveToCameraRoll])
    }

    // MARK: - QR code

    func test_qrCodeSaveAsImage_withoutPhotoLibraryUsageDescription_shouldExcludeSaveToCameraRoll() throws {
        let sut = QRCodeActionComponent(context: Dummy.context)

        let shareSheet = try presentShareSheet(on: sut, hasPhotoLibraryAddUsageDescription: false) {
            sut.presentSharePopover(with: UIImage(), sourceView: UIView())
        }

        XCTAssertEqual(shareSheet.excludedActivityTypes, [.saveToCameraRoll])
    }

    func test_qrCodeSaveAsImage_withPhotoLibraryUsageDescription_shouldKeepSaveToCameraRoll() throws {
        let sut = QRCodeActionComponent(context: Dummy.context)

        let shareSheet = try presentShareSheet(on: sut, hasPhotoLibraryAddUsageDescription: true) {
            sut.presentSharePopover(with: UIImage(), sourceView: UIView())
        }

        XCTAssertNil(shareSheet.excludedActivityTypes)
    }

    // MARK: - Helpers

    private func presentShareSheet(
        on sut: some ShareableComponent,
        hasPhotoLibraryAddUsageDescription: Bool,
        file: StaticString = #file,
        line: UInt = #line,
        share: () -> Void
    ) throws -> UIActivityViewController {
        setupRootViewController(sut.presenterViewController)

        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
            $0.hasPhotoLibraryAddUsageDescription = hasPhotoLibraryAddUsageDescription
        } perform: {
            share()
        }

        wait(
            until: { sut.presenterViewController.presentedViewController is UIActivityViewController },
            timeout: 5,
            retryInterval: .milliseconds(50),
            file: file,
            line: line
        )

        return try XCTUnwrap(
            sut.presenterViewController.presentedViewController as? UIActivityViewController,
            file: file,
            line: line
        )
    }
}
