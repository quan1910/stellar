//
//  LocalStorageService.swift
//  stellar
//
//  Created by Nguyen Minh Quan on 11/18/20.
//

import Foundation

protocol LocalStorageServiceType {
    func saveData<T: Codable>(_ data: T, key: String)
    func loadData<T: Decodable>(_ key: String, dataType: T.Type) -> [T]?
}

final class LocalStorageService: LocalStorageServiceType {
    
    private let userDefault: UserDefaults
    
    init(userDefault: UserDefaults) {
        self.userDefault = userDefault
    }
    
    func saveData<T: Codable>(_ data: T, key: String) {
        if let data = try? PropertyListEncoder().encode(data) {
            userDefault.setValue(data, forKey: key)
        }
    }
    func loadData<T: Decodable>(_ key: String, dataType: T.Type) -> [T]? {
        if let data = userDefault.data(forKey: key) {
            return try? PropertyListDecoder().decode([T].self, from: data)
        }
        return nil
    }
}

extension LocalStorageService {

    static let `default`: LocalStorageService = {
        return LocalStorageService(userDefault: UserDefaults.standard)
    }()
}
