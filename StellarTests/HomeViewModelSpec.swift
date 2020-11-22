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
            }

            context("viewDidLoadTrigger") {
                beforeEach {
                    sut.viewDidLoadTrigger.accept(())
                }

                it("should call fetch candidates") {
                    expect(candidateService.invokedGetCandidates).to(beTrue())
                }
            }
            
            context("viewFavoriteTrigger") {
                beforeEach {
                    sut.viewFavoriteTrigger.accept(())
                }

                it("should load favorite candidates") {
                    expect(localStorageService.invokedLoadData).to(beTrue())
                }
            }
            
            context("reloadTrigger") {
                beforeEach {
                    sut.reloadTrigger.accept(())
                }

                it("should fetch new candidates") {
                    expect(candidateService.invokedGetCandidates).to(beTrue())
                }
            }
            
            context("addFavoriteTrigger") {
                beforeEach {
                    let mockCandidateDate = MockCandidateData()
                    
                    let person = mockCandidateDate.makePerson()!
                    sut.addFavoriteTrigger.accept(person)
                }

                it("should add new favorite") {
                    expect(localStorageService.invokedSaveData).to(beTrue())
                }
            }
            
            context("removeFavoriteTrigger") {
                beforeEach {
                    let mockCandidateDate = MockCandidateData()
                    
                    let person = mockCandidateDate.makePerson()!
                    sut.removeFavoriteTrigger.accept(person)
                }

                it("should add new favorite") {
                    expect(localStorageService.invokedSaveData).to(beTrue())
                }
            }
        }
    }
}
