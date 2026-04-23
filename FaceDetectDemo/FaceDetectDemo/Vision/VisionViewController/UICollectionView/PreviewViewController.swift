//
//  PreviewViewController.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 20/4/26.
//

import UIKit

class PreviewViewController: UIViewController, StoryboardInstantiable {
    
    @IBOutlet weak var viewInclude: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var bottomViewInclude: UIView!
    @IBOutlet weak var horiontalStackView: UIStackView!
    @IBOutlet weak var rightViewInclude: UIView!
    @IBOutlet weak var rightVerticalStackView: UIStackView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var fouthLabel: UILabel!
    
    @IBOutlet weak var leftViewInclude: UIView!
    @IBOutlet weak var leftVerticalStackView: UIStackView!
    @IBOutlet weak var fithLabel: UILabel!
    @IBOutlet weak var seventhLabel: UILabel!
    @IBOutlet weak var eightLabel: UILabel!
    @IBOutlet weak var nineLabel: UILabel!
    
    private var output: VisionFaceOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = CGSize(width: 300, height: 360)
        self.populateContent()
    }
    
    func configure(with output: VisionFaceOutput) {
        self.output = output
        if self.isViewLoaded {
            self.populateContent()
        }
    }
}

private extension PreviewViewController {
    func populateContent() {
        guard let output else { return }
        
        self.imageView.image = output.faceImage
        
        let face = output.face
        let landmarks = face.landmarks
        
        self.firstLabel.text = "Box: \(self.boundingBoxText(face.boundingBox))"
        self.secondLabel.text = "Confidence: \(self.floatText(face.confidence))"
        self.thirdLabel.text = "Yaw: \(self.floatText(face.yaw))"
        self.fouthLabel.text = "Roll: \(self.floatText(face.roll))"
        
        self.fithLabel.text = "Left eye: \(self.pointsText(landmarks.leftEye))"
        self.seventhLabel.text = "Right eye: \(self.pointsText(landmarks.rightEye))"
        self.eightLabel.text = "Nose: \(self.pointsText(landmarks.nose))"
        self.nineLabel.text = "Outer lips: \(self.pointsText(landmarks.outerLips))"
    }
    
    func boundingBoxText(_ rect: CGRect) -> String {
        let x = String(format: "%.3f", rect.origin.x)
        let y = String(format: "%.3f", rect.origin.y)
        let width = String(format: "%.3f", rect.width)
        let height = String(format: "%.3f", rect.height)
        return "x:\(x) y:\(y) w:\(width) h:\(height)"
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
