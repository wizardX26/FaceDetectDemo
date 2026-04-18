//
//  CameraViewController.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 18/4/26.
//

import UIKit

protocol CameraViewControllerDelegate: AnyObject {
    func didTakeImageResult(image: [UIImage])
}

class CameraViewController: UIViewController, StoryboardInstantiable {
    
    weak var delegate: CameraViewControllerDelegate?

    @IBOutlet weak var captureButton: UIButton!
    
    let cameraService = CameraService()
    var result = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.cameraService.configure()
        self.cameraService.attachPreview(to: view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.cameraService.updatePreviewFrame(view.bounds)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cameraService.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.cameraService.stop()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.captureButton.isHidden = false
        view.bringSubviewToFront(self.captureButton)
    }
    
    @IBAction func didTapRightBarBtn(_ sender: Any) {
        if !self.result.isEmpty {
            self.delegate?.didTakeImageResult(image: self.result)
                dismiss(animated: true)
        } else {
            dismiss(animated: true)
        }
        
    }
    
    @IBAction func didTapCaptureButton(_ sender: Any) {
        self.cameraService.capture { image in
            switch image {
            case nil: break // TODO: notify user
            case let image?: self.result.append(image)
            }
        }
    }
    
    deinit {
        self.cameraService.stop()
    }
}
