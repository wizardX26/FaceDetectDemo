//
//  MLKitFaceDetect.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 16/4/26.
//

import UIKit

import MLKit
import MLKitFaceDetection

class MLKitFaceDetecter {
    
    func extractFaces( from image: UIImage) async throws -> [UIImage] {
        let upRight = Self.imageByNormalizingOrientation(image)
        guard let cgImage = upRight.cgImage else { return [] }
        
        let faces = try await detectFaces(image: upRight)
        guard !faces.isEmpty else { return [] }
        
        return faces.compactMap {
            self.cropFace(cgImage: cgImage, scale: upRight.scale, face: $0)
        }
    }
    
    private func detectFaces(image: UIImage) async throws -> [Face] {
        return try await withCheckedThrowingContinuation { continuation in
            let visionImage = VisionImage(image: image)
            visionImage.orientation = image.imageOrientation
            
            let options = FaceDetectorOptions()
            let detector = FaceDetector.faceDetector(options: options)
            
            detector.process(visionImage) { [weak self] faces, error in
                switch error {
                case nil:           continuation.resume(returning: faces ?? [])
                case let error?:    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func cropFace(cgImage: CGImage, scale: CGFloat, face: Face) -> UIImage? {
        let rect = face.frame
        
        guard let croppedCGImage = cgImage.cropping(to: rect) else { return nil }
        return UIImage(cgImage: croppedCGImage, scale: scale, orientation: .up)
    }
    
    private static func imageByNormalizingOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up { return image }
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }
}
