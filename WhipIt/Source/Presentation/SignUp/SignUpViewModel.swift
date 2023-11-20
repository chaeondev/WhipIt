//
//  SignUpViewModel.swift
//  WhipIt
//
//  Created by Chaewon on 11/20/23.
//

import Foundation
import RxSwift
import RxCocoa

class SignUpViewModel: ViewModelType {
    
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let pwRegEx = "^(?=.*[a-zA-Z])(?=.*[0-9]).{6,16}$"
    
    
    
    let disposeBag = DisposeBag()
    
    struct Input {
        let emailText: ControlProperty<String> // emailView.textField.rx.text.orEmpty
        let pwText: ControlProperty<String>
        let repwText: ControlProperty<String>
        let phoneText: ControlProperty<String>
        let tap: ControlEvent<Void>
    }
    
    struct Output {
        let tap: ControlEvent<Void>
        let checkEmailRegex: Observable<Bool>
        let emailDescription: BehaviorSubject<String>
    }
    
    func transform(input: Input) -> Output {
        
        let emailDescription = BehaviorSubject(value: JoinViewType.email.description)
        
        let checkEmailRegex = input.emailText
            .map { $0.range(of: self.emailRegEx, options: .regularExpression) != nil }
        
        checkEmailRegex
            .subscribe(with: self) { owner, value in
                let text = value ? "사용 가능한 이메일입니다" : "올바른 이메일을 입력해주세요"
                emailDescription.onNext(text)
            }
            .disposed(by: disposeBag)
        
        
        return Output(tap: input.tap, checkEmailRegex: checkEmailRegex, emailDescription: emailDescription)
        
    }
    
}
