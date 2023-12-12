//
//  InfoCell.swift
//  WhipIt
//
//  Created by Chaewon on 12/7/23.
//

import UIKit

final class InfoCell: BaseCollectionViewCell {
    let commentButton = {
        let view = UIButton()
        view.tintColor = .black
        let image = UIImage(resource: .bubble)
        view.setImage(image, for: .normal)
        return view
    }()
    let bookmarkButton = {
        let view = UIButton()
        view.tintColor = .black
        let image = UIImage(resource: .ribbon)
        view.setImage(image, for: .normal)
        return view
    }()
    let commentCntLabel = UILabel.labelBuilder(text: "댓글 2개", font: UIFont(name: Suit.semiBold, size: 14)!, textColor: .black)
    let bookmarkCntLabel = UILabel.labelBuilder(text: "북마크 27개", font: UIFont(name: Suit.semiBold, size: 14)!, textColor: .black)
    let contentLabel = UILabel.labelBuilder(text: "오늘의 OOTD \n#오오티디 #라이징슈즈 #요즘아우터 #오뭐압", font: UIFont(name: Suit.light, size: 15)!, textColor: .black, numberOfLines: 0)
    let separatorView = UIView.barViewBuilder(color: .lightGray)
    
    override func setHierarchy() {
        super.setHierarchy()
        
        [commentButton, bookmarkButton, commentCntLabel, bookmarkCntLabel, contentLabel, separatorView].forEach { contentView.addSubview($0) }
    }
    
    override func setConstraints() {
        super.setConstraints()
        
//        commentButton.backgroundColor = .lightGray
        commentButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(35)
        }
        
        bookmarkButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().inset(16)
            make.size.equalTo(35)
        }
        
        commentCntLabel.snp.makeConstraints { make in
            make.top.equalTo(commentButton.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
        }
        
        bookmarkCntLabel.snp.makeConstraints { make in
            make.top.equalTo(bookmarkButton.snp.bottom).offset(12)
            make.trailing.equalToSuperview().inset(20)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(commentCntLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(16)
        }
        
        separatorView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
        
    }
    
}
