//
//  SplashViewModel.swift
//  WhipIt
//
//  Created by Chaewon on 12/5/23.
//

import Foundation
import RxSwift
import RxCocoa

class SplashViewModel: ViewModelType {
    
    private var disposeBag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        let autoLoginValidation: PublishSubject<Bool>
    }
    
    func transform(input: Input) -> Output {
        let autoLoginValidation = PublishSubject<Bool>()
        
        if let _ = KeyChainManager.shared.accessToken,
           let _ = KeyChainManager.shared.refreshToken {
            APIManager.shared.refreshToken()
                .subscribe(with: self) { owner, result in
                    switch result {
                    case .success(let response):
                        KeyChainManager.shared.create(account: .accessToken, value: response.token)
                        autoLoginValidation.onNext(true)
                    case .failure(let error):
                        print("===autoLogin Error===", error)
                        switch error {
                        case .serverConflict:
                            autoLoginValidation.onNext(true)
                        default:
                            autoLoginValidation.onNext(false)
                            KeyChainManager.shared.delete(account: .accessToken)
                            KeyChainManager.shared.delete(account: .refreshToken)
                            
                        }
                    }
                }
                .disposed(by: disposeBag)
        }
        
        return Output(autoLoginValidation: autoLoginValidation)
    }
}
