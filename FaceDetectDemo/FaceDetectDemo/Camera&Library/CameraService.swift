//
//  CameraService.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 18/4/26.
//


import UIKit
import AVFoundation

final class CameraService: NSObject {
    
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    private var isConfigured = false
    
    private var completion: ((UIImage?) -> Void)?
    
    // MARK: - Setup
    
    func configure() {
        sessionQueue.sync {
            guard !isConfigured else { return }
            
            session.beginConfiguration()
            defer { session.commitConfiguration() }
            
            session.sessionPreset = .photo
            
            // Input (Camera)
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device),
                  session.canAddInput(input) else { return }
            
            session.addInput(input)
            
            // Output
            guard session.canAddOutput(photoOutput) else { return }
            session.addOutput(photoOutput)
            
            isConfigured = true
        }
    }
    
    // MARK: - Preview
    
    func attachPreview(to view: UIView) {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        
        view.layer.insertSublayer(layer, at: 0)
        self.previewLayer = layer
    }
    
    func updatePreviewFrame(_ frame: CGRect) {
        previewLayer?.frame = frame
    }
    
    // MARK: - Control
    
    func start() {
        sessionQueue.async {
            guard self.isConfigured, !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }
    
    func stop() {
        sessionQueue.async {
            guard self.session.isRunning else { return }
            self.session.stopRunning()
        }
    }
    
    // MARK: - Capture
    
    func capture(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
        
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            completion?(nil)
            completion = nil
            return
        }
        
        completion?(image)
        completion = nil
    }
}
