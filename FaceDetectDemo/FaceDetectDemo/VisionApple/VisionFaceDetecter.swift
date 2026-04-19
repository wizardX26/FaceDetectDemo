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
        let upright = Self.imageByNormalizingOrientation(image)
        guard let cgImage = upright.cgImage else { return [] }

        let observations = try await detectFaceRectangles(cgImage: cgImage)
        guard let observations, !observations.isEmpty else { return [] }

        return observations.compactMap { cropFace(cgImage: cgImage, scale: upright.scale, observation: $0) }
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
}

