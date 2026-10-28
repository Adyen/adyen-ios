//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

@available(iOS 13.0, *)
internal class CardScannerOverlayView: UIView {

    private enum Style {
        static let backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }

    private enum Constants {
        static let roiAspectRatio: CGFloat = 1.585 // Credit card aspect ratio
    }

    // MARK: - UI elements

    private let topMask = UIView()
    private let bottomMask = UIView()
    private let leftMask = UIView()

    private let rightMask = UIView()
    private let roiView: ROIView = {
        let view = ROIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Style.backgroundColor
        return view
    }()

    // MARK: - Properties

    @Published internal private(set) var roiFrame: CGRect = .zero

    private lazy var roiWidthConstraint = roiView.widthAnchor.constraint(equalToConstant: 0)

    // MARK: - Initializers

    override internal init(frame: CGRect) {
        super.init(frame: frame)
        setupMaskViews()
        setupConstraints()
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override internal func layoutSubviews() {
        updateRoiLayout()
        super.layoutSubviews()
        self.roiFrame = roiView.frame
    }

    // MARK: - Private

    private func setupMaskViews() {
        let maskViews = [topMask, bottomMask, leftMask, rightMask]
        maskViews.forEach {
            $0.backgroundColor = Style.backgroundColor
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        addSubview(roiView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            topMask.topAnchor.constraint(equalTo: topAnchor),
            topMask.leadingAnchor.constraint(equalTo: leadingAnchor),
            topMask.trailingAnchor.constraint(equalTo: trailingAnchor),
            topMask.bottomAnchor.constraint(equalTo: roiView.topAnchor),

            bottomMask.topAnchor.constraint(equalTo: roiView.bottomAnchor),
            bottomMask.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomMask.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomMask.bottomAnchor.constraint(equalTo: bottomAnchor),

            leftMask.topAnchor.constraint(equalTo: topMask.bottomAnchor),
            leftMask.leadingAnchor.constraint(equalTo: leadingAnchor),
            leftMask.trailingAnchor.constraint(equalTo: roiView.leadingAnchor),
            leftMask.bottomAnchor.constraint(equalTo: bottomMask.topAnchor),

            rightMask.topAnchor.constraint(equalTo: topMask.bottomAnchor),
            rightMask.leadingAnchor.constraint(equalTo: roiView.trailingAnchor),
            rightMask.trailingAnchor.constraint(equalTo: trailingAnchor),
            rightMask.bottomAnchor.constraint(equalTo: bottomMask.topAnchor),

            roiView.centerXAnchor.constraint(equalTo: centerXAnchor),
            roiView.centerYAnchor.constraint(equalTo: centerYAnchor),
            roiView.heightAnchor.constraint(equalTo: roiView.widthAnchor, multiplier: 1.0 / Constants.roiAspectRatio),
            roiWidthConstraint
        ])
    }

    private func updateRoiLayout() {
        let padding: CGFloat = 12
        roiWidthConstraint.constant = max(0, min(bounds.width, bounds.height) - (padding * 2))
    }
}
