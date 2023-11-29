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
    static let basic = "whipit/style"
}

class CreatePostViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let registerBarButtonTap: ControlEvent<Void>?
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
        
        return Output(registerValidation: registerValidation, postResponse: postResponse)
    }
}
