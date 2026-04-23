//
//  VisionCell.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 17/4/26.
//

import UIKit

class VisionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cardView: CardSubtileEffect!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var spiner: UIActivityIndicatorView!
    
    func update(display image: UIImage?) {
        switch image {
        case nil:
            self.spiner.startAnimating()
            self.imageView.image = nil
            
        case let imageToDisplay?:
            self.spiner.stopAnimating()
            self.imageView.image = imageToDisplay
        }
    }
}
