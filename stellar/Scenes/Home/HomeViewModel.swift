//
//  HomeViewModel.swift
//  stellar
//
//  Created by Nguyen Minh Quan on 11/14/20.
//

import Foundation
import Action
import RxSwift
import RxCocoa

protocol HomeViewModelProtocol {
    
    var personDataStream: Observable<[Person]> { get }
}

final class HomeViewModel: HomeViewModelProtocol {

    private let candidateService: CandidateServiceType
    private let _personDataStream = BehaviorRelay<[Person]>(value: [])
    
    private lazy var loadCandidatesAction = Action<Void, CandidateResponse> { [unowned self] in
        self.candidateService.getCandidates(offset: 50)
    }
    
    private let disposeBag = DisposeBag()

    init(candidateService: CandidateServiceType) {
        self.candidateService = candidateService
        configureFetchCandidates()
    }

    func fetchCandidates() {
        loadCandidatesAction.execute()
    }
    
    private func configureFetchCandidates() {

        loadCandidatesAction
            .executing
            .subscribeNext { [weak self] _ in
                print("LOADING")
            }
            .disposed(by: disposeBag)

        loadCandidatesAction
            .elements
            .subscribeNext { [weak self] candidates in
                self?._personDataStream.accept(candidates.candidates)
            }
            .disposed(by: disposeBag)

        loadCandidatesAction
            .underlyingError
            .subscribeNext { [weak self] error in
                print("ERROR \(error)")
            }
            .disposed(by: disposeBag)
    }
}

extension HomeViewModel {
    
    public var personDataStream: Observable<[Person]> {
        return _personDataStream.asObservable()
    }
}
