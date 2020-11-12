//
//  Location.swift
//  stellar
//
//  Created by Nguyen Minh Quan on 11/12/20.
//

import Foundation
import ObjectMapper

struct Street: ImmutableMappable {
    var number: Int?
    var name: String?
    
    public init(map: Map) throws {
        number = try? map.value("number")
        name = try? map.value("name")
    }
}

struct Cordinate: ImmutableMappable {
    var longtitude: Double?
    var latitude: Double?
    
    public init(map: Map) throws {
        longtitude = try? map.value("longtitude")
        latitude = try? map.value("latitude")
    }
}

struct TimeZone: ImmutableMappable {
    var offset: Double?
    var description: String?
    
    public init(map: Map) throws {
        offset = try? map.value("offset")
        description = try? map.value("description")
    }
}

struct Location: ImmutableMappable {
    var street: Street?
    var city: String?
    var state: String?
    var country: String?
    var postCode: Int?
    var cordinate: Cordinate?
    
    public init(map: Map) throws {
        street = try? map.value("street")
        city = try? map.value("city")
        state = try? map.value("state")
        country = try? map.value("country")
        postCode = try? map.value("postCode")
        cordinate = try? map.value("cordinate")
    }
}
