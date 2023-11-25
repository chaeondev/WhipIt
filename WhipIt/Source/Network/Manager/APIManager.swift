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
                switch result {
                case .success(let response):
//                    dump(response)
                    guard let decodedData = try? JSONDecoder().decode(T.self, from: response.data) else {
                        single(.success(.failure(.invalidData)))
                        return
                    }
                    print("==DecodedData==", decodedData)
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
                        return
                    }
                    single(.success(.failure(networkError)))
                }
            }
            return Disposables.create()
        }
    }
}

// MARK: 회원가입 API Method
extension APIManager {
    
    func fetchEmailValidation(email: String) -> Single<NetworkResult<EmailValidationResponse>> {
        let model = EmailValidationRequest(email: email)
        return request(target: .emailValidation(model: model))
    }
    
    func fetchSignUpRequest(model: SignUpRequest) -> Single<NetworkResult<SignUpResponse>> {
        return request(target: .signUp(model: model))
    }
}
