//
//  LoginViewModel.swift
//  WhipIt
//
//  Created by Chaewon on 11/19/23.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel: ViewModelType {
    
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let pwRegEx = "^(?=.*[a-zA-Z])(?=.*[0-9]).{6,16}$"
    
    let disposeBag = DisposeBag()
    
    struct Input {
        let emailText: ControlProperty<String>
        let pwText: ControlProperty<String>
        let loginButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let checkEmailRegex: BehaviorSubject<Bool>
        let emailDescription: BehaviorSubject<String>
        let checkPWRegex: BehaviorSubject<Bool>
        let pwDescription: BehaviorSubject<String>
        let buttonValidation: BehaviorSubject<Bool>
        let loginResponse: PublishSubject<NetworkResult<String>>
    }
    
    func transform(input: Input) -> Output {
        
        let emailDescription: BehaviorSubject<String> = BehaviorSubject(value: "")
        let checkEmailRegex: BehaviorSubject<Bool> = BehaviorSubject(value: false)
        let pwDescription: BehaviorSubject<String> = BehaviorSubject(value: "")
        let checkPWRegex: BehaviorSubject<Bool> = BehaviorSubject(value: false)
        let buttonValidation: BehaviorSubject<Bool> = BehaviorSubject(value: false)
        let loginResponse = PublishSubject<NetworkResult<String>>()
        
        // MARK: 이메일 정규식 검증
        input.emailText
            .asObservable()
            .map { $0.range(of: self.emailRegEx, options: .regularExpression) != nil }
            .bind(to: checkEmailRegex)
            .disposed(by: disposeBag)
        
        checkEmailRegex
            .bind(with: self) { owner, value in
                let text = value ? "" : JoinViewType.email.description
                emailDescription.onNext(text)
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
        
        // MARK: 로그인 버튼 enable 여부
        Observable.combineLatest(checkEmailRegex, checkPWRegex)
            .map { $0 && $1 }
            .bind(to: buttonValidation)
            .disposed(by: disposeBag)
        
        // MARK: 로그인 네트워크
        
        let loginRequest = Observable.combineLatest(
            input.emailText,
            input.pwText,
            buttonValidation
        )
            .share()
            .filter { $0.2 }
            .map { email, password, validation in
                return LoginRequest(email: email, password: password)
            }
        
        input.loginButtonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(loginRequest) { _, request in
                return request
            }
            .flatMapLatest {
                APIManager.shared.requestLogin(model: $0)
            }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    KeyChainManager.shared.create(account: .accessToken, value: response.token)
                    KeyChainManager.shared.create(account: .refreshToken, value: response.refreshToken)
                    KeyChainManager.shared.create(account: .userID, value: response._id)
                    UserDefaultsManager.isLogin = true
                    loginResponse.onNext(.success("Login Success"))
                case .failure(let error):
                    loginResponse.onNext(.failure(error))
                }
            }
            .disposed(by: disposeBag)
        
        return Output(checkEmailRegex: checkEmailRegex, emailDescription: emailDescription, checkPWRegex: checkPWRegex, pwDescription: pwDescription, buttonValidation: buttonValidation, loginResponse: loginResponse)
    }
}
