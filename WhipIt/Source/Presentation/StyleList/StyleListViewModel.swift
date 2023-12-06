//
//  StyleListViewModel.swift
//  WhipIt
//
//  Created by Chaewon on 11/30/23.
//

import Foundation
import RxSwift
import RxCocoa
import Kingfisher

class StyleListViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let searchButtonTap: ControlEvent<Void>
        let prefetchItems: ControlEvent<[IndexPath]>
    }
    
    struct Output {
        let feedResult: PublishSubject<NetworkResult<GetPostResponse>>
    }
    
    func transform(input: Input) -> Output {
        
        let feedResult = PublishSubject<NetworkResult<GetPostResponse>>()
 
        APIManager.shared.requestGetPost(limit: 10, next: nil)
            .asObservable()
            .subscribe(with: self) { owner, result in
                feedResult.onNext(result)
            }
            .disposed(by: disposeBag)
    
        return Output(feedResult: feedResult)
    }
    
}

