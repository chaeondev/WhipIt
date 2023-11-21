//
//  APIManager.swift
//  WhipIt
//
//  Created by Chaewon on 11/16/23.
//

import Foundation
import Moya
import RxMoya
import RxSwift

enum NetworkResult<T: Decodable> {
    case success(T)
    case failure(APIError)
}

final class APIManager {
    
    static let shared = APIManager()
    private init() { }
    
    private let provider = MoyaProvider<JoinAPI>()
    
    func request<T: Decodable>(target: JoinAPI) -> Single<NetworkResult<T>> {
        return Single<NetworkResult<T>>.create { single in
            self.provider.request(target) { result in
                print(result)
                switch result {
                case .success(let response):
                    dump(response)
                    guard let decodedData = try? JSONDecoder().decode(T.self, from: response.data) else {
                        single(.success(.failure(.invalidData)))
                        return
                    }
                    switch response.statusCode {
                    case 200:
                        return single(.success(.success(decodedData)))
                    default:
                        return single(.success(.failure(.statusError)))
                    }
                case .failure(let error):
                    dump(error)
                    guard let statusCode = error.response?.statusCode, let networkError = APIError(rawValue: statusCode) else {
                        single(.success(.failure(.serverError)))
                    }
                    single(.success(.failure(networkError)))
                }
            }
            return Disposables.create()
        }
    }
}
