//
//  LocalStorageService.swift
//  Stellar
//
//  Created by Nguyen Minh Quan on 11/18/20.
//

import Foundation

public protocol LocalStorageServiceType {
    func saveData<T: Codable>(_ data: T, key: String)
    func loadData<T: Decodable>(_ key: String, dataType: T.Type) -> [T]?
    func removeAll()
}

public final class LocalStorageService: LocalStorageServiceType {
    
    private let userDefault: UserDefaults
    
    public init(userDefault: UserDefaults) {
        self.userDefault = userDefault
    }
    
    public func removeAll() {
        if let appDomain = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: appDomain)
            }
    }
    
    public func saveData<T: Codable>(_ data: T, key: String) {
        if let data = try? PropertyListEncoder().encode(data) {
            userDefault.setValue(data, forKey: key)
        }
    }
    public func loadData<T: Decodable>(_ key: String, dataType: T.Type) -> [T]? {
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
