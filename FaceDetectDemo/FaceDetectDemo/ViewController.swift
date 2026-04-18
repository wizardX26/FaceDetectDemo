//
//  ViewController.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 16/4/26.
//

import UIKit

protocol VisionFaceDetecting: AnyObject {
    func detectVisionFaces(in image: UIImage) async throws -> [VisionFace]
}

protocol MLKitFaceDetecting: AnyObject {
    func detectMLKitFaces(in image: UIImage) async throws -> [MLKitFace]
}

class ViewController: UIViewController {
        
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var outerBtnView: UIView!
    @IBOutlet weak var modelButton: UIButton!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var contentView: UIView!
    
    private var visionViewCOntroller: VisionViewController!
    private var mlKitViewController: MLKitViewController!
    private var cameraViewController: CameraViewController!
    
    private var currentViewController: UIViewController?

    private var photosPicker: PhotosPicker!
    private var resultImage: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupMenu()
        self.setupChildViewControllers()
        self.switchController(index: self.segmentedControl.selectedSegmentIndex)
        
        self.photosPicker = PhotosPicker.init(presenting: self)
    }
    
    @IBAction func didTapLeftBarBtn(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
                let cameraNavigationController = UINavigationController(rootViewController: self.cameraViewController)
                cameraNavigationController.modalPresentationStyle = .fullScreen
                self.present(cameraNavigationController, animated: true)
            })
            
            alert.addAction(UIAlertAction(title: "Thư viện", style: .default) { _ in
                self.photosPicker.presentPhotosPicker { image in
                    self.imageView.image = image
                }
            })
            
            alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
            
            present(alert, animated: true)
    }
    

    @IBAction func didTapRightBarBtn(_ sender: Any) {
        self.animateView(self.outerBtnView)
    }
    
    @IBAction func didChangeValueSegmentedControler(_ sender: Any) {
        self.switchController(index: self.segmentedControl.selectedSegmentIndex)
    }
    
    enum ModelType {
        case vision
        case mlkit
    }
    
    private func setupMenu() {
        let visionAction = UIAction(title: "Vision") { [weak self] _ in
            self?.selectModel(.vision)
        }
        
        let mlkitAction = UIAction(title: "MLKit") { [weak self] _ in
            self?.selectModel(.mlkit)
        }
        
        let menu = UIMenu(title: "Select Model",
                          options: .singleSelection,
                          children: [visionAction, mlkitAction])
        
        self.modelButton.menu = menu
        self.modelButton.showsMenuAsPrimaryAction = true
    }
    
    private func selectModel(_ model: ModelType) {
        switch model {
        case .vision:
            self.modelButton.setTitle("Vision", for: .normal)
            
        case .mlkit:
            self.modelButton.setTitle("MLKit", for: .normal)
        }
    }
    
    
    private func setupChildViewControllers() {
        self.visionViewCOntroller = VisionViewController.instantiateViewController()
        self.mlKitViewController = MLKitViewController.instantiateViewController()
        self.cameraViewController = CameraViewController.instantiateViewController()
        self.cameraViewController.delegate = self
    }
    
    private func switchController(index: Int) {
        let destinationController: UIViewController
        
        switch index {
        case 0: destinationController = self.visionViewCOntroller
        case 1: destinationController = self.mlKitViewController
            
        default: return
        }
        
        if self.currentViewController == destinationController { return }
        if let current = self.currentViewController { self.removeChild(current) }
        
        self.addChild(destinationController, to: self.contentView)
        self.currentViewController = destinationController
    }
    
    func animateView(_ view: UIView) {
        UIView.animate(withDuration: 0.25, animations: {
            
            view.transform = CGAffineTransform(translationX: -4, y: 2)
            
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                
                UIView.animate(withDuration: 0.2, animations: {
                    view.transform = CGAffineTransform(translationX: 4, y: -4)
                }) { _ in
                    UIView.animate(
                        withDuration: 0.6,
                        delay: 0,
                        usingSpringWithDamping: 0.3,
                        initialSpringVelocity: 1.3
                    ) {
                        view.transform = .identity
                    }
                }
            }
        }
    }
}

extension ViewController: CameraViewControllerDelegate {
    func didTakeImageResult(image: [UIImage]) {
        self.resultImage = image
        self.imageView.image = self.resultImage.first
    }
}
