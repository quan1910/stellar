//
//  RequestTimeoutPlugin.swift
//  stellar
//
//  Created by Nguyen Minh Quan on 11/11/20.
//

import Foundation
import Moya

public enum RequestTimeoutLevel: Double {
    case `default` = 0
    case level1 = 15.0
    case level2 = 30.0
    case level3 = 60.0
    case level4 = 90.0
}

public protocol RequestTimeoutConfigurable {
    
    var timeoutLevel: RequestTimeoutLevel { get }
}

public struct RequestTimeoutPlugin: PluginType {
    
    public init() {
        
    }
    
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let target = target.rawTarget as? RequestTimeoutConfigurable else { return request }
        
        guard target.timeoutLevel != .default else { return request }
        
        var request = request
        request.timeoutInterval = target.timeoutLevel.rawValue
        return request
    }
}
