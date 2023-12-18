//
//  BookMarkViewModel.swift
//  WhipIt
//
//  Created by Chaewon on 12/15/23.
//

import Foundation
import RxSwift
import RxCocoa

final class BookMarkViewModel: ViewModelType {
    
    private var disposeBag = DisposeBag()
    
    struct Input {
        
    }
    
    struct Output {
        let postList: PublishSubject<NetworkResult<GetPostResponse>>
    }
    
    func transform(input: Input) -> Output {
        let postList = PublishSubject<NetworkResult<GetPostResponse>>()
        
        APIManager.shared.requestLikedPostList(limit: 100, next: nil)
            .asObservable()
            .subscribe(with: self) { owner, result in
                postList.onNext(result)
            }
            .disposed(by: disposeBag)
        
        return Output(postList: postList)
    }
}
