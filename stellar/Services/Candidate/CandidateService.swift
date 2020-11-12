//
//  CandidateService.swift
//  stellar
//
//  Created by Nguyen Minh Quan on 11/12/20.
//

import Foundation
import RxSwift
import Moya_ObjectMapper

protocol CandidateServiceType {

    func getCandidates(offset: Int) -> Observable<CandidateResponse>
}

public class CandidateService: CandidateServiceType {

    private let api: APIType
    
    public init(api: APIType) {
        self.api = api
    }

    func getCandidates(offset: Int) -> Observable<CandidateResponse> {

        let listTarget = CandidateTargets.ListTarget(
            offset: offset
        )

        let globalScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())

        return api
            .request(target: listTarget)
            .observeOn(globalScheduler) // avoid blocking main thread with mapping
            .mapObject(CandidateResponse.self)
            .observeOn(MainScheduler.instance) // switch back to  main thread
            .asObservable()
    }
}

extension CandidateService {

    static let `default`: CandidateService = {
        return CandidateService(api: API.default)
    }()
}
