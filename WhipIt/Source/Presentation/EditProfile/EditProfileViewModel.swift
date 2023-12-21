//
//  EditProfileViewModel.swift
//  WhipIt
//
//  Created by Chaewon on 12/19/23.
//

import Foundation
import RxSwift
import RxCocoa

final class EditProfileViewModel: ViewModelType {
    
    private var disposeBag = DisposeBag()
    
    struct Input {
        let editType: EditProfileType
        let contentText: ControlProperty<String>
        let saveButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let contentValidation: BehaviorSubject<Bool>
        let content: BehaviorSubject<String>
        let editResponse: PublishSubject<NetworkResult<GetProfileResponse>>
    }
    
    func transform(input: Input) -> Output {
        
        let contentValidation = BehaviorSubject(value: false)
        let content = BehaviorSubject(value: "")
        let editResponse = PublishSubject<NetworkResult<GetProfileResponse>>()
        
        var editRequest: Observable<EditMyProfileRequest> {
            switch input.editType {
            case .nickname:
                input.contentText
                    .asObservable()
                    .map { $0.count >= 3 && $0.count <= 25 }
                    .bind(to: contentValidation)
                    .disposed(by: disposeBag)
                
                input.contentText
                    .asObservable()
                    .bind(to: content)
                    .disposed(by: disposeBag)
                
                return Observable.combineLatest(input.contentText, contentValidation)
                    .filter { $0.1 }
                    .map { text, validation in
                        return EditMyProfileRequest(nick: text, phoneNum: nil, profile: nil)
                    }
                
            case .phone:
                input.contentText
                    .asObservable()
                    .bind(with: self) { owner, value in
                        let result = value.formated(by: "###-####-####")
                        content.onNext(result)
                    }
                    .disposed(by: disposeBag)
                
                content
                    .map { $0.count >= 13 }
                    .bind(to: contentValidation)
                    .disposed(by: disposeBag)
                
                return Observable.combineLatest(input.contentText, contentValidation)
                    .filter { $0.1 }
                    .map { text, validation in
                        return EditMyProfileRequest(nick: nil, phoneNum: text, profile: nil)
                    }
            }
        }
        
        input.saveButtonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(editRequest) { _, request in
                return request
            }
            .flatMapLatest {
                APIManager.shared.requestEditMyProfile(model: $0)
            }
            .subscribe(with: self) { owner, result in
                editResponse.onNext(result)
            }
            .disposed(by: disposeBag)
        
        
        
        return Output(contentValidation: contentValidation, content: content, editResponse: editResponse)
    }
}
