//
//  AuthInterceptor.swift
//  WhipIt
//
//  Created by Chaewon on 11/26/23.
//

import Foundation
import Alamofire
import RxSwift

final class AuthInterceptor: RequestInterceptor {
    
    static let shared = AuthInterceptor()
    
    private let disposeBag = DisposeBag()
    
    private init() {}
    
    //adapt: request 전 특정 작업을 하고싶은 경우 사용 -> token이 필요한 url api에 header 삽입
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
    
        let path = urlRequest.url?.lastPathComponent
        
        print(path ?? "can't find lastPathComponent")
        
        guard urlRequest.url?.absoluteString.hasPrefix(APIKey.baseURL) == true,
              ["join", "email", "login"].contains(path) == false,
              let accessToken = KeyChainManager.shared.accessToken
        else {
            completion(.success(urlRequest))
            return
        }
        
        var urlRequest = urlRequest
        urlRequest.setValue(accessToken, forHTTPHeaderField: "Authorization")
        
        if ["refresh"].contains(path) {
            let refreshToken = KeyChainManager.shared.refreshToken
            urlRequest.setValue(refreshToken, forHTTPHeaderField: "Refresh")
        }
        
        print("adaptor 적용 \(urlRequest.headers)")
        completion(.success(urlRequest))
    }
    
    //retry: request가 전송되고 받은 response에 따라 수행할 작업 지정 -> 통신 실패했을때 retry하는 기능
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        print("retry 진입")
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        //토큰 갱신 API 호출
        APIManager.shared.refreshToken()
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    print("Retry-토큰 재발급 성공")
                    KeyChainManager.shared.create(account: .accessToken, value: response.token)
                    completion(.retry)
                case .failure(let error):
                    completion(.doNotRetryWithError(error))
                }
            }
            .disposed(by: disposeBag)
        
    }
}
