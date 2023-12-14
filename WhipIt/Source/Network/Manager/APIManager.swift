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
    
    private let provider = MoyaProvider<LSLPAPI>(session: Session(interceptor: AuthInterceptor.shared))
  
    func request<T: Decodable>(target: LSLPAPI) -> Single<NetworkResult<T>> {
        return Single<NetworkResult<T>>.create { single in
            self.provider.request(target) { result in
                switch result {
                case .success(let response):
//                    dump(response)
//                    print(String(data: response.data, encoding: .utf8))
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
    
    func validateEmail(email: String) -> Single<NetworkResult<EmailValidationResponse>> {
        let model = EmailValidationRequest(email: email)
        return request(target: .emailValidation(model: model))
    }
    
    func requestSignUp(model: SignUpRequest) -> Single<NetworkResult<SignUpResponse>> {
        return request(target: .signUp(model: model))
    }
    
    func requestLogin(model: LoginRequest) -> Single<NetworkResult<LoginResponse>> {
        return request(target: .login(model: model))
    }
    
}

// MARK: 토큰 refresh API Method
extension APIManager {
    func refreshToken() -> Single<NetworkResult<RefreshResponse>> {
        return request(target: .refreshToken)
    }
    
    func refreshTokenWithoutRx() {
        provider.request(.refreshToken) { result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: POST 관련 API Method
extension APIManager {
    func requestCreatePost(model: CreatePostRequest) -> Single<NetworkResult<CreatePostResponse>> {
        return request(target: .createPost(model: model))
    }
    
    func requestGetPost(limit: Int, next: String?) -> Single<NetworkResult<GetPostResponse>> {
        return request(target: .getPost(limit: "\(limit)", next: next))
    }
    
    func requestLikePost(postID: String) -> Single<NetworkResult<LikePostResponse>> {
        return request(target: .likePost(postID: postID))
    }
}

// MARK: Comment 관련 API Method
extension APIManager {
    func requestCreateComment(model: CreateCommentRequest, postID: String) -> Single<NetworkResult<Comment>> {
        return request(target: .createComment(model: model, postID: postID))
    }
    
    func requestDeleteComment(postID: String, commentID: String) -> Single<NetworkResult<DeleteCommentResponse>> {
        return request(target: .deleteComment(postID: postID, commentID: commentID))
    }
}
