//
//  PanGestureRecognizer+Extension.swift
//  stellar
//
//  Created by Nguyen Minh Quan on 11/19/20.
//

import UIKit

public enum Direction: Int {
    case left, right
}

public extension UIPanGestureRecognizer {

   var direction: Direction? {
        let velocity = self.velocity(in: view)
    
    return (velocity.x > 0) ? .right : .left
    }
}
