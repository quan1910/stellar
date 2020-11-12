//
//  TargetType+rawTarget.swift
//  stellar
//
//  Created by Nguyen Minh Quan on 11/11/20.
//

import Alamofire
import Moya
import RxSwift

public extension TargetType {

    var rawTarget: TargetType {

        if let multiTarget = self as? MultiTarget {
            return multiTarget.target
        }
        return self
    }
}
