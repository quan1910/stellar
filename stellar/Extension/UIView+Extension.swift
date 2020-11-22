//
//  UIView+Extension.swift
//  Stellar
//
//  Created by Nguyen Minh Quan on 11/15/20.
//

import UIKit

extension UIView {
    func dropCardShadow() {
        layer.shadowColor = Colors.shadow.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 2.0
    }
}
