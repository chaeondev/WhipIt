//
//  ContentCell.swift
//  WhipIt
//
//  Created by Chaewon on 12/7/23.
//

import UIKit

final class ContentCell: BaseCollectionViewCell {
    let profileImageView = {
        let view = RoundImageView(frame: .zero)
        view.image = UIImage(systemName: "star")
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .blue
        return view
    }()
    let userNameLabel = UILabel.labelBuilder(text: "everywear", font: UIFont(name: Suit.bold, size: 12)!, textColor: .black, numberOfLines: 1)
    let dateLabel = UILabel.labelBuilder(text: "23년 11월 29일", font: UIFont(name: Suit.light, size: 10)!, textColor: .gray, numberOfLines: 1)
    let headerView = UIView()
    let headerButton = UIButton()
    let followButton = {
        let view = BlackBackgroundRoundedButton(title: "팔로우")
        view.titleLabel?.font = UIFont(name: Suit.semiBold, size: 12)!
        return view
    }()
    let menuButton = UIButton.buttonBuilder(image: UIImage(systemName: "ellipsis"))
    
    let styleImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .cyan
        return view
    }()
    
    override func setHierarchy() {
        super.setHierarchy()
        [profileImageView, userNameLabel, dateLabel].forEach { headerView.addSubview($0) }
        [headerView, headerButton, followButton, menuButton, styleImageView].forEach { contentView.addSubview($0) }
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        profileImageView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(8)
            make.leading.equalToSuperview().offset(16)
            make.width.equalTo(profileImageView.snp.height)
        }
        //userNameLabel.backgroundColor = .blue
        userNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().inset(8)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(2)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
        }
        //headerView.backgroundColor = .lightGray
        headerView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalToSuperview().multipliedBy(0.65)
        }
        
        headerButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.height.width.equalTo(headerView)
        }
        
        followButton.snp.makeConstraints { make in
            make.centerY.equalTo(headerView)
            make.leading.equalTo(headerView.snp.trailing).offset(8)
            make.width.equalTo(75)
            make.height.equalTo(headerView).multipliedBy(0.58)
        }
        
        menuButton.snp.makeConstraints { make in
            make.centerY.equalTo(headerView)
            make.leading.equalTo(followButton.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.height.equalTo(headerView).multipliedBy(0.85)
        }
        
        styleImageView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.greaterThanOrEqualTo(100)
        }
    }
}
