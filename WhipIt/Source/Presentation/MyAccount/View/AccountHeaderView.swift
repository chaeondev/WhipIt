//
//  AccountHeaderView.swift
//  WhipIt
//
//  Created by Chaewon on 12/14/23.
//

import UIKit

final class AccountHeaderView: UICollectionReusableView {
    
    let postCntLabel = UILabel.labelBuilder(text: "5", font: UIFont(name: Suit.extraBold, size: 16)!, textColor: .black)
    let postLabel = UILabel.labelBuilder(text: "게시물", font: UIFont(name: Suit.light, size: 14)!, textColor: .black)
    
    let bookmarkCntLabel = UILabel.labelBuilder(text: "23", font: UIFont(name: Suit.extraBold, size: 16)!, textColor: .black)
    let bookmarkLabel = UILabel.labelBuilder(text: "관심 스타일", font: UIFont(name: Suit.light, size: 14)!, textColor: .black)
    let bookmarkButton = UIButton()
    
    let borderView = UIView.barViewBuilder(color: .systemGray4)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setHierarchy()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(postCnt: Int, bookCnt: Int) {
        postCntLabel.text = "\(postCnt)"
        bookmarkCntLabel.text = "\(bookCnt)"
    }
    
    func remakeConstraints(accountType: AccountType) {
        if accountType == .user {
            postCntLabel.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.centerX.equalToSuperview()
            }
            postLabel.snp.remakeConstraints { make in
                make.top.equalTo(postCntLabel.snp.bottom).offset(4)
                make.centerX.equalTo(postCntLabel)
            }
            
            [bookmarkCntLabel, bookmarkLabel, bookmarkButton].forEach { $0.isHidden = true }
        }
    }
    
    func setHierarchy() {
        [postCntLabel, postLabel, bookmarkCntLabel, bookmarkLabel, bookmarkButton, borderView].forEach { self.addSubview($0) }
    }
    
    func setConstraints() {
        self.backgroundColor = .white

        postCntLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview().multipliedBy(0.5)
        }
        postLabel.snp.makeConstraints { make in
            make.top.equalTo(postCntLabel.snp.bottom).offset(4)
            make.centerX.equalTo(postCntLabel)
        }
        
        bookmarkCntLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview().multipliedBy(1.5)
        }
        bookmarkLabel.snp.makeConstraints { make in
            make.top.equalTo(bookmarkCntLabel.snp.bottom).offset(4)
            make.centerX.equalTo(bookmarkCntLabel)
        }

        bookmarkButton.snp.makeConstraints { make in
            make.top.equalTo(bookmarkCntLabel)
            make.centerX.equalTo(bookmarkCntLabel)
            make.width.equalTo(bookmarkLabel)
            make.bottom.equalTo(bookmarkLabel)
        }
        
        borderView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
}
