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
        let emailValidation: BehaviorSubject<Bool>
        let emailDescription: BehaviorSubject<String>
        let checkPWRegex: BehaviorSubject<Bool>
        let pwDescription: BehaviorSubject<String>
        let checkSamePW: BehaviorSubject<Bool>
        let repwDescription: BehaviorSubject<String>
    }
    
    func transform(input: Input) -> Output {
        
        let emailDescription: BehaviorSubject<String> = BehaviorSubject(value: "")
        let checkEmailRegex: BehaviorSubject<Bool> = BehaviorSubject(value: false)
        let emailValidation: BehaviorSubject<Bool> = BehaviorSubject(value: false)
        
        let pwDescription: BehaviorSubject<String> = BehaviorSubject(value: "")
        let checkPWRegex: BehaviorSubject<Bool> = BehaviorSubject(value: false)
        
        let checkSamePW: BehaviorSubject<Bool> = BehaviorSubject(value: false)
        let repwDescription: BehaviorSubject<String> = BehaviorSubject(value: "")

        // MARK: 이메일 정규표현식 검증
        input.emailText
            .asObservable()
            .map { $0.range(of: self.emailRegEx, options: .regularExpression) != nil }
            .subscribe(with: self) { owner, bool in
                checkEmailRegex.onNext(bool)
            }
            .disposed(by: disposeBag)
        
        checkEmailRegex
            .filter { $0 == false }
            .subscribe(with: self) { owner, value in
                let text = "올바른 이메일을 입력해주세요"
                emailValidation.onNext(false)
                emailDescription.onNext(text)
            }
            .disposed(by: disposeBag)
        
        // MARK: 이메일 중복 검증
        /// 이메일 정규표현식 검증이 끝난 후에 중복 검증
        
        input.emailText
            .asObservable()
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(checkEmailRegex, resultSelector: { text, bool in
                if bool {
                    return text
                } else {
                    return ""
                }
            })
            .filter { !$0.isEmpty }
            .flatMapLatest {
                APIManager.shared.fetchEmailValidation(email: $0)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success:
                    emailValidation.onNext(true)
                    emailDescription.onNext("사용 가능한 이메일입니다.")
                case .failure(let error):
                    // TODO: 예외처리하기
                    emailValidation.onNext(false)
                    emailDescription.onNext("이미 가입한 이메일입니다.")
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        // MARK: 비밀번호 정규식 검증
        input.pwText
            .asObservable()
            .map { $0.range(of: self.pwRegEx, options: .regularExpression) != nil }
            .bind(to: checkPWRegex)
            .disposed(by: disposeBag)
        
        checkPWRegex
            .bind(with: self) { owner, value in
                let text = value ? "" : JoinViewType.password.description
                pwDescription.onNext(text)
            }
            .disposed(by: disposeBag)

        // MARK: 비밀번호 재입력 비교검증
        Observable.combineLatest(input.pwText, input.repwText)
            .map { $0 == $1 }
            .bind(to: checkSamePW)
            .disposed(by: disposeBag)
        
        checkSamePW
            .bind(with: self) { owner, value in
                let text = value ? "비밀번호가 일치합니다." : JoinViewType.repassword.description
                repwDescription.onNext(text)
            }
            .disposed(by: disposeBag)
        

        return Output(emailValidation: emailValidation, emailDescription: emailDescription, checkPWRegex: checkPWRegex, pwDescription: pwDescription, checkSamePW: checkSamePW, repwDescription: repwDescription)
        
    }
    
}
