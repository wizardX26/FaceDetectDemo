//
//  CardSubtileEffect.swift
//  FaceDetectDemo
//
//  Created by wizard.os25 on 17/4/26.
//

import UIKit
import Foundation

@IBDesignable
final class CardSubtileEffect: UIView {
    
    // MARK: - Inspectable
    
    @IBInspectable
    var cornerRadius: CGFloat = 12 {
        didSet { layer.cornerRadius = cornerRadius }
    }
    
    @IBInspectable
    var shadowColor: UIColor = UIColor.black.withAlphaComponent(0.08) {
        didSet { layer.shadowColor = shadowColor.cgColor }
    }
    
    @IBInspectable
    var shadowOpacity: Float = 1 {
        didSet { layer.shadowOpacity = shadowOpacity }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat = 16 {
        didSet { layer.shadowRadius = shadowRadius }
    }
    
    @IBInspectable
    var shadowOffsetWidth: CGFloat = 0 {
        didSet { updateShadowOffset() }
    }
    
    @IBInspectable
    var shadowOffsetHeight: CGFloat = 4 {
        didSet { updateShadowOffset() }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .secondarySystemBackground
        
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        updateShadowOffset()
        
        clipsToBounds = false
    }
    
    private func updateShadowOffset() {
        layer.shadowOffset = CGSize(width: shadowOffsetWidth,
                                    height: shadowOffsetHeight)
    }
    
    // MARK: - Live render
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
    }
    
    // MARK: - IB Preview
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
}

extension CardSubtileEffect {
    func animatePressDown() {
        UIView.animate(withDuration: 0.15,
                       delay: 0,
                       options: [.curveEaseOut, .allowUserInteraction ]) {
            let scale = CGAffineTransform(scaleX: 0.96, y: 0.96)
            let translate = CGAffineTransform(translationX: 0, y: 2)

            self.transform = scale.concatenating(translate)
            self.layer.shadowOpacity = 0.5
        }
    }
    
    func animateRelease() {
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: [.curveEaseInOut, .allowUserInteraction]) {
            self.transform = .identity
            self.layer.shadowOpacity = 1
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            layer.shadowColor = self.shadowColor.resolvedColor(with: traitCollection).cgColor
        }
    }
}
