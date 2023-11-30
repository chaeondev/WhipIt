//
//  CreatePostViewModel.swift
//  WhipIt
//
//  Created by Chaewon on 11/30/23.
//

import Foundation
import RxSwift
import RxCocoa

enum ProductID {
    static let basic = "whipit_style"
}

class CreatePostViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let registerBarButtonTap: ControlEvent<Void>
        let contentText: ControlProperty<String>
        let imageData: Data
    }
    
    struct Output {
        let registerValidation: BehaviorSubject<Bool>
        let postResponse: PublishSubject<NetworkResult<CreatePostResponse>>
    }
    
    func transform(input: Input) -> Output {
        
        let registerValidation = BehaviorSubject(value: false)
        let imageRxData = BehaviorSubject(value: input.imageData)
        let postResponse = PublishSubject<NetworkResult<CreatePostResponse>>()
        
        // MARK: 등록 버튼 validation
        input.contentText
            .asObservable()
            .filter { $0 != "#아이템과 #스타일을 자랑해보세요"}
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .bind(to: registerValidation)
            .disposed(by: disposeBag)
        
        // MARK: post 등록 네트워크 통신
        let postRequest = Observable.combineLatest(
            input.contentText,
            imageRxData,
            registerValidation
        )
            .share()
            .filter { $0.2 }
            .map { text, image, validation in
                return CreatePostRequest(product_id: ProductID.basic, content: text, file: image)
            }
        
        input.registerBarButtonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(postRequest) { _, request in
                return request
            }
            .flatMapLatest {
                APIManager.shared.requestCreatePost(model: $0)
            }
            .subscribe(with: self) { owner, result in
                postResponse.onNext(result)
            }
            .disposed(by: disposeBag)
        
        
        
        return Output(registerValidation: registerValidation, postResponse: postResponse)
    }
}
