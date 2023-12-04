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
//    static let basic = "whipit_style" //"whipit_style_test", "whipit_test1"
    static let test = "whipit_test1"
}

class CreatePostViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let registerBarButtonTap: ControlEvent<Void>
        let contentText: ControlProperty<String>
        let imageData: Observable<Data?>
        let imageRatio: Observable<CGFloat>
    }
    
    struct Output {
        let registerValidation: BehaviorSubject<Bool>
        let postResponse: PublishSubject<NetworkResult<CreatePostResponse>>
    }
    
    func transform(input: Input) -> Output {
        
        let checkContent = BehaviorSubject(value: false)
        let checkImage = BehaviorSubject(value: false)
        let registerValidation = BehaviorSubject(value: false)
        
        let ratio = BehaviorSubject(value: "")
        let postResponse = PublishSubject<NetworkResult<CreatePostResponse>>()
        
        // MARK: 등록 버튼 validation -> 수정 content, image 확인
        input.contentText
            .asObservable()
            .filter { $0 != "#아이템과 #스타일을 자랑해보세요"}
            .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .bind(to: checkContent)
            .disposed(by: disposeBag)
        
        input.imageData
            .map { $0 != nil }
            .bind(to: checkImage)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(checkContent, checkImage)
            .map { $0 && $1 }
            .bind(to: registerValidation)
            .disposed(by: disposeBag)
        
        // MARK: image Ratio 변환
        input.imageRatio
            .filter { $0 != 0.0 }
            .map {
                print("===$0===", $0)
                print("====strRatio====", String(format: "%.2f", $0))
                return String(format: "%.2f", $0)
            }
            .bind(to: ratio)
            .disposed(by: disposeBag)
        
        
        // MARK: post 등록 네트워크 통신
        
        let postRequest = Observable.combineLatest(
            input.contentText,
            input.imageData,
            ratio,
            registerValidation
        )
            .share()
            .filter { $0.3 }
            .map { text, image, ratio, validation in
                
                return CreatePostRequest(product_id: ProductID.test, content: text, content1: ratio, file: image!)
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
