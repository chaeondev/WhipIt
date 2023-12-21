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

protocol EditDelegate: AnyObject {
    func updateProfile(info: GetProfileResponse)
}

final class EditProfileViewController: BaseViewController {
    
    private lazy var titleLabel = UILabel.labelBuilder(text: "닉네임", font: Font.bold14, textColor: .black)
    private lazy var contentTextField = UITextField.textFieldBuilder(placeholder: "이름 또는 별명", textColor: .black, font: Font.light14)
    private lazy var borderView = UIView.barViewBuilder(color: .black)
    private lazy var wordCntLabel = UILabel.labelBuilder(text: "0/25", font: UIFont(name: Suit.light, size: 12)!, textColor: .gray)
    private lazy var saveButton = BlackBackgroundRoundedButton(title: "저장하기")
    
    var editType: EditProfileType = .nickname
    var profileInfo: GetProfileResponse!
    
    var delegate: EditDelegate?
    
    private let viewModel = EditProfileViewModel()
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationbar()
        configureView()
        bind()
    }
    
    private func bind() {
        let input = EditProfileViewModel.Input(
            editType: self.editType,
            contentText: contentTextField.rx.text.orEmpty,
            saveButtonTap: saveButton.rx.tap
        )
        let output = viewModel.transform(input: input)
        
        output.content
            .bind(to: contentTextField.rx.text)
            .disposed(by: disposeBag)
        
        output.content
            .bind(with: self) { owner, text in
                owner.wordCntLabel.text = "\(text.count)/25"
            }
            .disposed(by: disposeBag)
        
        output.contentValidation
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.contentValidation
            .bind(with: self) { owner, bool in
                owner.saveButton.backgroundColor = bool ? .black : .gray
            }
            .disposed(by: disposeBag)
        
        output.editResponse
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let response):
                    owner.delegate?.updateProfile(info: response)
                    owner.dismiss(animated: true)
                case .failure(let error):
                    print("======프로필 수정 에러=====", error)
                    owner.dismiss(animated: true)
                    let message = "네트워크 서버 장애로 프로필이 수정되지 않았습니다. 다시 시도해주세요"
                    owner.showAlertMessage(title: "프로필 수정 오류", message: message)
                }
            }
            .disposed(by: disposeBag)
        
        navigationItem.rightBarButtonItem!.rx.tap
            .bind(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
    }
    
    private func configureView() {
        switch editType {
        case .nickname:
            titleLabel.text = "닉네임"
            contentTextField.placeholder = "이름 또는 별명"
            contentTextField.text = profileInfo.nick
            wordCntLabel.isHidden = false
        case .phone:
            titleLabel.text = "휴대폰 번호"
            contentTextField.placeholder = "예) 010-1234-5678"
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
