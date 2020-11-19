//
//  Environment.swift
//  stellar
//
//  Created by Nguyen Minh Quan on 11/12/20.
//

import Foundation

protocol EnvironmentType {
    var candidateService: CandidateServiceType { get }
    var localStorageService: LocalStorageServiceType { get }
}

final class Environment: EnvironmentType {
    var candidateService: CandidateServiceType { return CandidateService.default }
    
    var localStorageService: LocalStorageServiceType { return LocalStorageService.default }
}

struct AppEnvironment {

    /**
     A global stack of environments.
     */
    fileprivate static var stack: [EnvironmentType] = [Environment()]

    // The most recent environment on the stack.
    static var current: EnvironmentType {
        guard let last = stack.last else {
            fatalError("Cannot get current Environment")
        }
        return last
    }

    // Push a new environment onto the stack.
    static func pushEnvironment(_ env: EnvironmentType) {
        stack.append(env)
    }

    // Pop an environment off the stack.
    @discardableResult
    public static func popEnvironment() -> EnvironmentType? {
        return stack.popLast()
    }

    // Replace the current environment with a new environment.
    public static func replaceCurrentEnvironment(_ env: EnvironmentType) {
        pushEnvironment(env)
        stack.remove(at: stack.count - 2)
    }
}
