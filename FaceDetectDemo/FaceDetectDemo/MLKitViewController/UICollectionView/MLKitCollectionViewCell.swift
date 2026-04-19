//
//  MLKitCollectionViewCell.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 19/4/26.
//

import UIKit

class MLKitCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imageView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.layer.cornerRadius = self.imageView.bounds.height / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
    
    func fill(with image: UIImage) {
        self.imageView.image = image
    }
}
