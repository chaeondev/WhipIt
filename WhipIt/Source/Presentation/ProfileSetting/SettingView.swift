//
//  SettingView.swift
//  WhipIt
//
//  Created by Chaewon on 12/17/23.
//

import UIKit

enum SettingViewType {
    case emailID
    case nickname
    case phoneNum
    
    var title: String {
        switch self {
        case .emailID: "프로필 이름"
        case .nickname: "닉네임"
        case .phoneNum: "휴대폰 번호"
        }
    }
}


final class SettingView: UIView {
    
    let titleLabel = UILabel.labelBuilder(text: "닉네임", font: Font.bold14, textColor: .black)
    let contentLabel = UILabel.labelBuilder(text: "위핏이888", font: Font.light14, textColor: .black)
    let editButton = {
        let view = UIButton.buttonBuilder(title: "변경", font: UIFont(name: Suit.medium, size: 12)!, titleColor: .black)
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()
    let borderline = UIView.barViewBuilder(color: .systemGray5)
    
    init(type: SettingViewType) {
        super.init(frame: .zero)
        
        titleLabel.text = type.title
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        [titleLabel, contentLabel, editButton, borderline].forEach { self.addSubview($0) }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
        }
        editButton.snp.makeConstraints { make in
            make.centerY.equalTo(contentLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(35)
            make.height.equalTo(25)
        }
        borderline.snp.makeConstraints { make in
            make.top.equalTo(editButton.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
    }
}
