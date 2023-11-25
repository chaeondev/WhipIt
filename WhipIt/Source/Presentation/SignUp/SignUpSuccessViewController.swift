//
//  SignUpSuccessViewController.swift
//  WhipIt
//
//  Created by Chaewon on 11/25/23.
//

import UIKit
import RxSwift
import RxCocoa

class SignUpSuccessViewController: BaseViewController {
    
    private lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        view.image = .whipIt
        view.contentMode = .scaleAspectFit
        return view
    }()
    private lazy var successLabel = UILabel.labelBuilder(text: "회원가입이 완료되었습니다", font: Font.bold24, textColor: .black)
    private lazy var descriptionLabel = UILabel.labelBuilder(text: "로그인을 통해 WhipIt의 다양한 경험을 함께해주세요!", font: Font.bold16, textColor: .gray)
    private lazy var loginButton: UIButton = BlackBackgroundRoundedButton(title: "로그인")

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        bind()
    }
    
    private func bind() {
        loginButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.popToRootViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func setNavigationBar() {
        navigationItem.hidesBackButton = true
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        [logoImageView, successLabel, descriptionLabel, loginButton]
            .forEach { view.addSubview($0) }
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(100)
            make.width.equalTo(200)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(100)
        }
        successLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(successLabel.snp.bottom).offset(16)
        }
        loginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(50)
        }
    }
}
