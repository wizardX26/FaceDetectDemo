//
//  UICollectionViewDataSource.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 17/4/26.
//

import UIKit

class DataSource: NSObject, UICollectionViewDataSource {
    var items: [VisionFace]?
    var faceImages: [UIImage]?
    var outputs: [VisionFaceOutput]?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let outputs, !outputs.isEmpty {
            return outputs.count
        }
        if self.faceImages != nil {
            return self.faceImages?.count ?? 0
        }
        return self.items?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "VisionCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! VisionCollectionViewCell

        let displayImage: UIImage?
        if let outputs = self.outputs {
            displayImage = indexPath.item < outputs.count ? outputs[indexPath.item].faceImage : nil
        } else if let faces = self.faceImages {
            displayImage = indexPath.item < faces.count ? faces[indexPath.item] : nil
        } else if let items = self.items, indexPath.item < items.count {
            displayImage = mockImage(for: items[indexPath.item], index: indexPath.item)
        } else {
            displayImage = nil
        }
        cell.update(display: displayImage)

        return cell
    }
    
    func output(at index: Int) -> VisionFaceOutput? {
        if let outputs = self.outputs, index >= 0, index < outputs.count {
            return outputs[index]
        }
        
        let image = self.faceImages?[safe: index]
        let face = self.items?[safe: index]
        
        if let image, let face {
            return VisionFaceOutput(faceImage: image, face: face)
        }
        
        if let image {
            return VisionFaceOutput(faceImage: image, face: VisionFace.placeholder)
        }
        
        if let face {
            return VisionFaceOutput(
                faceImage: mockImage(for: face, index: index) ?? UIImage(),
                face: face
            )
        }
        
        return nil
    }
    
    @discardableResult
    func removeItem(at index: Int) -> Bool {
        var didRemove = false
        
        if var outputs = self.outputs, index >= 0, index < outputs.count {
            outputs.remove(at: index)
            self.outputs = outputs
            didRemove = true
        }
        
        if var faceImages = self.faceImages, index >= 0, index < faceImages.count {
            faceImages.remove(at: index)
            self.faceImages = faceImages
            didRemove = true
        }
        
        if var items = self.items, index >= 0, index < items.count {
            items.remove(at: index)
            self.items = items
            didRemove = true
        }
        
        return didRemove
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

private extension VisionFace {
    static var placeholder: VisionFace {
        VisionFace(
            boundingBox: .zero,
            confidence: nil,
            yaw: nil,
            roll: nil,
            landmarks: VisionLandmarks(
                leftEye: nil,
                rightEye: nil,
                nose: nil,
                outerLips: nil
            )
        )
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}
