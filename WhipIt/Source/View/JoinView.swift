//
//  JoinView.swift
//  WhipIt
//
//  Created by Chaewon on 11/19/23.
//

import UIKit
import SnapKit

enum JoinViewType {
    case email
    case password
    case repassword
    case phoneNum
    
    var title: String {
        switch self {
        case .email:
            "이메일 주소＊"
        case .password:
            "비밀번호＊"
        case .repassword:
            ""
        case .phoneNum:
            "핸드폰 번호 (옵션)"
        }
    }
    
    var placeholder: String {
        switch self {
        case .email:
            "예) whipit@whipit.co.kr"
        case .password:
            "비밀번호를 입력해주세요"
        case .repassword:
            "비밀번호 재입력"
        case .phoneNum:
            "예) 010-1234-5678"
        }
    }
    
    var description: String {
        switch self {
        case .email:
            "올바른 이메일을 입력해주세요"
        case .password:
            "영문, 숫자를 포함하여 입력해주세요. (6-16자)"
        case .repassword:
            "재입력 비밀번호가 일치하지 않습니다."
        case .phoneNum:
            "미입력시 아이디를 까먹었을 때 찾을 수 없어요!"
        }
    }
}

class JoinView: UIView {
    
    lazy var titleLabel: UILabel = UILabel.labelBuilder(text: "이메일 주소 (필수)", font: Font.bold14, textColor: .black)
    
    lazy var textField: UnderlineTextField = UITextField.underlineTextFieldBuilder(placeholder: "예) whipit@whipit.co.kr", textColor: .black, textAlignment: .natural)
    
    lazy var descriptionLabel: UILabel = UILabel.labelBuilder(text: "사용 가능한 이메일입니다.", font: Font.light12, textColor: .black)
    
    init(type: JoinViewType) {
        super.init(frame: .zero)
        
        titleLabel.text = type.title
        textField.setPlaceholder(placeholder: type.placeholder)
        descriptionLabel.text = type.description
        
        descriptionLabel.isHidden = true
        
        configureView()
    }
    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        [titleLabel, textField, descriptionLabel].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
    }
}
