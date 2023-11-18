//
//  LoginViewController.swift
//  WhipIt
//
//  Created by Chaewon on 11/16/23.
//

import UIKit
import RxSwift

class LoginViewController: BaseViewController {
    
    private lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        view.image = .whipIt
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var emailLabel = UILabel.labelBuilder(text: "이메일 주소", font: Font.bold14, textColor: .black)
    private lazy var emailTextField = UITextField.underlineTextFieldBuilder(placeholder: "예) whipit@whipit.co.kr", textColor: .black, textAlignment: .natural)
    private lazy var passwordLabel = UILabel.labelBuilder(text: "비밀번호", font: Font.bold14, textColor: .black)
    private lazy var passwordTextField = UITextField.underlineTextFieldBuilder(placeholder: "비밀번호를 입력해주세요", textColor: .black, textAlignment: .natural)
    private lazy var loginButton = {
        let view = UIButton.buttonBuilder(title: "로그인", font: Font.bold16)
        view.backgroundColor = .black
        view.setTitleColor(.white, for: .normal)
        view.layer.cornerRadius = 10
        return view
    }()
    private lazy var segmentedControl = {
        let view = UISegmentedControl(items: ["이메일 가입", "이메일 찾기", "비밀번호 찾기"])
        let font = Font.light14
        view.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        view.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        view.selectedSegmentIndex = -1 // default값을 no selection으로 지정
        return view
    }()
    
    let sample = SignUpRequest(email: "djs@apple.com", password: "12345", nick: "Danna")
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let a = APIManager.shared.signUp(model: sample)
//        a.subscribe {
//            print("single result", $0)
//        }
//        .disposed(by: disposeBag)
        
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        
        view.addSubview(logoImageView)
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordLabel)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(segmentedControl)
    }
    
    override func setConstraints() {
        super.setConstraints()
//        logoImageView.backgroundColor = .blue
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview().multipliedBy(0.95)
            make.height.equalTo(100)
            make.width.equalTo(200)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(60)
            make.leading.equalToSuperview().offset(20)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(32)
            make.leading.equalToSuperview().offset(20)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(50)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(32)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }
    }
}
