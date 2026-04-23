//
//  UICollectionDelegate.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 17/4/26.
//

import UIKit

class Delegate: NSObject, UICollectionViewDelegate {
    
    weak var dataSource: DataSource?
    weak var hostViewController: UIViewController?
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = self.dataSource?.output(at: indexPath.item) else { return }
        let previewViewController = self.makePreviewViewController(for: item)
        previewViewController.modalPresentationStyle = .pageSheet
        self.presenter(from: collectionView)?.present(previewViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? VisionCollectionViewCell else { return }
        cell.cardView.animatePressDown()
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? VisionCollectionViewCell else { return }
        cell.cardView.animateRelease()
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return self.contextMenuConfiguration(for: indexPath, in: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first else { return nil }
        return self.contextMenuConfiguration(for: indexPath, in: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let indexPath = configuration.identifier as? NSIndexPath,
              let item = self.dataSource?.output(at: indexPath.item) else { return }
        
        animator.addCompletion { [weak self, weak collectionView] in
            guard let self, let collectionView else { return }
            let previewViewController = self.makePreviewViewController(for: item)
            previewViewController.modalPresentationStyle = .pageSheet
            self.presenter(from: collectionView)?.present(previewViewController, animated: true)
        }
    }
    
    private func makeMenu(for item: VisionFaceOutput, at indexPath: IndexPath, in collectionView: UICollectionView) -> UIMenu {
        
        let save = UIAction(
            title: "Save",
            image: UIImage(systemName: "doc.richtext")
        ) { _ in
            self.savePDF(for: item, in: collectionView)
        }
        
        let copy = UIAction(
            title: "Copy",
            image: UIImage(systemName: "doc.on.doc")
        ) { _ in
            self.copyToPasteboard(item)
            self.presentMessage(
                title: "Copied",
                message: "Face data has been copied to clipboard.",
                from: collectionView
            )
        }
        
        let delete = UIAction(
            title: "Delete",
            image: UIImage(systemName: "trash"),
            attributes: .destructive
        ) { _ in
            self.deleteItem(at: indexPath, from: collectionView)
        }
        
        return UIMenu(title: "", children: [save, copy, delete])
    }
    
    func contextMenuConfiguration(for indexPath: IndexPath, in collectionView: UICollectionView) -> UIContextMenuConfiguration? {
        guard let item = self.dataSource?.output(at: indexPath.item) else { return nil }
        
        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath,
            previewProvider: { [weak self] in
                self?.makePreviewViewController(for: item)
            },
            actionProvider: { [weak self, weak collectionView] _ in
                guard let self, let collectionView else { return nil }
                return self.makeMenu(for: item, at: indexPath, in: collectionView)
            }
        )
    }
}

private extension Delegate {
    func makePreviewViewController(for item: VisionFaceOutput) -> PreviewViewController {
        let viewController = PreviewViewController.instantiateViewController()
        viewController.configure(with: item)
        return viewController
    }
    
    func copyToPasteboard(_ item: VisionFaceOutput) {
        UIPasteboard.general.string = self.detailsText(for: item)
    }
    
    func deleteItem(at indexPath: IndexPath, from collectionView: UICollectionView) {
        guard self.dataSource?.removeItem(at: indexPath.item) == true else { return }
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [indexPath])
        }
    }
    
    func savePDF(for item: VisionFaceOutput, in collectionView: UICollectionView) {
        guard let data = self.pdfData(for: item) else {
            self.presentMessage(
                title: "Save Failed",
                message: "Cannot generate PDF data for this face.",
                from: collectionView
            )
            return
        }
        
        guard let folderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            self.presentMessage(
                title: "Save Failed",
                message: "Cannot access Documents directory.",
                from: collectionView
            )
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let fileName = "FaceInfo_\(formatter.string(from: Date())).pdf"
        let fileURL = folderURL.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL, options: .atomic)
            self.presentMessage(
                title: "Saved",
                message: "PDF saved to \(fileName) in app Documents.",
                from: collectionView
            )
        } catch {
            self.presentMessage(
                title: "Save Failed",
                message: error.localizedDescription,
                from: collectionView
            )
        }
    }
    
    func pdfData(for item: VisionFaceOutput) -> Data? {
        let previewViewController = self.makePreviewViewController(for: item)
        _ = previewViewController.view
        previewViewController.view.frame = CGRect(x: 0, y: 0, width: 220, height: 300)
        previewViewController.view.layoutIfNeeded()
        
        let bounds = previewViewController.view.bounds
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: bounds, format: format)
        
        return renderer.pdfData { context in
            context.beginPage()
            previewViewController.view.layer.render(in: context.cgContext)
        }
    }
    
    func presenter(from collectionView: UICollectionView) -> UIViewController? {
        if let hostViewController {
            return hostViewController
        }
        
        var responder: UIResponder? = collectionView
        while let current = responder {
            if let viewController = current as? UIViewController {
                return viewController
            }
            responder = current.next
        }
        
        return nil
    }
    
    func presentMessage(title: String, message: String, from collectionView: UICollectionView) {
        guard let presenter = self.presenter(from: collectionView) else { return }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        presenter.present(alert, animated: true)
    }
    
    func detailsText(for item: VisionFaceOutput) -> String {
        let face = item.face
        let landmarks = face.landmarks
        
        return [
            "Bounding Box: \(self.boundingBoxText(face.boundingBox))",
            "Confidence: \(self.floatText(face.confidence))",
            "Yaw: \(self.floatText(face.yaw))",
            "Roll: \(self.floatText(face.roll))",
            "Left eye: \(self.pointsText(landmarks.leftEye))",
            "Right eye: \(self.pointsText(landmarks.rightEye))",
            "Nose: \(self.pointsText(landmarks.nose))",
            "Outer lips: \(self.pointsText(landmarks.outerLips))"
        ].joined(separator: "\n")
    }
    
    func boundingBoxText(_ rect: CGRect) -> String {
        let x = String(format: "%.3f", rect.origin.x)
        let y = String(format: "%.3f", rect.origin.y)
        let width = String(format: "%.3f", rect.width)
        let height = String(format: "%.3f", rect.height)
        return "x:\(x), y:\(y), w:\(width), h:\(height)"
    }
    
    func floatText(_ value: Float?) -> String {
        guard let value else { return "N/A" }
        return String(format: "%.3f", value)
    }
    
    func pointsText(_ points: [CGPoint]?) -> String {
        guard let points else { return "N/A" }
        return "\(points.count) point(s)"
    }
}
