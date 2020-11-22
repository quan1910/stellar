//
//  HomeViewModel.swift
//  Stellar
//
//  Created by Nguyen Minh Quan on 11/14/20.
//

import Foundation
import Action
import RxSwift
import RxCocoa

protocol HomeViewModelType {
    var personDataStream: Observable<[Person]> { get }
    var reloadTrigger: PublishRelay<Void> { get }
    var viewDidLoadTrigger: PublishRelay<Void> { get }
    var viewFavoriteTrigger: PublishRelay<Void> { get }
    var addFavoriteTrigger: PublishRelay<Person> { get }
    var removeFavoriteTrigger: PublishRelay<Person> { get }
}

final class HomeViewModel: HomeViewModelType {
    
    // Listener
    var reloadTrigger = PublishRelay<Void>()
    var viewDidLoadTrigger = PublishRelay<Void>()
    var viewFavoriteTrigger = PublishRelay<Void>()
    var addFavoriteTrigger = PublishRelay<Person>()
    var removeFavoriteTrigger = PublishRelay<Person>()

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
        configureListener()
    }

    private func fetchCandidates() {
        loadCandidatesAction.execute()
        favoritePersons = getFavorites()
    }
    
    private func addFavorite(_ person: Person) {
        favoritePersons.insert(person)
        localStorageService.saveData(favoritePersons, key: favoriteStorageKey)
    }
    
    private func removeFavorite(_ person: Person) {
        favoritePersons.remove(person)
        localStorageService.saveData(favoritePersons, key: favoriteStorageKey)
    }
    
    private func getFavorites() -> Set<Person> {
        
        return Set(localStorageService.loadData(favoriteStorageKey, dataType: Person.self) ?? [])
    }
    
    private func loadFavoritesDataStream() {
        _personDataStream.accept(Array(getFavorites()))
    }
    
    private func configureListener() {
        reloadTrigger.subscribeNext { [weak self] _ in
            self?.fetchCandidates()
        }
        .disposed(by: disposeBag)
        
        viewFavoriteTrigger.subscribeNext { [weak self] _ in
            self?.loadFavoritesDataStream()
        }
        .disposed(by: disposeBag)
        
        viewDidLoadTrigger.subscribeNext { [weak self] _ in
            self?.fetchCandidates()
        }
        .disposed(by: disposeBag)
        
        addFavoriteTrigger.subscribeNext { [weak self] in
            self?.addFavorite($0)
        }
        .disposed(by: disposeBag)
        
        removeFavoriteTrigger.subscribeNext { [weak self] in
            self?.removeFavorite($0)
        }
        .disposed(by: disposeBag)
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
