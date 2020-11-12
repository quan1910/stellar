//
//  API.swift
//  stellar
//
//  Created by Nguyen Minh Quan on 11/11/20.
//

import Alamofire
import Foundation
import Moya
import RxSwift

extension URLRequest {
}

public protocol APIType {

    /// Request networking API
    ///
    /// - Parameters:
    ///   - target: Target to request
    /// - Returns: An observable sequence containing the single Response.
    func request(target: TargetType) -> Single<Response>
}

public protocol APIErrorPreprocessing {
}

open class API: APIType {
    public static let `default`: API = {
        API(provider: APIProvider.default)
    }()

    public static let defaultWithoutCache: API = {
        API(provider: APIProvider.defaultWithoutCache)
    }()

    // MARK: - Dependencies

    private let provider: MoyaProvider<MultiTarget>
    private let errorPreprocessor: APIErrorPreprocessing

    // MARK: - Init

    public init(provider: MoyaProvider<MultiTarget>,
                errorPreprocessor: APIErrorPreprocessing) {
        self.provider = provider
        self.errorPreprocessor = errorPreprocessor
    }
    
    public init(provider: MoyaProvider<MultiTarget> = APIProvider.default) {
        self.provider = provider
        self.errorPreprocessor = DefaultErrorProcessor()
    }

    /// Request networking API without JWT Token
    ///
    /// - Parameters:
    ///   - target: Target to request
    /// - Returns: An observable sequence containing the single Response.
    open func request(target: TargetType) -> Single<Response> {

        #if PERFORMANCE_TEST
        return Single<Response>.never()
        #endif

        return provider
            .rx.request(MultiTarget(target))
            .filterSuccessfulStatusCodes()
    }
}

// MARK: - Default MoyaProvider for API

public class APIProvider: MoyaProvider<MultiTarget> {

    public static let `default`: APIProvider = APIProvider()

    public static let defaultWithoutCache = APIProvider(allowCache: false)

    public static var plugins: [PluginType] {
        return [
            RequestTimeoutPlugin()
        ]
    }

    public init(endpointClosure: @escaping EndpointClosure = MoyaProvider<MultiTarget>.defaultEndpointMapping,
                requestClosure: @escaping RequestClosure = MoyaProvider<MultiTarget>.defaultRequestMapping,
                stubClosure: @escaping StubClosure = MoyaProvider.neverStub,
                callbackQueue: DispatchQueue? = nil,
                plugins: [PluginType] = APIProvider.plugins,
                allowCache: Bool = true) {

        var apiPlugins: [PluginType] = plugins

        plugins
            .compactMap { plugin in
                plugin as? NetworkLoggerPlugin
            }
            .forEach { plugin in
                apiPlugins.removeElement(plugin)
            }

        if allowCache {
            apiPlugins.append(DisableLocalCachePlugin())
        }
        
        let loggerPlugin = NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.networkConfiguration)
        apiPlugins.append(loggerPlugin)

        super.init(endpointClosure: endpointClosure,
                   requestClosure: requestClosure,
                   stubClosure: stubClosure,
                   callbackQueue: callbackQueue,
                   plugins: apiPlugins)
    }
}

private extension Array {

    /// Remove the given element from this array, by comparing pointer references.
    ///
    /// - parameter element: The element to remove.
    mutating func removeElement(_ element: Element) {
        guard let objIndex = firstIndex(where: { $0 as AnyObject === element as AnyObject }) else {
            return
        }
        remove(at: objIndex)
    }
}

public final class DefaultErrorProcessor: APIErrorPreprocessing {

    public init() {
    }
    
    public func transformErrorIfNeeded(_ error: Error) -> Error {
        return error
    }
    
}

