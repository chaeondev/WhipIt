//
//  EditProfileViewController.swift
//  WhipIt
//
//  Created by Chaewon on 12/19/23.
//

import UIKit
import RxSwift
import RxCocoa

enum EditProfileType {
    case nickname, phone
}

final class EditProfileViewController: BaseViewController {
    
    private lazy var titleLabel = UILabel.labelBuilder(text: "닉네임", font: Font.bold14, textColor: .black)
    private lazy var contentTextField = UITextField.textFieldBuilder(placeholder: "이름 또는 별명", textColor: .black, font: Font.light14)
    private lazy var borderView = UIView.barViewBuilder(color: .black)
    private lazy var wordCntLabel = UILabel.labelBuilder(text: "0/25", font: UIFont(name: Suit.light, size: 12)!, textColor: .gray)
    private lazy var saveButton = BlackBackgroundRoundedButton(title: "저장하기")
    
    var editType: EditProfileType = .nickname
    var profileInfo: GetMyProfileResponse!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationbar()
        configureView()
    }
    
    func bind() {
        
    }
    
    func configureView() {
        switch editType {
        case .nickname:
            contentTextField.text = profileInfo.nick
            wordCntLabel.isHidden = false
        case .phone:
            contentTextField.text = profileInfo.phoneNum
            wordCntLabel.isHidden = true
        }
    }
    
    func setNavigationbar() {
        switch editType {
        case .nickname:
            title = "닉네임 변경"
        case .phone:
            title = "휴대폰 번호 변경"
        }
        let style = UINavigationBarAppearance()
        style.buttonAppearance.normal.titleTextAttributes = [.font: UIFont(name: Suit.bold, size: 15)!]
        navigationController?.navigationBar.standardAppearance = style
        
        let cancelButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: nil)
        cancelButton.tintColor = .black
        navigationItem.rightBarButtonItem = cancelButton
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        [titleLabel, contentTextField, borderView, wordCntLabel, saveButton].forEach { view.addSubview($0) }
    }
    
    override func setConstraints() {
        super.setConstraints()
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        
        contentTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        borderView.snp.makeConstraints { make in
            make.top.equalTo(contentTextField.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        wordCntLabel.snp.makeConstraints { make in
            make.top.equalTo(borderView.snp.bottom).offset(4)
            make.trailing.equalTo(borderView)
        }
        
        saveButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(50)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }
}
