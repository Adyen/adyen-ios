//
//  CameraViewController.swift
//  AdyenCardScanner
//
//  Created by Mohamed Eldoheiri on 16/11/2022.
//  Copyright © 2022 Adyen. All rights reserved.
//

import UIKit
@_spi(AdyenInternal) import Adyen
import AVFoundation

@available(iOS 13, *)
public class CameraViewController: UIViewController, CameraViewDelegate {
    
    var onDetect: ((DetectedCard?) -> Void)
    
    private lazy var scanner: ImageScanner = {
        AppleImageScanner(onDetect: { [weak self] card in
            DispatchQueue.main.async {
                self?.onDetect(card)
            }
            
        })
    }()
    
    public init(onDetect: @escaping (DetectedCard?) -> Void) {
        self.onDetect = onDetect
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraView.setupCamera()
    }
    
    private var cameraView: CameraView { view as! CameraView }
    
    public override func loadView() {
        let cameraView = CameraView(delegate: self, creditCardFrameStrokeColor: .clear, maskLayerColor: .black, maskLayerAlpha: 0.8)
        cameraView.delegate = self
        view = cameraView
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraView.setupRegionOfInterest()
    }

    internal func didCapture(image: CGImage) {
        scanner.scan(image: image)
    }
    
    internal func didError(with: CreditCardScannerError) {
        print(with)
    }

}
