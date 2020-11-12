//
//  ViewController.swift
//  stellar
//
//  Created by Nguyen Minh Quan on 11/10/20.
//

import UIKit
import Action
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    private let candidateService: CandidateServiceType = AppEnvironment.current.candidateService
    
    private lazy var loadCandidatesAction = Action<Void, CandidateResponse> { [unowned self] in self.candidateService.getCandidates(offset: 50)
    }
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureInteractor()
        loadCandidatesAction.execute()
        // Do any additional setup after loading the view.
    }
    
    func configureInteractor() {

        loadCandidatesAction
            .executing
            .subscribeNext { [weak self] _ in
                print("LOADING")
            }
            .disposed(by: disposeBag)

        loadCandidatesAction
            .elements
            .subscribeNext { [weak self] candidates in
                print("SUCCESS \(candidates)")
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
