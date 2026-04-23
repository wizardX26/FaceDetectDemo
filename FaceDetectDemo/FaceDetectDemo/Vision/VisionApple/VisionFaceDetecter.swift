//
//  VisionApple.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 16/4/26.
//

import UIKit

import Vision

class VisionFaceDetecter {
    
    /// Crops each detected face as its own `UIImage` (orientation `.up`), one element per face.
    func extractFaces(from image: UIImage) async throws -> [UIImage] {
        let outputs = try await extractFaceOutputs(from: image)
        return outputs.map(\.faceImage)
    }

    /// Returns cropped image + Vision metadata for each face.
    func extractFaceOutputs(from image: UIImage) async throws -> [VisionFaceOutput] {
        let upright = Self.imageByNormalizingOrientation(image)
        guard let cgImage = upright.cgImage else { return [] }

        let observations = try await detectFaceRectangles(cgImage: cgImage)
        guard let observations, !observations.isEmpty else { return [] }

        return observations.compactMap { observation in
            guard let faceImage = cropFace(cgImage: cgImage, scale: upright.scale, observation: observation) else {
                return nil
            }

            let face = makeVisionFace(from: observation)
            return VisionFaceOutput(faceImage: faceImage, face: face)
        }
    }

    private func detectFaceRectangles(cgImage: CGImage) async throws -> [VNFaceObservation]? {
        let request = VNDetectFaceLandmarksRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        try handler.perform([request])
        return request.results as? [VNFaceObservation]
    }

    private func cropFace(cgImage: CGImage, scale: CGFloat, observation: VNFaceObservation) -> UIImage? {
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        let boundingBox = observation.boundingBox
        let rect = CGRect(
            x: boundingBox.origin.x * width,
            y: (1 - boundingBox.origin.y - boundingBox.height) * height,
            width: boundingBox.width * width,
            height: boundingBox.height * height
        )

        let expandedRect = rect.insetBy(dx: -rect.width, dy: -rect.height)
        let finalRect = expandedRect.intersection(CGRect(x: 0, y: 0, width: width, height: height))
        guard !finalRect.isEmpty, let croppedCGImage = cgImage.cropping(to: finalRect) else { return nil }

        return UIImage(cgImage: croppedCGImage, scale: scale, orientation: .up)
    }

    private func makeVisionFace(from observation: VNFaceObservation) -> VisionFace {
        let boundingBox = observation.boundingBox
        let landmarks = observation.landmarks

        return VisionFace(
            boundingBox: observation.boundingBox,
            confidence: observation.confidence,
            yaw: observation.yaw?.floatValue,
            roll: observation.roll?.floatValue,
            landmarks: VisionLandmarks(
                leftEye: mapPoints(landmarks?.leftEye, in: boundingBox),
                rightEye: mapPoints(landmarks?.rightEye, in: boundingBox),
                nose: mapPoints(landmarks?.nose, in: boundingBox),
                outerLips: mapPoints(landmarks?.outerLips, in: boundingBox)
            )
        )
    }
    
    func mapPoints(_ region: VNFaceLandmarkRegion2D?, in boundingBox: CGRect) -> [CGPoint]? {
        guard let points = region?.normalizedPoints, !points.isEmpty else { return nil }
        return points.map { point in
            CGPoint(
                x: boundingBox.origin.x + (CGFloat(point.x) * boundingBox.width),
                y: boundingBox.origin.y + (CGFloat(point.y) * boundingBox.height)
            )
        }
    }
    
    /// Renders the image so pixel data matches UIKit display (`UIImage.size` / draw). Vision + `CGImage` crop then share one coordinate space.
    private static func imageByNormalizingOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up { return image }
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }

}

