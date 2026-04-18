//
//  VisionModel.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 16/4/26.
//

import Foundation

struct VisionFace {
    let boundingBox: CGRect
    
    let confidence: Float?
    
    let yaw: Float?
    let roll: Float?
    
    let landmarks: VisionLandmarks
}

struct VisionLandmarks {
    let leftEye: [CGPoint]?
    let rightEye: [CGPoint]?
    let nose: [CGPoint]?
    let outerLips: [CGPoint]?
}
