//
//  SignUpViewController.swift
//  WhipIt
//
//  Created by Chaewon on 11/19/23.
//

import UIKit
import RxSwift
import RxCocoa

class SignUpViewController: BaseViewController {
    
    private lazy var emailView = JoinView(type: .email)
    private lazy var passwordView = JoinView(type: .password)
    private lazy var repasswordView = JoinView(type: .repassword)
    private lazy var phoneNumView = JoinView(type: .phoneNum)
    private lazy var signupButton = {
        let view = UIButton.buttonBuilder(title: "회원가입", font: Font.bold16)
        view.backgroundColor = .black
        view.setTitleColor(.white, for: .normal)
        view.layer.cornerRadius = 10
        return view
    }()
    
    let disposeBag = DisposeBag()
    
    let viewModel = SignUpViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()

        bind()
    }
    
    func bind() {
        let input = SignUpViewModel.Input(
            emailText: emailView.textField.rx.text.orEmpty,
            pwText: passwordView.textField.rx.text.orEmpty,
            repwText: repasswordView.textField.rx.text.orEmpty,
            phoneText: phoneNumView.textField.rx.text.orEmpty,
            tap: signupButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        
        // 이메일
        checkTextFieldValidation(joinView: emailView, check: output.emailValidation, descript: output.emailDescription)
  
        
        // 비밀번호
        passwordView.textField.isSecureTextEntry = true
        checkTextFieldValidation(joinView: passwordView, check: output.checkPWRegex, descript: output.pwDescription)
        
        // 비밀번호 재입력
        repasswordView.textField.isSecureTextEntry = true
        checkTextFieldValidation(joinView: repasswordView, check: output.checkSamePW, descript: output.repwDescription)
        
        // 핸드폰 번호
        
        
    }
    
    private func checkTextFieldValidation(joinView: JoinView, check: BehaviorSubject<Bool>, descript: BehaviorSubject<String>) {
        Observable.combineLatest(joinView.textField.rx.controlEvent(.editingDidBegin), check) { return $1 }
            .bind(with: self) { owner, value in
                joinView.descriptionLabel.isHidden = false
                
                let color: UIColor = value ? .blue : .red
                joinView.descriptionLabel.textColor = color
                joinView.textField.underlineView.backgroundColor = color
            }
            .disposed(by: disposeBag)
        
        descript
            .bind(to: joinView.descriptionLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    
    private func setNavigationBar() {
        title = "회원가입"
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.font : Font.extraBold34
        ]
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        view.addSubview(emailView)
        view.addSubview(passwordView)
        view.addSubview(repasswordView)
        view.addSubview(phoneNumView)
        view.addSubview(signupButton)
    }
    
    override func setConstraints() {
        super.setConstraints()
//        emailView.backgroundColor = .blue
        emailView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(90)
        }
        
        passwordView.snp.makeConstraints { make in
            make.top.equalTo(emailView.snp.bottom).offset(24)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(90)
        }
//        repasswordView.backgroundColor = .blue
        repasswordView.snp.makeConstraints { make in
            make.top.equalTo(passwordView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(70)
        }
        phoneNumView.snp.makeConstraints { make in
            make.top.equalTo(repasswordView.snp.bottom).offset(24)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(90)
        }
        
        signupButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(50)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
}
