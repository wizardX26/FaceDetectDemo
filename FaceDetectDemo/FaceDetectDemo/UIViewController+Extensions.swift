//
//  File.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 17/4/26.
//

import UIKit

public extension UIViewController {
    func addChild(_ childController: UIViewController, to containerView: UIView) {
        addChild(childController)
        containerView.addSubview(childController.view)
        childController.view.frame = containerView.bounds
        childController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childController.didMove(toParent: self)
    }
    
    func removeChild(_ childController: UIViewController, animated: Bool = false) {
        guard childController.parent != nil else { return }
        
        let remove = {
            childController.willMove(toParent: nil)
            childController.view.removeFromSuperview()
            childController.removeFromParent()
        }
        
        if animated {
            UIView.animate(withDuration: 0.4) { [weak self] in
                self?.view.alpha = 0.0
            } completion: { [weak self] (_) in
                guard let self = self else { return }
                remove()
            }
        } else {
            remove()
        }
    }
}
