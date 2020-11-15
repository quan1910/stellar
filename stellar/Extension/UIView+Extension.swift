//
//  UIView+Extension.swift
//  stellar
//
//  Created by Nguyen Minh Quan on 11/15/20.
//

import UIKit

extension UIView {

    func roundCorners(_ corners: UIRectCorner, cornerRadius: Double) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }

    func dropCardShadow() {
        layer.shadowColor = Colors.shadow.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 2.0
    }
}

