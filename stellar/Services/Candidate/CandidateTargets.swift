//
//  CandidateTargets.swift
//  stellar
//
//  Created by Nguyen Minh Quan on 11/12/20.
//

import Foundation
import Moya

protocol CandidateTargetType: TargetType {}

extension CandidateTargetType {
    var baseURL: URL {
        let apiBase = "https://randomuser.me/api/"
        guard let url = URL(string: apiBase) else {
            fatalError("Invalid base URL \(apiBase)")
        }
        return url
    }
}

enum CandidateTargets {

    struct ListTarget: CandidateTargetType {

        var path: String { return "" }
        let method: Moya.Method = .get
        var task: Task { return Task.requestParameters(parameters: parameters, encoding: URLEncoding.queryString) }

        let offset: Int
        
        var parameters: [String: Any] {
            return [
                "results": offset
            ]
        }
    }
}
