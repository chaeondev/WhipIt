//
//  StyleCollectionViewCell.swift
//  WhipIt
//
//  Created by Chaewon on 11/26/23.
//

import UIKit

class StyleCollectionViewCell: BaseCollectionViewCell {
    
    lazy var photoImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .blue
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var userImageView: UIImageView = {
        let view = RoundImageView(frame: .zero)
        view.image = UIImage(systemName: "star")
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .brown
        return view
    }()
    
    lazy var userNickLabel: UILabel = UILabel.labelBuilder(text: "위핏이620", font: Font.light10, textColor: .darkGray)
    
    lazy var userStackView: UIStackView = UIStackView.stackViewBuilder(axis: .horizontal, distribution: .equalSpacing, spacing: 4)

    lazy var bookMarkButton: UIButton = {
        let view = UIButton.buttonBuilder(image: UIImage(systemName: "bookmark")!)
        view.tintColor = .gray
        return view
    }()
    
    lazy var bookMarkCntLabel: UILabel = UILabel.labelBuilder(text: "168", font: Font.light10, textColor: .gray)
    
    lazy var bookMarkStackView: UIStackView = UIStackView.stackViewBuilder(axis: .horizontal, distribution: .equalSpacing, spacing: 4)
    
    lazy var contentLabel: UILabel = UILabel.labelBuilder(text: "#코지챌린지 \n 궂은 날씨에도 포근하게 감싸줄 아우터!", font: Font.light12, textColor: .black, numberOfLines: 2)
    
    override func setHierarchy() {
        [userImageView, userNickLabel].forEach { userStackView.addArrangedSubview($0) }
        [bookMarkButton, bookMarkCntLabel].forEach { bookMarkStackView.addArrangedSubview($0) }
        [photoImageView, userStackView, bookMarkStackView, contentLabel].forEach { contentView.addSubview($0) }
    }
    
    override func setConstraints() {
        photoImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(contentView)
        }
        
        userImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
        }
        
        userStackView.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(8)
            make.leading.equalTo(contentView).offset(4)
            make.width.equalTo(photoImageView).multipliedBy(0.4)
        }
        
        bookMarkStackView.snp.makeConstraints { make in
            make.top.equalTo(photoImageView.snp.bottom).offset(8)
            make.trailing.equalTo(contentView).inset(4)
            make.width.equalTo(photoImageView).multipliedBy(0.23)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(userStackView.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(contentView).inset(4)
            make.bottom.equalTo(contentView).inset(8)
        }
    }
}
