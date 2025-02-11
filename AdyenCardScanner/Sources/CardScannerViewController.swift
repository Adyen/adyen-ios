//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import Combine
import AVFoundation

class CardScannerViewController: UIViewController {

    // MARK: - UI elements

    private let overlayView: CardScannerOverlayView = {
        let view = CardScannerOverlayView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()

    // MARK: - Properties

    private let viewModel: CardScannerViewModelProtocol
    private let previewLayer: AVCaptureVideoPreviewLayer
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers

    init(viewModel: CardScannerViewModelProtocol) {
        self.viewModel = viewModel
        self.previewLayer = viewModel.videoPreviewLayer
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPreviewLayer()
        addOverlayView()
        observeRoiLayoutChanges()

        viewModel.configureSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopSession()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        viewModel.updateVideoOrientation()
    }

    // MARK: - Private

    private func setupPreviewLayer() {
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
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
}

