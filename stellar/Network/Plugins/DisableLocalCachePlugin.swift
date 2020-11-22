//
//  DisableLocalCachePlugin.swift
//  Stellar
//
//  Created by Nguyen Minh Quan on 11/11/20.
//

import Foundation
import Moya

public struct DisableLocalCachePlugin: PluginType {

    public init() {}

    public func prepare(_ request: URLRequest, target _: TargetType) -> URLRequest {
        var request = request
        request.cachePolicy = .reloadIgnoringLocalCacheData

        return request
    }
}
