//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AVFoundation
import Combine
import UIKit

internal protocol CardScannerPresenting: AnyObject {
    func dismiss()
    func presentCameraAccessDeniedAlert()
}

@available(iOS 13.0, *)
internal class CardScannerViewController: UIViewController, CardScannerPresenting {

    // MARK: - UI elements

    private let overlayView: CardScannerOverlayView = {
        let view = CardScannerOverlayView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()

    // MARK: - Properties

    private let viewModel: CardScannerViewModelProtocol
    private let previewLayer: CALayer
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers

    internal init(viewModel: CardScannerViewModelProtocol) {
        self.viewModel = viewModel
        self.previewLayer = viewModel.videoPreviewLayer
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    override internal func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        viewModel.requestCaptureAuthorization()

        setupPreviewLayer()
        addOverlayView()
        observeRoiLayoutChanges()
    }

    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startCaptureSession()
    }

    override internal func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopCaptureSession()
    }

    override internal func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        viewModel.updateVideoOrientation()
    }

    // MARK: - Private

    private func setupView() {
        view.backgroundColor = .black
    }

    private func setupPreviewLayer() {
        view.layer.insertSublayer(previewLayer, at: 0)
    }

    private func addOverlayView() {
        view.addSubview(overlayView)

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func observeRoiLayoutChanges() {
        overlayView.$roiFrame.sink { newRoiFrame in
            self.viewModel.update(
                previewLayerFrame: self.previewLayer.frame,
                roiInPreviewLayer: newRoiFrame
            )
        }.store(in: &cancellables)
    }

    // MARK: - CardScannerViewProtocol

    internal func dismiss() {
        dismiss(animated: true)
    }

    internal func presentCameraAccessDeniedAlert() {
        let alertTitle = viewModel.cameraAlertTitle
        let alertMessage = viewModel.cameraAlertMessage
        let alert = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: .alert
        )

        let settingsActionTitle = viewModel.cameraAlertSettingButtonTitle
        let settingsAction = UIAlertAction(
            title: settingsActionTitle,
            style: .default
        ) { [weak self] _ in
            self?.viewModel.openSettingsApp()
        }
        alert.addAction(settingsAction)

        let cancelActionTitle = viewModel.cameraAlertCancelButtonTitle
        let cancelAction = UIAlertAction(
            title: cancelActionTitle,
            style: .cancel
        ) { [weak self] _ in
            self?.dismiss()
        }
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}
