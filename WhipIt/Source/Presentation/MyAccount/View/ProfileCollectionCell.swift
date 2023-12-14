//
//  ProfileCollectionCell.swift
//  WhipIt
//
//  Created by Chaewon on 12/14/23.
//

import UIKit

final class ProfileCollectionCell: BaseCollectionViewCell {
    
    let profileImageView = {
        let view = RoundImageView(frame: .zero)
        view.image = UIImage(systemName: "star")
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .systemGray5
        return view
    }()
    
    let userNameLabel = UILabel.labelBuilder(text: "위핏이888", font: UIFont(name: Suit.bold, size: 20)!, textColor: .black, numberOfLines: 1)
    
    let followerButton = UIButton.buttonBuilder(title: "팔로워 728", font: UIFont(name: Suit.medium, size: 14)!, titleColor: .black)
    let borderView = UIView.barViewBuilder(color: .systemGray4)
    let followingButton = UIButton.buttonBuilder(title: "팔로잉 16", font: UIFont(name: Suit.medium, size: 14)!, titleColor: .black)
    
    let profileSettingButton = {
        let view = UIButton.buttonBuilder(title: "프로필 관리", font: UIFont(name: Suit.light, size: 14)!, titleColor: .black)
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    let followButton = {
        let view = UIButton.buttonBuilder(title: "팔로우", font: UIFont(name: Suit.light, size: 14)!, titleColor: .black)
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    let profileShareButton = {
        let view = UIButton.buttonBuilder(title: "프로필 공유", font: UIFont(name: Suit.light, size: 14)!, titleColor: .black)
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    
    let separatorView = UIView.barViewBuilder(color: .systemGray6)
    
    override func setHierarchy() {
        [profileImageView, userNameLabel, followerButton, borderView, followingButton, profileSettingButton, followButton, profileShareButton, separatorView].forEach { self.addSubview($0) }
    }
    
    override func setConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(90)
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView).offset(20)
            make.leading.equalTo(profileImageView.snp.trailing).offset(16)
            make.trailing.lessThanOrEqualToSuperview().inset(20)
        }
        
        followerButton.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom)
            make.leading.equalTo(userNameLabel)
        }
        
        borderView.snp.makeConstraints { make in
            make.top.equalTo(followerButton).offset(8)
            make.bottom.equalTo(followerButton).offset(-8)
            make.leading.equalTo(followerButton.snp.trailing).offset(8)
            make.width.equalTo(1)
        }
        
        followingButton.snp.makeConstraints { make in
            make.top.equalTo(followerButton)
            make.leading.equalTo(borderView.snp.trailing).offset(8)
        }
        
        profileSettingButton.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(24)
            make.leading.equalTo(profileImageView)
            make.width.equalTo(180)
            make.height.equalTo(35)
        }
        
        followButton.isHidden = true
        followButton.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(24)
            make.leading.equalTo(profileImageView)
            make.width.equalTo(170)
            make.height.equalTo(35)
        }
        
        profileShareButton.snp.makeConstraints { make in
            make.top.equalTo(profileSettingButton)
            make.trailing.equalToSuperview().inset(16)
            make.width.equalTo(170)
            make.height.equalTo(35)
        }
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(profileShareButton.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(6)
        }
    }
    
}
