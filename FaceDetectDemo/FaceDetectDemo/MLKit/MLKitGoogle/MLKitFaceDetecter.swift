//
//  MLKitFaceDetect.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 16/4/26.
//

import UIKit

import MLKitVision
import MLKitFaceDetection

class MLKitFaceDetecter {
    
    func extractFaceOutputs(from image: UIImage) async throws -> [MLKitFaceOutput] {
        let upRight = Self.imageByNormalizingOrientation(image)
        guard let cgImage = upRight.cgImage else { return [] }
        
        let faces = try await detectFaces(image: upRight)
        return faces.compactMap { detectedFace in
            guard let image = self.cropFace(cgImage: cgImage, scale: upRight.scale, face: detectedFace) else {
                return nil
            }
            
            return MLKitFaceOutput(
                faceImage: image,
                face: self.mapFace(detectedFace)
            )
        }
    }
    
    private func detectFaces(image: UIImage) async throws -> [Face] {
        return try await withCheckedThrowingContinuation { continuation in
            let visionImage = VisionImage(image: image)
            visionImage.orientation = image.imageOrientation
            
            let options = FaceDetectorOptions()
            let detector = FaceDetector.faceDetector(options: options)
            
            detector.process(visionImage) { faces, error in
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
    
    private func mapFace(_ face: Face) -> MLKitFace {
        let leftEye = self.landmarkPoint(for: .leftEye, in: face)
        let rightEye = self.landmarkPoint(for: .rightEye, in: face)
        let noseBase = self.landmarkPoint(for: .noseBase, in: face)
        let mouthLeft = self.landmarkPoint(for: .mouthLeft, in: face)
        let mouthRight = self.landmarkPoint(for: .mouthRight, in: face)
        
        let landmarks = MLKitLandmarks(
            leftEye: leftEye,
            rightEye: rightEye,
            noseBase: noseBase,
            mouthLeft: mouthLeft,
            mouthRight: mouthRight
        )
        
        return MLKitFace(
            frame: face.frame,
            headEulerAngleX: face.hasHeadEulerAngleX ? Float(face.headEulerAngleX) : nil,
            headEulerAngleY: face.hasHeadEulerAngleY ? Float(face.headEulerAngleY) : nil,
            headEulerAngleZ: face.hasHeadEulerAngleZ ? Float(face.headEulerAngleZ) : nil,
            smillingProbability: face.hasSmilingProbability ? Float(face.smilingProbability) : nil,
            leftEyeOpenProbability: face.hasLeftEyeOpenProbability ? Float(face.leftEyeOpenProbability) : nil,
            rightEyeOpenProbability: face.hasRightEyeOpenProbability ? Float(face.rightEyeOpenProbability) : nil,
            landmarks: landmarks
        )
    }
    
    func landmarkPoint(for type: FaceLandmarkType, in face: Face) -> CGPoint? {
        guard let landmark = face.landmark(ofType: type) else { return nil }
        let position = landmark.position
        return CGPoint(x: position.x, y: position.y)
    }
    
    private static func imageByNormalizingOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up { return image }
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }
}
