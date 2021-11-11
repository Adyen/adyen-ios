//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal final class FormCardLogosItemView: FormItemView<FormCardLogosItem> {
    
    private enum Constants {
        static let cardSpacing: CGFloat = 3
        static let rowSpacing: CGFloat = 2
        static let cardSize = CGSize(width: 24, height: 16)
    }
    
    private lazy var collectionView: CardLogoCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = Constants.cardSize
        flowLayout.minimumLineSpacing = Constants.rowSpacing
        flowLayout.minimumInteritemSpacing = Constants.cardSpacing
        flowLayout.scrollDirection = .vertical
        let collectionView = CardLogoCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    internal required init(item: FormCardLogosItem) {
        super.init(item: item)
        addSubview(collectionView)
        collectionView.adyen.anchor(inside: self, with: UIEdgeInsets(top: 4, left: 16, bottom: -8, right: -16))
        collectionView.register(CardLogoCell.self, forCellWithReuseIdentifier: CardLogoCell.reuseIdentifier)
        collectionView.dataSource = self
        
        observe(item.$alpha) { [weak self] alpha in
            self?.collectionView.alpha = alpha
        }
    }
    
}

extension FormCardLogosItemView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        item.cardLogos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardLogoCell.reuseIdentifier, for: indexPath)
        if let cell = cell as? CardLogoCell,
           let logo = item.cardLogos.adyen[safeIndex: indexPath.row] {
            cell.update(imageUrl: logo.url, style: item.style.icon)
        }
        return cell
    }
}

extension FormCardLogosItemView {
    
    /// A `UICollectionView` that updates its `intrinsicContentSize` to make all rows visible.
    internal class CardLogoCollectionView: UICollectionView {
        private var shouldInvalidateLayout = false
        
        override internal func layoutSubviews() {
            super.layoutSubviews()
            if shouldInvalidateLayout {
                collectionViewLayout.invalidateLayout()
                shouldInvalidateLayout = false
            }
        }
        
        override internal func reloadData() {
            shouldInvalidateLayout = true
            invalidateIntrinsicContentSize()
            super.reloadData()
        }
        
        override internal var intrinsicContentSize: CGSize {
            CGSize(width: contentSize.width, height: max(Constants.cardSize.height, contentSize.height))
        }
    }
}

extension FormCardLogosItemView {
    
    private class CardLogoCell: UICollectionViewCell {
        
        fileprivate static let reuseIdentifier = "CardLogoCell"
        
        private lazy var cardTypeImageView = NetworkImageView()
        
        override private init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(cardTypeImageView)
            cardTypeImageView.adyen.anchor(inside: contentView)
        }
        
        @available(*, unavailable)
        fileprivate required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        internal func update(imageUrl: URL, style: ImageStyle) {
            cardTypeImageView.imageURL = imageUrl
            
            cardTypeImageView.layer.masksToBounds = style.clipsToBounds
            cardTypeImageView.layer.borderWidth = style.borderWidth
            cardTypeImageView.layer.borderColor = style.borderColor?.cgColor
            cardTypeImageView.backgroundColor = style.backgroundColor
            cardTypeImageView.adyen.round(using: style.cornerRounding)
        }
        
    }
}
