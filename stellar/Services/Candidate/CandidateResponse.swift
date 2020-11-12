//
//  CandidateResponse.swift
//  stellar
//
//  Created by Nguyen Minh Quan on 11/12/20.
//

import Foundation
import ObjectMapper

struct CandidateResponse: Mappable {
    var offset: Int = 0
    var candidates: [Person] = []
    
    init() {}
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        offset <- map["meta.offset"]
        candidates <- map["results"]
    }
}
