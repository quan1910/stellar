//
//  HomeViewModelTests.swift
//  StellarTests
//
//  Created by Nguyen Minh Quan on 11/22/20.
//s

import RxCocoa
import RxSwift
import Quick
import Nimble

@testable import Stellar

final class HomeViewModelSpec: QuickSpec {
    
    override func spec() {
        var sut: HomeViewModel!

        var candidateService: MockCandidateService!
        var localStorageService: MockLocalStorageService!

        var candidateResponse: CandidateResponse!

        beforeEach {
            candidateService = MockCandidateService()
            localStorageService = MockLocalStorageService()

            let mockCandidateDate = MockCandidateData()
            candidateResponse = mockCandidateDate.makeCandidateResponse()
            candidateService.stubbedGetCandidatesResult.accept(candidateResponse)

            sut = HomeViewModel(candidateService: candidateService,
                                                localStorageService: localStorageService)

        }

        describe("HomeViewModel trigger") {
            beforeEach {
                // Setup local storage service favorite person
                

                //mock current user profile

            }

            context("viewDidLoad") {
                beforeEach {
                    sut.viewDidLoadTrigger.accept(())
                }

                it("should call fetch candidates") {
                    expect(candidateService.invokedGetCandidates).to(beTrue())
                }
            }
            
            context("viewFavorite") {
                beforeEach {
                    sut.viewDidLoadTrigger.accept(())
                    sut.viewFavoriteTrigger.accept(())
                }

                it("should load favorite candidates") {
                    expect(localStorageService.invokedLoadData).to(beTrue())
                }
            }
        }
    }
}
