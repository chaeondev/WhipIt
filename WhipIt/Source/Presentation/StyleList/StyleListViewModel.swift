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
    }
    
    struct Output {
        let getPostResponse: PublishSubject<NetworkResult<GetPostResponse>>
    }
    
    func transform(input: Input) -> Output {
        
        let getPostResponse = PublishSubject<NetworkResult<GetPostResponse>>()
 
        APIManager.shared.requestGetPost(limit: 10)
            .asObservable()
            .subscribe(with: self) { owner, result in
                getPostResponse.onNext(result)
            }
            .disposed(by: disposeBag)
    
        return Output(getPostResponse: getPostResponse)
    }
}

