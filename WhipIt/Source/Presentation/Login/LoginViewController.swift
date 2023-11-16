//
//  LoginViewController.swift
//  WhipIt
//
//  Created by Chaewon on 11/16/23.
//

import UIKit

class LoginViewController: BaseViewController {
    
    private lazy var emailLabel = UILabel.labelBuilder(text: "이메일 주소", font: .boldSystemFont(ofSize: 14), textColor: .black)
    private lazy var emailTextField = UITextField.underlineTextFieldBuilder(placeholder: "예) whipit@whipit.co.kr", textColor: .black, textAlignment: .natural)
    private lazy var passwordLabel = UILabel.labelBuilder(text: "비밀번호", font: .boldSystemFont(ofSize: 14), textColor: .black)
    private lazy var passwordTextField = UITextField.underlineTextFieldBuilder(placeholder: "비밀번호를 입력해주세요", textColor: .black, textAlignment: .natural)
    private lazy var loginButton = {
        let view = UIButton.buttonBuilder(title: "로그인", font: .boldSystemFont(ofSize: 16))
        view.backgroundColor = .black
        view.setTitleColor(.white, for: .normal)
        view.layer.cornerRadius = 10
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.leading.equalToSuperview().offset(16)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(16)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(50)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
    }
}
