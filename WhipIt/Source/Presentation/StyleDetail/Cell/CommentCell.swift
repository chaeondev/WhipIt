//
//  CommentCell.swift
//  WhipIt
//
//  Created by Chaewon on 12/7/23.
//

import UIKit

final class CommentCell: BaseCollectionViewCell {
    let profileImageView = {
        let view = RoundImageView(frame: .zero)
        view.image = UIImage(systemName: "star")
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    let userLabel = UILabel.labelBuilder(text: "위핏이8888", font: UIFont(name: Suit.extraBold, size: 12)!, textColor: .black, numberOfLines: 1)
    let dateLabel = UILabel.labelBuilder(text: "3일 전", font: Font.light10, textColor: .gray)
    let commentLabel = UILabel.labelBuilder(text: "피드 자주 보고있어요! \n너무 예뻐요", font: Font.light12, textColor: .black)
    lazy var menuButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        view.tintColor = .lightGray
        return view
    }()
    
    func configureCell(_ comment: Comment) {
        profileImageView.setKFImage(imageUrl: comment.creator.profile ?? "")
        userLabel.text = comment.creator.nick
        dateLabel.text = comment.time.changeFromTimeToRelativeDate()
        commentLabel.text = comment.content
    }
    
    override func setHierarchy() {
        super.setHierarchy()
        [profileImageView, userLabel, dateLabel, commentLabel, menuButton].forEach { contentView.addSubview($0) }
    }
    
    override func setConstraints() {
        super.setConstraints()
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(35)
        }
        
        userLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(14)
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.bottom.equalTo(userLabel)
            make.leading.equalTo(userLabel.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().inset(8)
        }
        
        menuButton.snp.makeConstraints { make in
            make.centerY.equalTo(userLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(20)
        }
        
        commentLabel.snp.makeConstraints { make in
            make.top.equalTo(userLabel.snp.bottom).offset(2)
            make.leading.equalTo(userLabel)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(12)
        }
    }
}
