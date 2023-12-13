//
//  StyleDetailViewModel.swift
//  WhipIt
//
//  Created by Chaewon on 12/12/23.
//

import Foundation
import RxSwift
import RxCocoa

final class StyleDetailViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let commentText: ControlProperty<String>
        let registerButtonTap: ControlEvent<Void>
        let postID: String
    }
    
    struct Output {
        let commentResponse: PublishSubject<NetworkResult<Comment>>
        let commentValidation: BehaviorSubject<Bool>
    }
    
    func transform(input: Input) -> Output {
        
        let postIDSubject = BehaviorSubject(value: input.postID)
        let commentResponse = PublishSubject<NetworkResult<Comment>>()
        let commentValidation = BehaviorSubject(value: false)
        
        // MARK: Comment 등록 네트워크 통신
        input.commentText
            .map { !$0.isEmpty && $0.count >= 1 }
            .bind(to: commentValidation)
            .disposed(by: disposeBag)

        let items = Observable.combineLatest(input.commentText, postIDSubject, commentValidation)
        
        input.registerButtonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(items) { _, items in
                return items
            }
            .filter { $0.2 }
            .flatMapLatest { items in
                APIManager.shared.requestCreateComment(model: CreateCommentRequest(content: items.0), postID: items.1)
            }
            .subscribe(with: self) { owner, result in
                commentResponse.onNext(result)
            }
            .disposed(by: disposeBag)
                    
        return Output(commentResponse: commentResponse, commentValidation: commentValidation)
    }
}
