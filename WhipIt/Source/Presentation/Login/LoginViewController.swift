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
    
    let viewModel = LoginViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        segmentedControl.selectedSegmentIndex = -1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        
    }

    private func bind() {
        
        let input = LoginViewModel.Input(
            emailText: emailView.textField.rx.text.orEmpty,
            pwText: passwordView.textField.rx.text.orEmpty,
            loginButtonTap: loginButton.rx.tap
        )
        
        let output = viewModel.transform(input: input)
        
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
        
        // 이메일
        emailView.textField.textContentType = .emailAddress
        emailView.textField.keyboardType = .emailAddress
        checkTextFieldValidation(joinView: emailView, check: output.checkEmailRegex, descript: output.emailDescription)
  
        
        // 비밀번호
        passwordView.textField.textContentType = .newPassword
        passwordView.textField.isSecureTextEntry = true
        checkTextFieldValidation(joinView: passwordView, check: output.checkPWRegex, descript: output.pwDescription)
        
        // 회원가입 버튼 enable 여부
        output.buttonValidation
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.buttonValidation
            .bind(with: self) { owner, bool in
                owner.loginButton.backgroundColor = bool ? .black : .gray
            }
            .disposed(by: disposeBag)
        
        //로그인 네트워크 분기처리
        output.loginResponse
            .bind(with: self) { owner, result in
                switch result {
                case .success:
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(owner.setTabBarController())
                case .failure(let error):
                    var message: String {
                        switch error {
                        case .wrongRequest:
                            return "이메일 또는 비밀번호를 입력해주세요"
                        case .unAuthorized:
                            return "가입되지 않은 계정입니다. 이메일 또는 비밀번호를 다시 확인해주세요"
                        default:
                            return "네트워크 오류로 로그인이 진행되지 않았습니다. 다시 한 번 시도해주세요"
                        }
                    }
                    
                    owner.showAlertMessage(title: "로그인 오류", message: message)
                }
            }
            .disposed(by: disposeBag)

        
    }
    
    func setTabBarController() -> UITabBarController {
        let tabBar = UITabBarController()
        
        let styleVC = UINavigationController(rootViewController: StyleListViewController())
        styleVC.tabBarItem = UITabBarItem(title: "STYLE", image: UIImage(systemName: "heart.text.square"), selectedImage: UIImage(systemName: "heart.text.square.fill"))
        let bookmarkVC = UINavigationController(rootViewController: BookMarkViewController())
        bookmarkVC.tabBarItem = UITabBarItem(title: "SAVED", image: UIImage(systemName: "bookmark"), selectedImage: UIImage(systemName: "bookmark.fill"))
        let accountVC = MyAccountViewController()
        accountVC.accountType = .me
        accountVC.userID = KeyChainManager.shared.userID
        let accountNav = UINavigationController(rootViewController: accountVC)
        accountNav.tabBarItem = UITabBarItem(title: "MY", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
        
        tabBar.viewControllers = [styleVC, bookmarkVC, accountNav]
        tabBar.tabBar.tintColor = .black
        
        return tabBar
    }
    
    private func checkTextFieldValidation(joinView: JoinView, check: BehaviorSubject<Bool>, descript: BehaviorSubject<String>) {
        Observable.combineLatest(joinView.textField.rx.controlEvent(.editingDidEnd), check) { return $1 }
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
            make.top.equalTo(logoImageView.snp.bottom).offset(50)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(70)
        }
        
        passwordView.titleLabel.text = "비밀번호"
        passwordView.snp.makeConstraints { make in
            make.top.equalTo(emailView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(70)
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
