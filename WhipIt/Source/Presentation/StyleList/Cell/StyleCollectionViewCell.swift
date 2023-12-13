//
//  StyleCollectionViewCell.swift
//  WhipIt
//
//  Created by Chaewon on 11/26/23.
//

import UIKit
import Kingfisher

final class StyleCollectionViewCell: BaseCollectionViewCell {
    
    private lazy var photoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .blue
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    private lazy var userImageView: UIImageView = {
        let view = RoundImageView(frame: .zero)
        view.image = UIImage(systemName: "star")
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .brown
        return view
    }()
    
    private lazy var userNickLabel: UILabel = UILabel.labelBuilder(text: "위핏이620", font: Font.light12, textColor: .darkGray)
    
    private lazy var userButton = UIButton()
    
    private lazy var bookMarkButton: UIButton = {
        let view = UIButton.buttonBuilder(image: UIImage(resource: .ribbon))
        view.tintColor = .gray
        return view
    }()
    
    private lazy var bookMarkCntLabel: UILabel = UILabel.labelBuilder(text: "168", font: Font.light12, textColor: .gray)
    
    private lazy var contentLabel: UILabel = {
        let view = UILabel.labelBuilder(text: "#코지챌린지 \n 궂은 날씨에도 포근하게 감싸줄 아우터!", font: UIFont(name: Suit.medium, size: 12)!, textColor: .black, numberOfLines: 2)
        view.lineBreakMode = .byWordWrapping //말줄임표 X
        view.sizeToFit()
        return view
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        
        photoImageView.kf.cancelDownloadTask()
        photoImageView.image = nil
        
        userImageView.kf.cancelDownloadTask()
        userImageView.image = nil
    }
    
    func configureCell(stylePost: Post) {
        let imageUrl = stylePost.image[0]
        let profileUrl = stylePost.creator.profile
        photoImageView.setKFImage(imageUrl: imageUrl)
        userImageView.setKFImage(imageUrl: profileUrl ?? "")
        userNickLabel.text = stylePost.creator.nick
        bookMarkCntLabel.text = "\(stylePost.likes.count)"
        contentLabel.text = stylePost.content
    }
    
    override func setHierarchy() {
        [photoImageView, userImageView, userNickLabel, userButton, bookMarkCntLabel, bookMarkButton, contentLabel].forEach { contentView.addSubview($0) }
    }
    
    override func setConstraints() {
        photoImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(contentView)
        }
        
        userImageView.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(8)
            make.leading.equalTo(contentView).offset(4)
            make.size.equalTo(20)
        }
        //userNickLabel.backgroundColor = .blue
        userNickLabel.snp.makeConstraints { make in
            make.centerY.equalTo(userImageView)
            make.leading.equalTo(userImageView.snp.trailing).offset(8)
            make.width.lessThanOrEqualTo(photoImageView).multipliedBy(0.5)
        }
        
        userButton.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(4)
            make.leading.equalToSuperview()
            make.trailing.equalTo(userNickLabel)
            make.height.equalTo(25)
        }
        
        bookMarkCntLabel.snp.makeConstraints { make in
            make.centerY.equalTo(userImageView)
            make.trailing.equalToSuperview().inset(8)
        }
        
        bookMarkButton.snp.makeConstraints { make in
            make.centerY.equalTo(userImageView)
            make.trailing.equalTo(bookMarkCntLabel.snp.leading).offset(-4)
            make.size.equalTo(20)
        }
      
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(userImageView.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(contentView).inset(4)
            make.height.greaterThanOrEqualTo(20)
            make.bottom.equalTo(contentView).inset(8)
        }
    }
}
