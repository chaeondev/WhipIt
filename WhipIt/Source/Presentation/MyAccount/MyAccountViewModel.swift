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
        let accountType: AccountType
        let userID: String
    }
    
    struct Output {
        let profileResult: PublishSubject<NetworkResult<GetProfileResponse>>
        let postResult: PublishSubject<NetworkResult<GetPostResponse>>
        let likeCnt: BehaviorSubject<Int>

    }
    
    func transform(input: Input) -> Output {
        let profileResult = PublishSubject<NetworkResult<GetProfileResponse>>()
        let postResult = PublishSubject<NetworkResult<GetPostResponse>>()
        let likeCnt = BehaviorSubject(value: 0)
        
        // MARK: Profile 네트워크
        if input.accountType == .me {
            APIManager.shared.requestGetMyProfile()
                .subscribe(with: self) { owner, result in
                    profileResult.onNext(result)
                }
                .disposed(by: disposeBag)
        } else {
            APIManager.shared.requestGetUserProfile(userID: input.userID)
                .subscribe(with: self) { owner, result in
                    profileResult.onNext(result)
                }
                .disposed(by: disposeBag)
        }
        
        // MARK: 포스트 리스트 조회
        APIManager.shared.requestGetPostListByUserID(limit: 30, next: nil, userID: input.userID)
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
