//
//  CandidateResponse.swift
//  Stellar
//
//  Created by Nguyen Minh Quan on 11/12/20.
//

import Foundation
import ObjectMapper

public struct CandidateResponse: Mappable {
    var offset: Int = 0
    var candidates: [Person] = []
    
    init() {}
    
    public init?(map: Map) {}
    
    mutating public func mapping(map: Map) {
        offset <- map["meta.offset"]
        candidates <- map["results"]
    }
}
