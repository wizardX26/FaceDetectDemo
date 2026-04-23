//
//  MLKitCollectionViewCell.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 19/4/26.
//

import UIKit

class MLKitCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageView.clipsToBounds = true
        self.imageView.contentMode = .scaleAspectFit
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = self.bounds
        self.contentView.layoutIfNeeded()
        self.outerView.layer.masksToBounds = true
        self.outerView.layer.cornerRadius = min(self.outerView.bounds.width, self.outerView.bounds.height) / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
    
    func fill(with image: UIImage) {
        self.imageView.image = image
    }
}
