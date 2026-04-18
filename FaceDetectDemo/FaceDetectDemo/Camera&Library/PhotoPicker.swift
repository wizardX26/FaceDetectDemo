//
//  PhotoPicker.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 18/4/26.
//

import UIKit
import PhotosUI

final class PhotosPicker: NSObject {
    private weak var viewController: UIViewController?
    private var completion: ((UIImage?) -> Void)?
    
    init(presenting viewController: UIViewController
    ) {
        self.viewController = viewController
    }
    
    func presentPhotosPicker(completion: @escaping ((UIImage?) -> Void)) {
        self.completion = completion
     
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        
        let phpPicker = PHPickerViewController(configuration: configuration)
        phpPicker.delegate = self
        
        self.viewController?.present(phpPicker, animated: true)
    }
}

extension PhotosPicker: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let item = results.first?.itemProvider else {
            completion?(nil)
            return
        }
        if item.canLoadObject(ofClass: UIImage.self) {
            item.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    switch error {
                    case nil:
                        self?.completion?(image as? UIImage)
                        
                    case let error?:
                        self?.completion?(nil)
                    }
                    
                    self?.completion = nil
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.completion?(nil)
                self?.completion = nil
            }
        }
    }
    
    
}
