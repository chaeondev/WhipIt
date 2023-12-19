//
//  SearchViewModel.swift
//  WhipIt
//
//  Created by Chaewon on 12/19/23.
//

import Foundation
import RxSwift
import RxCocoa

final class SearchViewModel: ViewModelType {
    
    private var disposeBag = DisposeBag()
    
    struct Input {
        let hashtag: String
    }
    
    struct Output {
        let hashResult: PublishSubject<NetworkResult<GetPostResponse>>
    }
    
    func transform(input: Input) -> Output {
        
        let hashResult = PublishSubject<NetworkResult<GetPostResponse>>()
        
        APIManager.shared.requestHashtagList(limit: 50, next: nil, hashtag: input.hashtag)
            .asObservable()
            .subscribe(with: self) { owner, result in
                hashResult.onNext(result)
            }
            .disposed(by: disposeBag)
        
        return Output(hashResult: hashResult)
    }
}
