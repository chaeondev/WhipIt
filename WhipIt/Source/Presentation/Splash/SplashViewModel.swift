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
        let autoLoginValidation: BehaviorSubject<AutoLoginValidation>
    }
    
    func transform(input: Input) -> Output {
        let autoLoginValidation = BehaviorSubject<AutoLoginValidation>(value: .nothing)
        
        if let _ = KeyChainManager.shared.accessToken,
           let _ = KeyChainManager.shared.refreshToken {
            APIManager.shared.refreshToken()
                .subscribe(with: self) { owner, result in
                    switch result {
                    case .success(let response):
                        KeyChainManager.shared.create(account: .accessToken, value: response.token)
                        autoLoginValidation.onNext(.accept)
                    case .failure(let error):
                        print("===autoLogin Error===", error)
                        switch error {
                        case .serverConflict:
                            autoLoginValidation.onNext(.accept)
                        default:
                            autoLoginValidation.onNext(.reject)
                            KeyChainManager.shared.delete(account: .accessToken)
                            KeyChainManager.shared.delete(account: .refreshToken)
                            KeyChainManager.shared.delete(account: .userID)
                        }
                    }
                }
                .disposed(by: disposeBag)
        } else {
            autoLoginValidation.onNext(.reject)
        }
        
        return Output(autoLoginValidation: autoLoginValidation)
    }
}

enum AutoLoginValidation {
    case accept
    case reject
    case nothing
}
