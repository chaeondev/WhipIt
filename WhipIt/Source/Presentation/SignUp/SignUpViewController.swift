//
//  SignUpViewController.swift
//  WhipIt
//
//  Created by Chaewon on 11/19/23.
//

import UIKit



class SignUpViewController: BaseViewController {
    
    private lazy var emailView = JoinView(type: .email(validation: false))
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "회원가입"
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.font : Font.extraBold34
        ]
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
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
