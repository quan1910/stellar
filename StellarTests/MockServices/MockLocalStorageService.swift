//
//  MockLocalStorageService.swift
//  StellarTests
//
//  Created by Nguyen Minh Quan on 11/22/20.
//

import RxCocoa
import RxSwift
import UIKit
import Stellar

public final class MockLocalStorageService: LocalStorageServiceType {
    
    var invokedSaveData = false
    var invokedSaveDataCount = 0
    public func saveData<T: Codable>(_ data: T, key: String) {
        invokedSaveData = true
        invokedSaveDataCount += 1
    }
    
    var invokedLoadData = false
    var invokedLoadDataCount = 0
    var stubbedCodableData: [Person] = []
    public func loadData<T: Decodable>(_ key: String, dataType: T.Type) -> [T]? {
        invokedLoadData = true
        invokedLoadDataCount += 1
        return stubbedCodableData as? [T]
    }
    
    var invokedRemoveAll = false
    var invokedRemoveAllCount = 0
    public func removeAll() {
        invokedRemoveAll = true
        invokedRemoveAllCount += 1
        
    }
    public init() {}
}
