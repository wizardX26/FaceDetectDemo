//
//  Alertable.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 18/4/26.
//

import UIKit

protocol Alertable { }

extension Alertable where Self: UIViewController {
    func showAlert(
        title: String = "",
        message: String,
        preferredStyle: UIAlertController.Style = .alert,
        handler: ((UIAlertAction) -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(alert, animated: true)
    }
}
