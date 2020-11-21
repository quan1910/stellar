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
    private var favoritePersons: Set<Person> = []
    private let favoriteStorageKey = "favoritedCandidates"
    
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
        favoritePersons.insert(person)
        localStorageService.saveData(favoritePersons, key: favoriteStorageKey)
    }
    
    func removeFavorite(_ person: Person) {
        favoritePersons.remove(person)
        localStorageService.saveData(favoritePersons, key: favoriteStorageKey)
    }
    
    func getFavorites() -> Set<Person> {
        
        return Set(localStorageService.loadData(favoriteStorageKey, dataType: Person.self) ?? [])
    }
    
    func loadFavoritesDataStream() {
        _personDataStream.accept(Array(getFavorites()))
    }
    
    private func configureFetchCandidates() {

        loadCandidatesAction
            .executing
            .subscribeNext { loading in
                if loading {
                    LoadingOverlay.setLoading(true)
                }
                
            }
            .disposed(by: disposeBag)

        loadCandidatesAction
            .elements
            .subscribeNext { [weak self] response in
                LoadingOverlay.setLoading(false)
                self?.persons = response.candidates
                self?._personDataStream.accept(response.candidates)
            }
            .disposed(by: disposeBag)

        loadCandidatesAction
            .underlyingError
            .subscribeNext { error in
                LoadingOverlay.setLoading(false)
            }
            .disposed(by: disposeBag)
    }
}

extension HomeViewModel {
    
    public var personDataStream: Observable<[Person]> {
        return _personDataStream.asObservable()
    }
}
