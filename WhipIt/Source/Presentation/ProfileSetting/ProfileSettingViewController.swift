//
//  ProfileSettingViewController.swift
//  WhipIt
//
//  Created by Chaewon on 12/17/23.
//

import UIKit

final class ProfileSettingViewController: BaseViewController {
    
    private lazy var profileImageView = {
        let view = RoundImageView(frame: .zero)
        view.backgroundColor = .systemGray5
        view.image = UIImage(systemName: "star")
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var imageEditButton = UIButton.buttonBuilder(title: "프로필 사진 수정", font: UIFont(name: Suit.medium, size: 14)!, titleColor: .systemBlue)

    
    private lazy var profileButton = UIButton()
    
    private lazy var profileInfoLabel = UILabel.labelBuilder(text: "프로필 정보", font: UIFont(name: Suit.bold, size: 20)!, textColor: .black)
    private lazy var emailView = SettingView(type: .emailID)
    private lazy var nicknameView = SettingView(type: .nickname)
    private lazy var phoneView = SettingView(type: .phoneNum)
    
    private lazy var logoutButton = {
        let view = UIButton.buttonBuilder(title: "로그아웃", font: UIFont(name: Suit.medium, size: 14), titleColor: .systemRed)
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    private lazy var withdrawButton = {
        let view = UIButton.buttonBuilder(title: "회원탈퇴", font: UIFont(name: Suit.medium, size: 14), titleColor: .darkGray)
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    var profile: GetMyProfileResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    private func configureView() {
        guard let profile else { return }
        profileImageView.setKFImage(imageUrl: profile.profile ?? "")
        emailView.contentLabel.text = profile.email
        nicknameView.contentLabel.text = profile.nick
        phoneView.contentLabel.text = profile.phoneNum
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        [profileImageView, imageEditButton, profileButton, profileInfoLabel, emailView, nicknameView, phoneView, logoutButton, withdrawButton].forEach { view.addSubview($0) }
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.centerX.equalToSuperview()
            make.size.equalTo(80)
        }
        
        imageEditButton.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        //profileButton.backgroundColor = .black.withAlphaComponent(0.5)
        profileButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.bottom.equalTo(imageEditButton)
            make.centerX.equalToSuperview()
            make.width.equalTo(imageEditButton)
        }
        
        profileInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(profileButton.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
        }
        //emailView.backgroundColor = .blue.withAlphaComponent(0.5)
        emailView.snp.makeConstraints { make in
            make.top.equalTo(profileInfoLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(90)
        }
        
        nicknameView.snp.makeConstraints { make in
            make.top.equalTo(emailView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(90)
        }
        
        phoneView.snp.makeConstraints { make in
            make.top.equalTo(nicknameView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(90)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(phoneView.snp.bottom).offset(30)
            make.centerX.equalToSuperview().multipliedBy(0.5)
            make.width.equalTo(180)
            make.height.equalTo(35)
        }
        
        withdrawButton.snp.makeConstraints { make in
            make.top.equalTo(phoneView.snp.bottom).offset(30)
            make.centerX.equalToSuperview().multipliedBy(1.5)
            make.width.equalTo(180)
            make.height.equalTo(35)
        }
    }
}
