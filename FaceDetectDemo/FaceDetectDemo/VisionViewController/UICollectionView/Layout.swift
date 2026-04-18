//
//  Layout.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 17/4/26.
//

import UIKit

final class Layout: UICollectionViewFlowLayout {
    
    private let numberOfColumns: CGFloat = 3
    private let topInset: CGFloat = 10
    private let bottomInset: CGFloat = 10
    
    private let spacing: CGFloat = 4
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        // MARK: - Spacing config
        minimumInteritemSpacing = self.spacing
        minimumLineSpacing = self.spacing
        sectionInset = UIEdgeInsets(top: self.topInset,
                                    left: self.spacing,
                                    bottom: self.bottomInset,
                                    right: self.spacing)
        
        // MARK: - Tính toán width chuẩn
        let totalSpacing = self.spacing * (self.numberOfColumns + 1)
        let availableWidth = collectionView.bounds.width - totalSpacing
        
        let itemWidth = floor(availableWidth / self.numberOfColumns)
        
        // MARK: - Size item
        itemSize = CGSize(width: itemWidth, height: itemWidth * 1.2)
    }
}
