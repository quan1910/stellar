//
//  MockCandidateService.swift
//  StellarTests
//
//  Created by Nguyen Minh Quan on 11/22/20.
//

import RxCocoa
import RxSwift
import UIKit
import Stellar

public final class MockCandidateService: CandidateServiceType {

    public var stubbedGetCandidatesResult = PublishRelay<CandidateResponse>()
    public var invokedGetCandidates = false
    public var invokedGetCandidateCount = 0
    public func getCandidates(offset: Int) -> Observable<CandidateResponse> {
        invokedGetCandidates = true
        invokedGetCandidateCount += 1
        return stubbedGetCandidatesResult.asObservable()
    }
    public init() {}
}
