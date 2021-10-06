//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal final class FormCardLogoItemView: FormItemView<FormCardLogoItem> {
    
    private enum Constants {
        static let cardSpacing: CGFloat = 3
        static let rowSpacing: CGFloat = 2
        static let cardSize = CGSize(width: 24, height: 16)
    }
    
    private lazy var collectionView: CardsCollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = Constants.cardSize
        flowLayout.minimumLineSpacing = Constants.rowSpacing
        flowLayout.minimumInteritemSpacing = Constants.cardSpacing
        flowLayout.scrollDirection = .vertical
        let collectionView = CardsCollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    internal required init(item: FormCardLogoItem) {
        super.init(item: item)
        addSubview(collectionView)
        collectionView.adyen.anchor(inside: layoutMarginsGuide)
        collectionView.register(CardTypeLogoCell.self, forCellWithReuseIdentifier: CardTypeLogoCell.reuseIdentifier)
        collectionView.dataSource = self
    }
    
}

extension FormCardLogoItemView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        item.cardLogos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardTypeLogoCell.reuseIdentifier, for: indexPath)
        if let cell = cell as? CardTypeLogoCell {
            let logo = item.cardLogos[indexPath.row]
            cell.update(imageUrl: logo.url, style: item.style.icon)
        }
        return cell
    }
}

extension FormCardLogoItemView {
    
    /// A collectionview that updates its intrinsicContentSize to make all rows visible.
    internal class CardsCollectionView: UICollectionView {
        private var shouldInvaliateLayout = false
        
        override internal func layoutSubviews() {
            super.layoutSubviews()
            if shouldInvaliateLayout {
                collectionViewLayout.invalidateLayout()
                shouldInvaliateLayout = false
            }
        }
        
        override internal func reloadData() {
            shouldInvaliateLayout = true
            invalidateIntrinsicContentSize()
            super.reloadData()
        }
        
        override internal var intrinsicContentSize: CGSize {
            CGSize(width: contentSize.width, height: max(Constants.cardSize.height, contentSize.height))
        }
    }
}

extension FormCardLogoItemView {
    
    private class CardTypeLogoCell: UICollectionViewCell {
        
        fileprivate static let reuseIdentifier = "CardTypeLogoCell"
        
        private lazy var cardTypeImageView: NetworkImageView = {
            NetworkImageView()
        }()
        
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

internal extension Array {
    
    /// Safely returns the element at the given index, if the index is within the bounds of the array.
    subscript(safeIndex index: Int) -> Element? {
        guard index >= startIndex,
              index < endIndex else { return nil }
        return self[index]
    }
}
