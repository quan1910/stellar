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

    // Services
    private let candidateService: CandidateServiceType
    private let localStorageService: LocalStorageServiceType

    // Datas
    private let _personDataStream = BehaviorRelay<[Person]>(value: [])
    private var persons: [Person] = []
    private var favoritePersons: [Person] = []
    private let favoriteStorage = "favoritedCandidates"
    
    // Actions
    private lazy var loadCandidatesAction = Action<Void, CandidateResponse> { [unowned self] in
        self.candidateService.getCandidates(offset: 50)
    }
    
    private let disposeBag = DisposeBag()

    init(candidateService: CandidateServiceType,
         localStorageService: LocalStorageServiceType) {
        self.candidateService = candidateService
        self.localStorageService = localStorageService
        configureFetchCandidates()
    }

    func fetchCandidates() {
        loadCandidatesAction.execute()
        favoritePersons = getFavorites()
    }
    
    func addFavorite(_ person: Person) {
        favoritePersons.append(person)
        localStorageService.saveData(favoritePersons, key: favoriteStorage)
    }
    
    func getFavorites() -> [Person] {
        return localStorageService.loadData(favoriteStorage, dataType: Person.self) ?? []
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
            .subscribeNext { [weak self] response in
                self?.persons = response.candidates
                self?._personDataStream.accept(response.candidates)
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
