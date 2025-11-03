//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit
@_spi(AdyenInternal) import Adyen

internal final class ComponentContainerViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ComponentContainerViewModelProtocol
    
    // MARK: - Initializers
    
    internal init(viewModel: ComponentContainerViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: Bundle(for: ComponentContainerViewController.self))
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View life cycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupComponentView()
        setupNavigationItem()
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        componentView.resignFirstResponder()
        viewModel.cancel()
    }
    
    // MARK: - Internal
    
    internal var componentView: UIViewController {
        viewModel.componentViewController
    }
    
    // MARK: - Private

    private func setupComponentView() {
        componentView.willMove(toParent: self)
        addChild(componentView)
        view.addSubview(componentView.view)
        componentView.didMove(toParent: self)
        setupLayout()
    }
        
    private func setupLayout() {
        componentView.view.adyen.anchor(inside: view)
    }
    
    private func setupNavigationItem() {
        navigationItem.title = componentView.title
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
