//
//  MLKitModel.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 16/4/26.
//

import Foundation

struct MLKitFace {
    let frame: CGRect
    
    let headEulerAngleX: Float?
    let headEulerAngleY: Float?
    let headEulerAngleZ: Float?
    
    let smillingProbability: Float?
    let leftEyeOpenProbability: Float?
    let rightEyeOpenProbability: Float?
    
    let landmarks: MLKitLandmarks
}

struct MLKitLandmarks {
    let leftEye: CGPoint?
    let rightEye: CGPoint?
    let noseBase: CGPoint?
    let mouthLeft: CGPoint?
    let mouthRight: CGPoint?
}
