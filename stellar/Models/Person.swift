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
    var picture: Picture?
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
        picture = try? map.value("picture")
        location = try? map.value("location")
        email = try? map.value("email")
        dob = try? map.value("dob")
        homePhone = try? map.value("phone")
        cellPhone = try? map.value("cell")
        nat = try? map.value("nat")
    }
    
    var fullName: String? {
        get {
            guard let name = name else { return nil }
            var returnName = ""
            if let title = name.title {
                returnName += title
            }
            
            if let lastName = name.last {
                returnName += " \(lastName)"
            }
            
            if let firstName = name.first {
                returnName += " \(firstName)"
            }
            return returnName
        }
    }
    
    var fullAddress: String? {
        get {
            guard let location = location else { return nil }
            var returnAddress = ""
            if let streetNumber = location.street?.number, let streetName = location.street?.name {
                returnAddress += "\(streetNumber) \(streetName) Street"
            }
            
            if let cityName = location.city {
                returnAddress += ", \(cityName) City"
            }
            
            if let stateName = location.state {
                returnAddress += ", \(stateName) State"
            }
            return returnAddress
        }
    }
    
    var birthDate: String? {
        get {
            guard let dob = dob else { return nil }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            if let date = dob.date {
                return dateFormatter.string(from: date)
            }
            
            return nil
        }
    }
}
