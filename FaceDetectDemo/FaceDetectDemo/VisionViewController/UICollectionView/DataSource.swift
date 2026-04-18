//
//  UICollectionViewDataSource.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 17/4/26.
//

import UIKit

class DataSource: NSObject, UICollectionViewDataSource {
    var items: [VisionFace]?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = "VisionCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! VisionCollectionViewCell
        //let item = self.items?[indexPath.item]
        cell.update(display: nil)
        //cell.update(display: self.mockImage(for: item, index: indexPath.item))
        
        return cell
    }
    
    
}

private extension DataSource {
    func mockImage(for item: VisionFace?, index: Int) -> UIImage? {
        let size = CGSize(width: 140, height: 140)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let colors: [UIColor] = [.systemBlue, .systemPink, .systemOrange, .systemTeal, .systemPurple]
            colors[index % colors.count].setFill()
            ctx.fill(CGRect(origin: .zero, size: size))

            let confidence = Int((item?.confidence ?? 0) * 100)
            let text = "#\(index + 1)\n\(confidence)%"
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraph
            ]

            let textRect = CGRect(x: 0, y: 45, width: size.width, height: 60)
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}
