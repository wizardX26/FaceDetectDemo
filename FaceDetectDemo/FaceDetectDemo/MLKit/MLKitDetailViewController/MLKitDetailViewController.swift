//
//  MLKitDetailViewController.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 23/4/26.
//

import UIKit

class MLKitDetailViewController: UIViewController, StoryboardInstantiable {
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let imageView = UIImageView()
    private let detailsLabel = UILabel()
    
    private var output: MLKitFaceOutput?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "MLKit Detail"
        self.view.backgroundColor = .systemBackground
        self.setupViews()
        self.populateContent()
    }
    
    func configure(with output: MLKitFaceOutput) {
        self.output = output
        if self.isViewLoaded {
            self.populateContent()
        }
    }
}

private extension MLKitDetailViewController {
    func setupViews() {
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentStackView.axis = .vertical
        self.contentStackView.spacing = 16
        self.contentStackView.alignment = .fill
        
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.clipsToBounds = true
        self.imageView.layer.cornerRadius = 12
        self.imageView.backgroundColor = .secondarySystemBackground
        
        self.detailsLabel.numberOfLines = 0
        self.detailsLabel.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        self.detailsLabel.textColor = .label
        
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.contentStackView)
        self.contentStackView.addArrangedSubview(self.imageView)
        self.contentStackView.addArrangedSubview(self.detailsLabel)
        
        NSLayoutConstraint.activate([
            self.scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            self.contentStackView.topAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.topAnchor, constant: 16),
            self.contentStackView.leadingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            self.contentStackView.trailingAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            self.contentStackView.bottomAnchor.constraint(equalTo: self.scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            self.contentStackView.widthAnchor.constraint(equalTo: self.scrollView.frameLayoutGuide.widthAnchor, constant: -32),
            
            self.imageView.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.75)
        ])
    }
    
    func populateContent() {
        guard let output else { return }
        
        self.imageView.image = output.faceImage
        self.detailsLabel.text = self.detailsText(for: output.face)
    }
    
    func detailsText(for face: MLKitFace) -> String {
        let landmarks = face.landmarks
        
        return [
            "Frame: \(self.rectText(face.frame))",
            "Head Euler X: \(self.floatText(face.headEulerAngleX))",
            "Head Euler Y: \(self.floatText(face.headEulerAngleY))",
            "Head Euler Z: \(self.floatText(face.headEulerAngleZ))",
            "Smiling Prob: \(self.floatText(face.smillingProbability))",
            "Left Eye Open Prob: \(self.floatText(face.leftEyeOpenProbability))",
            "Right Eye Open Prob: \(self.floatText(face.rightEyeOpenProbability))",
            "Landmark Left Eye: \(self.pointText(landmarks.leftEye))",
            "Landmark Right Eye: \(self.pointText(landmarks.rightEye))",
            "Landmark Nose Base: \(self.pointText(landmarks.noseBase))",
            "Landmark Mouth Left: \(self.pointText(landmarks.mouthLeft))",
            "Landmark Mouth Right: \(self.pointText(landmarks.mouthRight))"
        ].joined(separator: "\n")
    }
    
    func rectText(_ rect: CGRect) -> String {
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
    
    func pointText(_ point: CGPoint?) -> String {
        guard let point else { return "N/A" }
        let x = String(format: "%.3f", point.x)
        let y = String(format: "%.3f", point.y)
        return "x:\(x), y:\(y)"
    }
}
