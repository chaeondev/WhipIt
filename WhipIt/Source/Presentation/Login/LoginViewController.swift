//
//  LoginViewController.swift
//  WhipIt
//
//  Created by Chaewon on 11/16/23.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: BaseViewController {
    
    private lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        view.image = .whipIt
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var emailView: JoinView = JoinView(type: .email)
    private lazy var passwordView: JoinView = JoinView(type: .password)
    private lazy var loginButton: UIButton = BlackBackgroundRoundedButton(title: "로그인")
    private lazy var segmentedControl = {
        let view = UISegmentedControl(items: ["이메일 가입", "이메일 찾기", "비밀번호 찾기"])
        let font = Font.light14
        view.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        view.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        view.selectedSegmentIndex = -1 // default값을 no selection으로 지정
        return view
    }()
    
    let disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        segmentedControl.selectedSegmentIndex = -1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        
    }

    func bind() {
        segmentedControl.rx.selectedSegmentIndex
            .bind(with: self) { owner, index in
                switch index {
                case 0:
                    owner.navigationController?.pushViewController(SignUpViewController(), animated: true)
                default:
                    print("default")
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    
    override func setHierarchy() {
        super.setHierarchy()
        
        view.addSubview(logoImageView)
        view.addSubview(emailView)
        view.addSubview(passwordView)
        view.addSubview(loginButton)
        view.addSubview(segmentedControl)
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.centerX.equalToSuperview().multipliedBy(0.95)
            make.height.equalTo(100)
            make.width.equalTo(200)
        }
        
        emailView.titleLabel.text = "이메일 주소"
        emailView.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(60)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(65)
        }
        
        passwordView.titleLabel.text = "비밀번호"
        passwordView.snp.makeConstraints { make in
            make.top.equalTo(emailView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(65)
        }

        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordView.snp.bottom).offset(40)
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
