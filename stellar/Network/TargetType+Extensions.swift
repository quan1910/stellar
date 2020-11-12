//
//  TargetType+Extensions.swift
//  stellar
//
//  Created by Nguyen Minh Quan on 11/12/20.
//

import Foundation
import Moya

public extension TargetType {

    var headers: [String: String]? {
        return nil
    }
    
    var urlParameters: [String: Any]? {
        return nil
    }
    
    var parameterEncoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var validate: Bool {
        return false
    }
}
