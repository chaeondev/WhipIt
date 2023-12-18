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
        let likeCnt: BehaviorSubject<Int>

    }
    
    func transform(input: Input) -> Output {
        let profileResult = PublishSubject<NetworkResult<GetMyProfileResponse>>()
        let postResult = PublishSubject<NetworkResult<GetPostResponse>>()
        let likeCnt = BehaviorSubject(value: 0)
        
        // MARK: My Profile 네트워크
        APIManager.shared.requestGetMyProfile()
            .subscribe(with: self) { owner, result in
                profileResult.onNext(result)
            }
            .disposed(by: disposeBag)
        
        guard let userID = KeyChainManager.shared.userID else { return Output(profileResult: profileResult, postResult: postResult, likeCnt: likeCnt)}
        
        // MARK: 내가 쓴 포스트 리스트 조회
        APIManager.shared.requestGetPostListByUserID(limit: 10, next: nil, userID: userID)
            .asObservable()
            .subscribe(with: self) { owner, result in
                postResult.onNext(result)
            }
            .disposed(by: disposeBag)
        
        // MARK: 북마크 개수 조회
        APIManager.shared.requestLikedPostList(limit: 100, next: nil)
            .asObservable()
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    likeCnt.onNext(response.data.count)
                case .failure(let error):
                    print("====북마크 개수 네트워크 오류=====", error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(profileResult: profileResult, postResult: postResult, likeCnt: likeCnt)
    }
    
 

}
