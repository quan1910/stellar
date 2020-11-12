//
//  Person.swift
//  stellar
//
//  Created by Nguyen Minh Quan on 11/12/20.
//

import Foundation
import Foundation
import ObjectMapper

enum Gender: String {
    case male
    case female
    case notDisclosed
}

struct Name: ImmutableMappable {
    var title: String?
    var first: String?
    var last: String?
    
    public init(map: Map) throws {
        title = try? map.value("title")
        first = try? map.value("first")
        last = try? map.value("last")
    }
}

struct DateOfBirth: ImmutableMappable {
    var date: Date?
    var age: Int?
    
    public init(map: Map) throws {
        date = try? map.value("date")
        age = try? map.value("age")
    }
}

struct Picture: ImmutableMappable {
    var large: String?
    var medium: String?
    var thumbnail: String?
    
    public init(map: Map) throws {
        large = try? map.value("large")
        medium = try? map.value("medium")
        thumbnail = try? map.value("thumbnail")
    }
}

struct Identity: ImmutableMappable {
    var name: String?
    var value: String?
    
    public init(map: Map) throws {
        name = try? map.value("name")
        value = try? map.value("value")
    }
}


final class Person: ImmutableMappable {

    var id: String?
    var gender: Gender?
    var name: Name?
    var location: Location?
    var email: String?
    var dob: DateOfBirth?
    var homePhone: String?
    var cellPhone: String?
    var nat: String?

    public init(map: Map) throws {
        id = try? map.value("name")
        
        gender = try? map.value("gender", using: EnumTransform<Gender>())
        name = try? map.value("name")
        
        location = try? map.value("location")
        email = try? map.value("email")
        dob = try? map.value("dob")
        homePhone = try? map.value("phone")
        cellPhone = try? map.value("cell")
        nat = try? map.value("nat")
        
    }
}
