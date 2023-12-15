//
//  MyAccountViewModel.swift
//  WhipIt
//
//  Created by Chaewon on 12/14/23.
//

import Foundation
import RxSwift
import RxCocoa

final class MyAccountViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        let profileResult: PublishSubject<NetworkResult<GetMyProfileResponse>>
        let postResult: PublishSubject<NetworkResult<GetPostResponse>>

    }
    
    func transform(input: Input) -> Output {
        let profileResult = PublishSubject<NetworkResult<GetMyProfileResponse>>()
        let postResult = PublishSubject<NetworkResult<GetPostResponse>>()
        
        APIManager.shared.requestGetMyProfile()
            .subscribe(with: self) { owner, result in
                profileResult.onNext(result)
            }
            .disposed(by: disposeBag)
        guard let userID = KeyChainManager.shared.userID else { return Output(profileResult: profileResult, postResult: postResult)}
        
        APIManager.shared.requestGetPostListByUserID(limit: 10, next: nil, userID: userID)
            .asObservable()
            .subscribe(with: self) { owner, result in
                postResult.onNext(result)
            }
            .disposed(by: disposeBag)
        
        return Output(profileResult: profileResult, postResult: postResult)
    }
    
 

}
