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

enum APIError: Error {
    case invalidKey
    case overcall
    case invalidURL
    case serverError
    case statusError
}

enum SignUpError: Error {
    case insufficientInfo
    case alreadyJoin
}
    

class APIManager {
    
    static let shared = APIManager()
    private init() { }
    
    private let provider = MoyaProvider<JoinAPI>()
    
    func signUp(model: SignUpRequest) -> Single<SignUpResponse> {
        return Single<SignUpResponse>.create { single in
            self.provider.request(.signUp(model: model)) { result in
                print(result)
                switch result {
                case .success(let response):
                    print(response.statusCode)
                    guard let decodedData = try? JSONDecoder().decode(SignUpResponse.self, from: response.data) else { return }
                    print(decodedData)
                    switch response.statusCode {
                    case 200..<300:
                        return single(.success(decodedData))
                    case 420:
                        return single(.failure(APIError.invalidKey))
                    case 429:
                        return single(.failure(APIError.overcall))
                    case 444:
                        return single(.failure(APIError.invalidURL))
                    case 500:
                        return single(.failure(APIError.serverError))
                    case 400:
                        return single(.failure(SignUpError.insufficientInfo))
                    case 409:
                        return single(.failure(SignUpError.alreadyJoin))
                    default:
                        return single(.failure(APIError.statusError))
                    }
                            
                            
                case .failure(let error):
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

}
