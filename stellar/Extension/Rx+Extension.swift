//
//  ObservableType+Shortcuts.swift
//  RxShortcuts
//
//  Created by sunshinejr on 11/13/2016.
//  Copyright (c) 2016 sunshinejr. All rights reserved.
//
// https://github.com/sunshinejr/RxShortcuts

import RxSwift
import RxCocoa

// MARK: - RxSwift

public extension ObservableType {

    /**
     Subscribes an element handler to an observable sequence.
     
     - parameter onNext: Action to invoke for each element in the observable sequence.
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
    // @warn_unused_result(message: "http://git.io/rxs.ud")
    func subscribeNext(_ onNext: @escaping (Element) -> Void) -> Disposable {
        return self.subscribe(onNext: onNext)
    }
}
