//
//  UIView+Extensions.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 17/4/26.
//

import UIKit

public extension UIView {
    func visibility(hidden: Bool, dimension: CGFloat = 0.0, attribute: NSLayoutConstraint.Attribute = .height) {
        if let constraint = (self.constraints.filter { $0.firstAttribute == attribute }.first) {
            constraint.constant = hidden ? 0.0 : dimension
            self.layoutIfNeeded()
            self.isHidden = hidden
        }
    }
    
//    func getLayoutSizeFitting() -> CGSize {
//        setNeedsLayout()
//        layoutIfNeeded()
//        return systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
//    }
    
    func addSubviews(_ views: UIView...) {
        views.forEach {
            self.addSubview($0)
        }
    }
    
    func removeAllSubViews() {
        subviews.forEach {
            $0.removeFromSuperview()
        }
    }
}


